//
//  CCService.m
//  MouseLive
//
//  Created by 张建平 on 2020/4/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import "CCService.h"
#import "CSServiceProtocol.h"
#import "CSWSService.h"
#import "CSHummerService.h"
#import "SYAppStatusManager.h"

@interface CCService () <SYAppStatusManagerDelegate>

@property (nonatomic, strong) id<CSServiceProtocol> servicer;
@property (nonatomic, weak) id<CCServiceDelegate> observer;

@end

@implementation CCService

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
    YYLogDebug(@"[MouseLive-CSService] joinRoom entry");
    if (self.servicer) {
        [self.servicer joinRoom];
    }
    
    [[SYAppStatusManager shareManager] addDelegate:self forKey:@"CCService"];
    YYLogDebug(@"[MouseLive-CSService] joinRoom exit");
}

/// 离开房间
- (void)leaveRoom
{
    YYLogDebug(@"[MouseLive-CSService] leaveRoom entry");
    if (self.servicer) {
        [self.servicer leaveRoom];
    }
    
    [[SYAppStatusManager shareManager] removeDelegateForKey:@"CCService"];
    YYLogDebug(@"[MouseLive-CSService] leaveRoom exit");
}

/// 增加观察者
/// @param observer id<CCServiceDelegate>
- (void)addObserver:(id<CCServiceDelegate>)observer
{
    self.observer = observer;
    if (self.servicer) {
        [self.servicer addObserver:observer];
    }
}

/// 移除观察者
/// @param observer id<CCServiceDelegate>
- (void)removeObserver:(id<CCServiceDelegate>)observer
{
    self.observer = nil;
    if (self.servicer) {
        [self.servicer removeObserver:observer];
    }
}

/// 是否使用 WS
/// @param ws YES - 使用
- (void)setUseWS:(BOOL)ws
{
    YYLogDebug(@"[MouseLive-CSService] setUseWS entry, ws:%d", ws);
    self.servicer = nil;
    if (ws) {
        self.servicer = [CSWSService sharedInstance];
    }
    else {
        self.servicer = [CSHummerService sharedInstance];
    }
    
    if (self.observer) {
        [self.servicer addObserver:self.observer];
    }
    YYLogDebug(@"[MouseLive-CSService] setUseWS exit");
}

/// 发送请求连麦请求 -- WS_CHAT_APPLY
/// @param req WSInviteRequest 结构体
- (void)sendApply:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSService] sendApply entry, req:%@", [req string]);
    if (self.servicer) {
        [self.servicer sendApply:req complete:complete];
    }
    YYLogDebug(@"[MouseLive-CSService] sendApply exit");
}

/// 发送接受连麦请求 -- WS_CHAT_ACCEPT
/// @param req WSInviteRequest 结构体
- (void)sendAccept:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSService] sendAccept entry, req:%@", [req string]);
    if (self.servicer) {
        [self.servicer sendAccept:req complete:complete];
    }
    YYLogDebug(@"[MouseLive-CSService] sendAccept exit");
}

/// 发送拒绝连麦请求 -- WS_CHAT_REJECT
/// @param req WSInviteRequest 结构体
- (void)sendReject:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSService] sendReject entry, req:%@", [req string]);
    if (self.servicer) {
        [self.servicer sendReject:req complete:complete];
    }
    YYLogDebug(@"[MouseLive-CSService] sendReject exit");
}

/// 发送取消连麦请求 -- WS_CHAT_CANCEL
/// @param req WSInviteRequest 结构体
- (void)sendCancel:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSService] sendCancel entry, req:%@", [req string]);
    if (self.servicer) {
        [self.servicer sendCancel:req complete:complete];
    }
    YYLogDebug(@"[MouseLive-CSService] sendCancel exit");
}

/// 发送挂断连麦请求 -- WS_CHAT_HANGUP
/// @param req WSInviteRequest 结构体
- (void)sendHangup:(WSInviteRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSService] sendHangup entry, req:%@", [req string]);
    if (self.servicer) {
        [self.servicer sendHangup:req complete:complete];
    }
    YYLogDebug(@"[MouseLive-CSService] sendHangup exit");
}

/// 发送自己开麦/闭麦连麦请求 -- WS_CHAT_MIC_ENABLE
/// @param req WSMicOffRequest 结构体
- (void)sendMicEnable:(WSMicOffRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSService] sendMicEnable entry, req.MicEnable:%d", req.MicEnable);
    if (self.servicer) {
        [self.servicer sendMicEnable:req complete:complete];
    }
    YYLogDebug(@"[MouseLive-CSService] sendMicEnable exit");
}

/// 发送进入房间的请求
/// @param req WSRoomRequest 结构体
- (void)sendJoinRoom:(WSRoomRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSService] sendJoinRoom entry, req.Uid:%lld, req.LiveRoomId:%lld, req.ChatRoomId:%lld", req.Uid, req.LiveRoomId, req.ChatRoomId);
    if (self.servicer) {
        [self.servicer sendJoinRoom:req complete:complete];
    }
    YYLogDebug(@"[MouseLive-CSService] sendJoinRoom exit");
}

/// 发送退出房间的请求
/// @param req WSRoomRequest 结构体
- (void)sendLeaveRoom:(WSRoomRequest *)req complete:(SendComplete)complete
{
    YYLogDebug(@"[MouseLive-CSService] sendLeaveRoom entry, req.Uid:%lld, req.LiveRoomId:%lld, req.ChatRoomId:%lld", req.Uid, req.LiveRoomId, req.ChatRoomId);
    if (self.servicer) {
        [self.servicer sendLeaveRoom:req complete:complete];
    }
    YYLogDebug(@"[MouseLive-CSService] sendLeaveRoom exit");
}

#pragma mark -- SYAppStatusManagerDelegate

// return foreground & unlock screen
- (void)SYAppDidBecomeActive:(nonnull SYAppStatusManager *)manager
{
    YYLogDebug(@"[MouseLive-CSService] SYAppDidBecomeActive entry");
    if (self.servicer) {
        [self.servicer handleAppDidBecomeActive];
    }
    YYLogDebug(@"[MouseLive-CSService] SYAppDidBecomeActive exit");
}

// enter backgroud & lock screen
- (void)SYAppWillResignActive:(nonnull SYAppStatusManager *)manager
{
    YYLogDebug(@"[MouseLive-CSService] SYAppWillResignActive entry");
    if (self.servicer) {
        [self.servicer handleAppWillResignActive];
    }
    YYLogDebug(@"[MouseLive-CSService] SYAppWillResignActive exit");
}

// App will terminate
- (void)SYAppWillTerminate:(nonnull SYAppStatusManager *)manager
{
    YYLogDebug(@"[MouseLive-CSService] SYAppWillTerminate entry");
}

// phone call began
- (void)SYAppInterruptionBegan:(nonnull SYAppStatusManager *)manager
{
    YYLogDebug(@"[MouseLive-CSService] SYAppInterruptionBegan entry");
}

// phone call ended
- (void)SYAppInterruptionEnded:(nonnull SYAppStatusManager *)manager
{
    YYLogDebug(@"[MouseLive-CSService] SYAppInterruptionEnded entry");
}

@end
