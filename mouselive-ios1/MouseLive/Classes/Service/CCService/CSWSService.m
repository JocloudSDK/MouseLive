//
//  CSWSService.m
//  MouseLive
//
//  Created by 张建平 on 2020/4/14.
//  Copyright © 2020 sy. All rights reserved.
//

#import "CSWSService.h"
#import "CCService.h"
#import "WSService.h"
#import <NSObject+YYModel.h>
#import "SYAppInfo.h"



@interface CSWSService () <WSServiceDelegate>

@property (nonatomic, weak) id<CCServiceDelegate> observer;
@property (nonatomic, strong) WSRoomRequest *roomReq;
@property (nonatomic, strong) NSMutableArray *taskArray;
@end

@implementation CSWSService

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self alloc];
    });
    return sharedInstance;
}

/// 加入房间
- (void)joinRoom
{
    YYLogDebug(@"[MouseLive-CSWSService] joinRoom entry");
    [[WSService sharedInstance] addObserver:self];
    [[WSService sharedInstance] connect];
    YYLogDebug(@"[MouseLive-CSWSService] joinRoom exit");
}

/// 离开房间
- (void)leaveRoom
{
    YYLogDebug(@"[MouseLive-CSWSService] leaveRoom entry");
    self.roomReq = nil;
    [[SYHttpService shareInstance]cancelAllRequest];
    [[WSService sharedInstance] removeObserver:self];
    [[WSService sharedInstance] close];
    YYLogDebug(@"[MouseLive-CSWSService] leaveRoom exit");
}

// 增加观察者
/// @param observer id<CCServiceDelegate>
- (void)addObserver:(id<CCServiceDelegate>)observer
{
    self.observer = observer;
}

/// 移除观察者
/// @param observer id<CCServiceDelegate>
- (void)removeObserver:(id<CCServiceDelegate>)observer
{
    self.observer = nil;
}

/// 发送请求连麦请求 -- WS_CHAT_APPLY
/// @param req WSInviteRequest 结构体
- (void)sendApply:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSWSService] sendApply entry");
    [[WSService sharedInstance]sendWithParam:WS_CHAT_APPLY object:req];
    if (complete) {
        complete(nil);
    }
    YYLogDebug(@"[MouseLive-CSWSService] sendApply exit");
}

/// 发送接受连麦请求 -- WS_CHAT_ACCEPT
/// @param req WSInviteRequest 结构体
- (void)sendAccept:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSWSService] sendAccept entry");
    [[WSService sharedInstance]sendWithParam:WS_CHAT_ACCEPT object:req];
    if (complete) {
        complete(nil);
    }
    YYLogDebug(@"[MouseLive-CSWSService] sendAccept exit");
}

/// 发送拒绝连麦请求 -- WS_CHAT_REJECT
/// @param req WSInviteRequest 结构体
- (void)sendReject:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSWSService] sendReject entry");
    [[WSService sharedInstance]sendWithParam:WS_CHAT_REJECT object:req];
    if (complete) {
        complete(nil);
    }
    YYLogDebug(@"[MouseLive-CSWSService] sendReject exit");
}

/// 发送取消连麦请求 -- WS_CHAT_CANCEL
/// @param req WSInviteRequest 结构体
- (void)sendCancel:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSWSService] sendCancel entry");
    [[WSService sharedInstance]sendWithParam:WS_CHAT_CANCEL object:req];
    if (complete) {
        complete(nil);
    }
    YYLogDebug(@"[MouseLive-CSWSService] sendCancel exit");
}

/// 发送挂断连麦请求 -- WS_CHAT_HANGUP
/// @param req WSInviteRequest 结构体
- (void)sendHangup:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSWSService] sendHangup entry");
    [[WSService sharedInstance]sendWithParam:WS_CHAT_HANGUP object:req];
    if (complete) {
        complete(nil);
    }
    YYLogDebug(@"[MouseLive-CSWSService] sendHangup exit");
}

/// 发送自己开麦/闭麦连麦请求 -- WS_CHAT_MIC_ENABLE
/// @param req WSMicOffRequest 结构体
- (void)sendMicEnable:(WSMicOffRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSWSService] sendMicEnable entry");
    [[WSService sharedInstance]sendWithParam:WS_CHAT_MIC_ENABLE object:req];
    if (complete) {
        complete(nil);
    }
    YYLogDebug(@"[MouseLive-CSWSService] sendMicEnable exit");
}

/// 发送进入房间的请求
/// @param req WSRoomRequest 结构体
- (void)sendJoinRoom:(WSRoomRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSWSService] sendJoinRoom entry");
    self.roomReq = req;
    if ([WSService sharedInstance].state == WS_CONNECTED) {
        YYLogDebug(@"[MouseLive-CSWSService] sendJoinRoom send WS_JOIN_ROOM");
        [[WSService sharedInstance] sendWithParam:WS_JOIN_ROOM object:self.roomReq];
    }
    
    if (complete) {
        complete(nil);
    }
    YYLogDebug(@"[MouseLive-CSWSService] sendJoinRoom exit");
}

