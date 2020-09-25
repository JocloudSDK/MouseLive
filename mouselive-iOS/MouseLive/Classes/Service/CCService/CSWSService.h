//
//  CSWSService.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/14.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface CSWSService : NSObject <CSServiceProtocol>

/// 单实例
+ (instancetype)sharedInstance;

/// 加入房间
- (void)joinRoom;

/// 离开房间
- (void)leaveRoom;

/// 增加观察者
/// @param observer id<CCServiceDelegate>
- (void)addObserver:(id<CCServiceDelegate>)observer;

/// 移除观察者
/// @param observer id<CCServiceDelegate>
- (void)removeObserver:(id<CCServiceDelegate>)observer;

/// 发送请求连麦请求 -- WS_CHAT_APPLY
/// @param req WSInviteRequest 结构体
- (void)sendApply:(WSInviteRequest *)req complete:(SendComplete)complete;

/// 发送接受连麦请求 -- WS_CHAT_ACCEPT
/// @param req WSInviteRequest 结构体
- (void)sendAccept:(WSInviteRequest *)req complete:(SendComplete)complete;

/// 发送拒绝连麦请求 -- WS_CHAT_REJECT
/// @param req WSInviteRequest 结构体
- (void)sendReject:(WSInviteRequest *)req complete:(SendComplete)complete;

/// 发送取消连麦请求 -- WS_CHAT_CANCEL
/// @param req WSInviteRequest 结构体
- (void)sendCancel:(WSInviteRequest *)req complete:(SendComplete)complete;

/// 发送挂断连麦请求 -- WS_CHAT_HANGUP
/// @param req WSInviteRequest 结构体
- (void)sendHangup:(WSInviteRequest *)req complete:(SendComplete)complete;

/// 发送自己开麦/闭麦连麦请求 -- WS_CHAT_MIC_ENABLE
/// @param req WSMicOffRequest 结构体
- (void)sendMicEnable:(WSMicOffRequest *)req complete:(SendComplete)complete;

/// 发送进入房间的请求
/// @param req WSRoomRequest 结构体
- (void)sendJoinRoom:(WSRoomRequest *)req complete:(SendComplete)complete;

/// 切到后台
- (void)handleAppDidBecomeActive;

/// 切到前台
- (void)handleAppWillResignActive;

/// 杀进程
- (void)handleAppWillTerminate;

/// 接听电话
- (void)handleAppInterruptionBegan;

/// 挂断电话
- (void)handleAppInterruptionEnded;

@end

NS_ASSUME_NONNULL_END
