//
//  LiveBeInvited.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveBeInvited.h"
#import "NSDictionary+AddAction.h"
#import "TaskQueueWaitForComplete.h"
#import "WSInviteRequest.h"
#import <YYModel.h>
#import "CCService.h"

@interface LiveBeInvited() <TaskQueueWaitForCompleteDelegate>

@property (nonatomic) NSMutableDictionary *actionDic;
@property (nonatomic, weak) id<LiveBeInvitedDelegate> delegate;
@property (nonatomic, strong) TaskQueueWaitForComplete *taskQueue;
@property (nonatomic, strong) NSMutableDictionary *beInvitedDic;
@property (nonatomic, strong) NSMutableDictionary *allItemDic;
@property (nullable, nonatomic, strong) dispatch_queue_t inviteQueue;

@end

@implementation LiveBeInvited

- (instancetype)initWithDelegate:(id<LiveBeInvitedDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        self.allItemDic = [[NSMutableDictionary alloc] init];
        self.beInvitedDic = [[NSMutableDictionary alloc] init];
        self.inviteQueue = dispatch_queue_create("com.sy.beinvited.queue", DISPATCH_QUEUE_SERIAL);
        self.taskQueue = [[TaskQueueWaitForComplete alloc] init];
        [self.taskQueue start];
    }
    return self;
}

- (void)destory
{
    [self.taskQueue stop];
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.inviteQueue, ^{
        // 移除 task
        [weakSelf.beInvitedDic removeAllObjects];
        [weakSelf.allItemDic removeAllObjects];
    });
}

- (void)completeWithUid:(NSString *)uid
{
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.inviteQueue, ^{
        NSNumber *taskId = [weakSelf.allItemDic objectForKey:uid];
        if (taskId) {
            [weakSelf.beInvitedDic removeObjectForKey:taskId];
            [weakSelf.allItemDic removeObjectForKey:uid];
            
            [self.taskQueue completeTask:taskId];
        }
    });
}

- (void)acceptWithUid:(NSString *)uid complete:(SendAcceptComplete)complete
{
    NSNumber *taskId = [self.allItemDic objectForKey:uid];
    NSString *roomid = @"";
    if (taskId) {
        WSInviteRequest *item = (WSInviteRequest *)[self.beInvitedDic objectForKey:taskId];
         __weak typeof(self) weakSelf = self;
        
        // 源是对方的目的，目的是对方的源
        WSInviteRequest *q = [[WSInviteRequest alloc] init];
        q.SrcUid = item.DestUid;
        q.SrcRoomId = item.DestRoomId;
        q.DestUid = item.SrcUid;
        q.DestRoomId = item.SrcRoomId;
        q.ChatType = item.ChatType;
        q.TraceId = item.TraceId;
        roomid = [NSString stringWithFormat:@"%lld", item.SrcRoomId];
        
        // 发送接受请求
        [[CCService sharedInstance] sendAccept:q complete:^(NSError * _Nullable error) {
            if (!error) {
                dispatch_sync(weakSelf.inviteQueue, ^{
                    // 移除 task
                    [weakSelf.beInvitedDic removeObjectForKey:taskId];
                    [weakSelf.allItemDic removeObjectForKey:[NSString stringWithFormat:@"%lld", item.SrcUid]];
                    [weakSelf.taskQueue completeTask:taskId];
                });
            }
            else {
                YYLogDebug(@"[MouseLive-LiveBeInvited] acceptWithUid sendAccept error:%@", error);
            }
            
            if (complete) {
                complete(error, roomid);
            }
        }];
    }
}

- (void)refuseWithUid:(NSString *)uid complete:(SendComplete)complete
{
    NSNumber *taskId = [self.allItemDic objectForKey:uid];
    if (taskId) {
        WSInviteRequest *item = (WSInviteRequest *)[self.beInvitedDic objectForKey:taskId];
        __weak typeof(self) weakSelf = self;
        
        // 源是对方的目的，目的是对方的源
        WSInviteRequest *q = [[WSInviteRequest alloc] init];
        q.SrcUid = item.DestUid;
        q.SrcRoomId = item.DestRoomId;
        q.DestUid = item.SrcUid;
        q.DestRoomId = item.SrcRoomId;
        q.ChatType = item.ChatType;
        q.TraceId = item.TraceId;

        // 发送拒绝请求
        [[CCService sharedInstance] sendReject:q complete:^(NSError * _Nullable error) {
            if (!error) {
                dispatch_sync(weakSelf.inviteQueue, ^{
                    // 移除 task
                    [weakSelf.beInvitedDic removeObjectForKey:taskId];
                    [weakSelf.allItemDic removeObjectForKey:[NSString stringWithFormat:@"%lld", item.SrcUid]];
                    [weakSelf.taskQueue completeTask:taskId];
                });
            }
            else {
                YYLogDebug(@"[MouseLive-LiveBeInvited] refuseWithUid sendReject error:%@", error);
            }
            
            if (complete) {
                complete(error);
            }
        }];
    }
}

