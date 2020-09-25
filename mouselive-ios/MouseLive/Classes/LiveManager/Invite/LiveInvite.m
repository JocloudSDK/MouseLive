//
//  LiveInvite.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveInvite.h"
#import "NSDictionary+AddAction.h"
#import "WSInviteRequest.h"
#import <YYModel.h>
#import "CCService.h"

#define TIME_OUT_INTERVAL 15


@interface LiveInvite()

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic) NSMutableDictionary *actionDic;
@property (nonatomic) NSTimer *timer;
@property (nonatomic, weak) id<LiveInviteDelegate> delegate;
@property (nullable, nonatomic, strong) dispatch_queue_t inviteQueue;
@property (nonatomic, strong) LiveInviteItem *remoteItem;
@property (nonatomic, strong) LiveInviteItem *localItem;
@property (nonatomic, assign) LiveType roomType;
@property (nonatomic, copy) NSString *tranceId;

@end

@implementation LiveInvite

- (instancetype)initWithDelegate:(id<LiveInviteDelegate>)delegate uid:(NSString *)uid roomid:(NSString *)roomid roomType:(LiveType)roomType
{
    if (self = [super init]) {
        self.delegate = delegate;
        self.localItem = [LiveInviteItem alloc];
        self.inviteQueue = dispatch_queue_create("com.sy.invite.queue", DISPATCH_QUEUE_SERIAL);
        self.localItem.uid = uid;
        self.localItem.roomid = roomid;
        self.roomType = roomType;
    }
    return self;
}

- (void)sendInvoteWithUid:(NSString *)uid roomId:(NSString *)roomid complete:(SendComplete)complete
{
    if (self.isRunning) {
        if (complete) {
            complete([NSError errorWithDomain:@"已经在连麦申请中。。。" code:1 userInfo:nil]);
        }
        return;
    }

    self.remoteItem.uid = uid;
    self.remoteItem.roomid = roomid;
    
    // 发送连麦请求
    WSInviteRequest *q = [[WSInviteRequest alloc] init];
    q.SrcUid = self.localItem.uid.longLongValue;
    q.SrcRoomId = self.localItem.roomid.longLongValue;
    q.DestUid = self.remoteItem.uid.longLongValue;
    q.DestRoomId = self.remoteItem.roomid.longLongValue;
    self.tranceId = [q createTraceId];
    q.ChatType = (int)self.roomType;
    
    WeakSelf
    [[CCService sharedInstance] sendApply:q complete:^(NSError * _Nullable error) {
        if (error) {
            YYLogDebug(@"[MouseLive-LiveInvite] sendInvoteWithUid sendApply error:%@", error);
        }
        else {
            weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:TIME_OUT_INTERVAL * 1.f target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
            weakSelf.isRunning = YES;
        }
        
        if (complete) {
            complete(error);
        }
    }];
}

- (void)cancelWithComplete:(SendComplete)complete
{
    if (self.isRunning) {
        WSInviteRequest *q = [[WSInviteRequest alloc] init];
        q.SrcUid = self.localItem.uid.longLongValue;
        q.SrcRoomId = self.localItem.roomid.longLongValue;
        q.DestUid = self.remoteItem.uid.longLongValue;
        q.DestRoomId = self.remoteItem.roomid.longLongValue;
        q.TraceId = self.tranceId;
        q.ChatType = (int)self.roomType;
        
        WeakSelf
        [[CCService sharedInstance] sendCancel:q complete:^(NSError * _Nullable error) {
            if (error) {
                YYLogDebug(@"[MouseLive-LiveInvite] cancelWithUid sendCancel error:%@", error);
            }
            else {
                // 如果正在运行，发送取消请求，关闭定时器
                [weakSelf.timer invalidate];
                weakSelf.isRunning = NO;
            }
            
            if (complete) {
                complete(error);
            }
        }];
        
        self.tranceId = @"";
    }
}

#pragma mark - action