/// 发送退出房间的请求
/// @param req WSRoomRequest 结构体
- (void)sendLeaveRoom:(WSRoomRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSWSService] sendLeaveRoom entry");
    [[WSService sharedInstance]sendWithParam:WS_LEAVE_ROOM object:req];
    if (complete) {
        complete(nil);
    }
    YYLogDebug(@"[MouseLive-CSWSService] sendLeaveRoom exit");
}

- (void)sendAppStateToServer:(AppStateToServer)appState
{
    YYLogDebug(@"[MouseLive-CSWSService] sendAppStateToServer appState:%lu", (unsigned long)appState);
    NSString *localUid = [NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults]dictionaryForKey:kUserInfo] objectForKey:kUid]];;
    NSDictionary *params = @{
        kUid:@(localUid.longLongValue),
        kUStatus:@(appState)
    };
    SYHttpService *httpClient  = [SYHttpService shareInstance];
    [httpClient sy_httpRequestWithType:SYHttpRequestKeyType_SetStatus params:params success:^(NSString *taskId,id  _Nullable respObjc) {
        NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
        if ([code isEqualToString:ksuccessCode]) {
            YYLogDebug(@"MouseLive-CSWSService] sendAppStateToServer SYHttpRequestKeyType_GetUserInfo success!!!");
        }
    } failure:^(NSString *taskId, NSError *error) {
        YYLogDebug(@"MouseLive-CSWSService] sendAppStateToServer SYHttpRequestKeyType_GetUserInfo failed, error:%@",error);
    }];
    
}

#pragma mark -- 这些操作都应该拿到外面去做
/// 切到后台
- (void)handleAppDidBecomeActive
{
    YYLogDebug(@"[MouseLive-CSWSService] handleAppDidBecomeActive entry");
    // TODO: zhangjianping -- 先不发送切后台消息，因为 iOS 现在切后台+息屏是不会断开 tcp
    // 1. 发送给服务器已经切到后台
    //[self sendAppStateToServer:USER_STATUS_BACK_GROUND];
    
    // 2. 处理 ws
    [[WSService sharedInstance] handleAppDidBecomeActive];
    YYLogDebug(@"[MouseLive-CSWSService] handleAppDidBecomeActive exit");
}

/// 切到前台
- (void)handleAppWillResignActive
{
    YYLogDebug(@"[MouseLive-CSWSService] handleAppWillResignActive entry");
    // 1. 处理 ws
    [[WSService sharedInstance] handleAppWillResignActive];
    YYLogDebug(@"[MouseLive-CSWSService] handleAppWillResignActive exit");
}

/// 杀进程
- (void)handleAppWillTerminate
{
    // 发送退出房间的消息
    [self sendLeaveRoom:self.roomReq complete:nil];
}

/// 接听电话
- (void)handleAppInterruptionBegan
{
    
}

/// 挂断电话
- (void)handleAppInterruptionEnded
{
    
}
#pragma mark -- 这些操作都应该拿到外面去做


#pragma mark -- WS handler
- (BOOL)handleCmdWithSelector:(SEL)aSelector body:(id)body
{
    BOOL ret = NO;
    if ([self.observer respondsToSelector:aSelector]) {
        ret = (BOOL)[self.observer performSelector:aSelector withObject:body];
    }
    return ret;
}

#pragma mark -- WSDelegate
- (BOOL)websocketRecvMsgWithCmd:(NSNumber *)type body:(NSDictionary *)body
{
    YYLogDebug(@"[MouseLive-CSWSService]. recvMsgWithCmd entry, body:%@, type:%lu", body, (unsigned long)type);
    int cmd = [type intValue];
    switch (cmd) {
        case WS_JOIN_ROOM:   // 接受到这个消息是 ack
            return [self handleJoinRoomAck];
        case WS_CHAT_HANGUP:
            return [self handleCmdWithSelector:@selector(didChatHangup:) body:body];
        case WS_CHAT_HANGUP_BROADCAST:
            return [self handleCmdWithSelector:@selector(didHangupBroadcast:) body:body];
        case WS_CHAT_CHATING_BROADCAST:
            return [self handleCmdWithSelector:@selector(didChatingBroadcast:) body:body];
        case WS_LEAVE_BROADCAST: {
            WSRoomRequest *q = (WSRoomRequest *)[WSRoomRequest yy_modelWithJSON:body];
            return [self handleCmdWithSelector:@selector(didLeaveRoomBroadcast:) body:[NSArray arrayWithObject:q]];
        }
        case WS_JOIN_BROADCAST: {
            WSRoomRequest *q = (WSRoomRequest *)[WSRoomRequest yy_modelWithJSON:body];
            return [self handleCmdWithSelector:@selector(didJoinRoomBroadcast:) body:[NSArray arrayWithObject:q]];
        }
        case WS_CHAT_MIC_ENABLE_BROADCAST:
            return [self handleCmdWithSelector:@selector(didMicEnableBroadcast:) body:body];
        case WS_CHAT_APPLY:
            return [self handleCmdWithSelector:@selector(didChatApply:) body:body];
        case WS_CHAT_ACCEPT:
            return [self handleCmdWithSelector:@selector(didChatAccept:) body:body];
        case WS_CHAT_REJECT:
            return [self handleCmdWithSelector:@selector(didChatReject:) body:body];
        case WS_CHAT_CANCEL:
            return [self handleCmdWithSelector:@selector(didChatCancel:) body:body];
        case WS_CHAT_CHATTING:
            return [self handleCmdWithSelector:@selector(didChattingLimit:) body:body];
        case WS_ERROR:
            return [self handleWSError];
        default:
            break;
    }
    YYLogDebug(@"[MouseLive-CSWSService]. recvMsgWithCmd exit");
    return NO;
}