- (void)cancelWithUidId:(NSString *)uid
{
    NSNumber *taskId = [self.allItemDic objectForKey:uid];
    if (taskId) {
        WSInviteRequest *item = (WSInviteRequest *)[self.beInvitedDic objectForKey:taskId];
        __weak typeof(self) weakSelf = self;
        
        // 源是对方的目的，目的是对方的源
        WSInviteRequest *q = [[WSInviteRequest alloc] init];
        q.SrcUid = item.DestUid;
        q.SrcRoomId = item.DestRoomId;
        q.DestUid = item.SrcUid;
        q.DestRoomId = item.SrcRoomId;
        q.ChatType = item.ChatType;
        q.TraceId = item.TraceId;
        
        [[CCService sharedInstance] sendCancel:q complete:^(NSError * _Nullable error) {
            if (!error) {
                dispatch_sync(weakSelf.inviteQueue, ^{
                    // 移除 task
                    [weakSelf.beInvitedDic removeObjectForKey:taskId];
                    [weakSelf.allItemDic removeObjectForKey:[NSString stringWithFormat:@"%lld", item.SrcUid]];
                    [weakSelf.taskQueue completeTask:taskId];
                });
            }
            else {
                YYLogDebug(@"[MouseLive-LiveBeInvited] refuseWithUid sendReject error:%@", error);
            }
        }];
    }
}

- (void)clearBeInvitedQueue
{
    for (WSInviteRequest* item in [self.beInvitedDic allValues]) {
        [self cancelWithUidId:[NSString stringWithFormat:@"%lld", item.SrcUid]];
    }
//    [self.beInvitedDic removeAllObjects];
}

#pragma mark -- handler
- (BOOL)handleInvite:(id)object
{
    // 如果接受到邀请
    WSInviteRequest *item = (WSInviteRequest *)object;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.inviteQueue, ^{
        NSNumber *taskID = [self.taskQueue addTaskWithObject:item delegate:self];
        [weakSelf.beInvitedDic setObject:item forKey:taskID];
        [weakSelf.allItemDic setObject:taskID forKey:[NSString stringWithFormat:@"%lld", item.SrcUid]];
    });
    return YES;
}

- (BOOL)handleCancel:(id)object
{
    WSInviteRequest *item = (WSInviteRequest *)object;
    
    __weak typeof(self) weakSelf = self;
    __block BOOL ret = NO;
    dispatch_sync(self.inviteQueue, ^{
        // 删除数据
        NSNumber *taskId = [weakSelf.allItemDic objectForKey:[NSString stringWithFormat:@"%lld", item.SrcUid]];
        if (taskId) {
            ret = YES;
            [weakSelf.beInvitedDic removeObjectForKey:taskId];
            [weakSelf.allItemDic removeObjectForKey:[NSString stringWithFormat:@"%lld", item.SrcUid]];
            
            [self.taskQueue completeTask:taskId];
        }
    });
    
    // 回调通知
    if (ret) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didBeInvitedWithCmd:item:)]) {
                // 获取对方 uid + roomid
                LiveInviteItem *item1 = [LiveInviteItem alloc];
                item1.uid = [NSString stringWithFormat:@"%lld", item.SrcUid];
                item1.roomid = [NSString stringWithFormat:@"%lld", item.SrcRoomId];
                [self.delegate didBeInvitedWithCmd:LIVE_BE_INVITED_CANCEL item:item1];
            }
        });
    }
    return ret;
}


#pragma mark - setter / getter

- (NSDictionary *)actionDic
{
    if (!_actionDic) {
        _actionDic = [[NSMutableDictionary alloc] init];
        [_actionDic yy_setAction:@selector(handleInvite:) forKey:@(CCS_CHAT_APPLY)];
        [_actionDic yy_setAction:@selector(handleCancel:) forKey:@(CCS_CHAT_CANCEL)];
    }
    return _actionDic;
}

#pragma mark - TaskQueueDelegate
- (void)executeWithReq:(NSNumber *)req object:(id)object
{
    // TODO: 在 ui 主线程中运行
    __weak typeof(self) weakSelf = self;
    __block WSInviteRequest *item = nil;
    dispatch_sync(self.inviteQueue, ^{
        // 获取被邀请的人
        item = (WSInviteRequest *)[weakSelf.beInvitedDic objectForKey:req];
    });
    
    if (item) {
        // 发送到外部
        if ([self.delegate respondsToSelector:@selector(didBeInvitedWithCmd:item:)]) {
            // 获取对方 uid + roomid
            LiveInviteItem *item1 = [LiveInviteItem alloc];
            item1.uid = [NSString stringWithFormat:@"%lld", item.SrcUid];
            item1.roomid = [NSString stringWithFormat:@"%lld", item.SrcRoomId];
            [self.delegate didBeInvitedWithCmd:LIVE_BE_INVITED_APPLY item:item1];
        }
    }
}

#pragma mark - WSServiceDelegate
- (BOOL)handleMsgWithCmd:(NSNumber *)cmd body:(NSDictionary *)body
{
    WSInviteRequest *q = (WSInviteRequest *)[WSInviteRequest yy_modelWithJSON:body];
    return [self.actionDic yy_invokeActionWithKey:cmd target:self object:q];
}

@end