- (void)timerAction
{
    if (self.isRunning) {
        self.isRunning = NO;
        
        // 超时就取消
        // 发送 roomid + uid
        WSInviteRequest *q = [[WSInviteRequest alloc] init];
        q.SrcUid = self.localItem.uid.longLongValue;
        q.SrcRoomId = self.localItem.roomid.longLongValue;
        q.DestUid = self.remoteItem.uid.longLongValue;
        q.DestRoomId = self.remoteItem.roomid.longLongValue;
        q.TraceId = self.tranceId;
        q.ChatType = (int)self.roomType;
        self.tranceId = @"";
        
        WeakSelf
        [[CCService sharedInstance] sendCancel:q complete:^(NSError * _Nullable error) {
            if (error) {
                YYLogDebug(@"[MouseLive-LiveInvite] cancelWithUid sendCancel error:%@", error);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(didInviteWithCmd:item:)]) {
                    // 返回超时
                    [weakSelf.delegate didInviteWithCmd:LIVE_INVITE_TYPE_TIME_OUT item:weakSelf.remoteItem];
                }
            });
        }];
    }
}

#pragma mark -- handler
- (BOOL)handleWithType:(LiveInviteActionType)type object:(id)object
{
    if (self.isRunning) {
        self.isRunning = NO;
        [self.timer invalidate];
        self.timer = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didInviteWithCmd:item:)]) {
                [self.delegate didInviteWithCmd:type item:self.remoteItem];
            }
        });
    }
    else {
        return NO;
    }
    
    return YES;
}

- (BOOL)handleAccept:(id)object
{
    // 获取到主播接受
    return [self handleWithType:LIVE_INVITE_TYPE_ACCEPT object:object];
}

- (BOOL)handleRefuse:(id)object
{
    // 主播拒绝
    return [self handleWithType:LIVE_INVITE_TYPE_REFUSE object:object];
}

- (BOOL)handleRunning:(id)object
{
    // 主播正在连麦
    return [self handleWithType:LIVE_INVITE_TYPE_RUNNING object:object];
}

#pragma mark - setter / getter

- (BOOL)isIsRunning
{
    __block BOOL running = NO;
    dispatch_sync(self.inviteQueue, ^{
        running = _isRunning;
    });
    return running;
}

- (void)setIsRunning:(BOOL)isRunning
{
     dispatch_sync(self.inviteQueue, ^{
        _isRunning = isRunning;
    });
}

- (NSDictionary *)actionDic
{
    if (!_actionDic) {
        _actionDic = [[NSMutableDictionary alloc] init];
        [_actionDic yy_setAction:@selector(handleAccept:) forKey:@(CCS_CHAT_ACCEPT)];
        [_actionDic yy_setAction:@selector(handleRefuse:) forKey:@(CCS_CHAT_REJECT)];
        [_actionDic yy_setAction:@selector(handleRunning:) forKey:@(CCS_CHAT_CANCEL)];
        [_actionDic yy_setAction:@selector(handleRunning:) forKey:@(CCS_CHAT_CHATTING)];
    }
    return _actionDic;
}

- (LiveInviteItem *)remoteItem
{
    if (!_remoteItem) {
        _remoteItem = [LiveInviteItem alloc];
    }
    return _remoteItem;
}

- (BOOL)handleMsgWithCmd:(NSNumber *)cmd body:(NSDictionary *)body
{
    if ([cmd intValue] == CCS_CHAT_CHATTING) {
        return [self.actionDic yy_invokeActionWithKey:cmd target:self object:body];
    }
    // body 中判断是否是当前的 roomid + uid
    WSInviteRequest *q = (WSInviteRequest *)[WSInviteRequest yy_modelWithJSON:body];
    if (q.SrcUid == self.remoteItem.uid.longLongValue && q.DestUid == self.localItem.uid.longLongValue
        && q.SrcRoomId == self.remoteItem.roomid.longLongValue && q.DestRoomId  == self.localItem.roomid.longLongValue) {
        // 是本次内容
        return [self.actionDic yy_invokeActionWithKey:cmd target:self object:q];
    }
    return NO;
}

@end