- (BOOL)handleWSError
{
    // 处理错误
    YYLogDebug(@"[MouseLive-CSWSService] handleWSError entry");
    if ([self.observer respondsToSelector:@selector(didNetError:)]) {
        YYLogDebug(@"[MouseLive-CSWSService] handleWSError send didNetError");
        [self.observer didNetError:[NSError errorWithDomain:@"WS return error" code:22222 userInfo:nil]];
    }
    YYLogDebug(@"[MouseLive-CSWSService] handleWSError exit");
    return YES;
}

- (BOOL)handleJoinRoomAck
{
//    2020/05/12 20:57:05:977  [MouseLive-WSService] [cmd: 进入房间] 接受请求, json = {"MsgId":201,"Body":{"TraceId":"","MsgName":"EV_CS_ENTER_ROOM_NTY","Code":"Ack"}}
    
    // 如果返回进入房间成功，才会发送已经 didNetConnected
    YYLogDebug(@"[MouseLive-CSWSService] handleJoinRoomAck entry");
    if ([self.observer respondsToSelector:@selector(didNetConnected)]) {
        YYLogDebug(@"[MouseLive-CSWSService] handleJoinRoomAck send didNetConnected");
        [self.observer didNetConnected];
    }
    YYLogDebug(@"[MouseLive-CSWSService] handleJoinRoomAck exit");
    return YES;
}

- (void)websocketDidNetError:(int)err
{
    YYLogDebug(@"[MouseLive-CSWSService] didNetError entry");
    if ([self.observer respondsToSelector:@selector(didNetError:)]) {
        YYLogDebug(@"[MouseLive-CSWSService] didNetError, err:%d", err);
        [self.observer didNetError:[NSError errorWithDomain:@"WS网络错误" code:err userInfo:nil]];
    }
    YYLogDebug(@"[MouseLive-CSWSService] didNetError exit");
}

- (void)webSocketDidOpen
{
    YYLogDebug(@"[MouseLive-CSWSService] webSocketDidOpen entry");
    YYLogDebug(@"[MouseLive-APPDelegate] App build:%@, version:%@", [SYAppInfo sharedInstance].appBuild, [SYAppInfo sharedInstance].appVersion);
    
    if (self.roomReq) {
        // 连接上，就需要发送 join room 消息
        YYLogDebug(@"[MouseLive-CSWSService] webSocketDidOpen entry, send WS_JOIN_ROOM");
        [[WSService sharedInstance]sendWithParam:WS_JOIN_ROOM object:self.roomReq];
    }
    
#if 0
    // 不能在这里发送已经连接的消息 -- 在 handleJoinRoomAck 发送
    if (self.firstConnected) {
        // 如果不是第一次，就表示要重连了，就要返回已经连接完成的消息
        if ([self.observer respondsToSelector:@selector(didNetConnected)]) {
            [self.observer didNetConnected];
        }
    }
    else {
        self.firstConnected = YES;
    }
#endif

    YYLogDebug(@"[MouseLive-CSWSService] webSocketDidOpen exit");
}

- (void)webSocketDidClose
{
    YYLogDebug(@"[MouseLive-CSWSService] webSocketDidClose entry");
    if ([self.observer respondsToSelector:@selector(didNetClose)]) {
        YYLogDebug(@"[MouseLive-CSWSService] webSocketDidClose");
        [self.observer didNetClose];
    }
    YYLogDebug(@"[MouseLive-CSWSService] webSocketDidClose exit");
}

- (void)webSocketDidConnecting
{
    YYLogDebug(@"[MouseLive-CSWSService] webSocketDidConnecting entry");
    if ([self.observer respondsToSelector:@selector(didnetConnecting)]) {
        YYLogDebug(@"[MouseLive-CSWSService] webSocketDidConnecting");
        [self.observer didnetConnecting];
    }
    YYLogDebug(@"[MouseLive-CSWSService] webSocketDidConnecting exit");
}

#pragma mark -- get / set
- (NSMutableArray *)taskArray
{
    if (!_taskArray) {
        _taskArray = [[NSMutableArray alloc] init];
    }
    return _taskArray;
}

@end
