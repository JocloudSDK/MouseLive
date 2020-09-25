//
//  CCService.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSInviteRequest.h"
#import "WSRoomRequest.h"
#import "WSMicOffRequest.h"

typedef enum : NSUInteger {
    CCS_JOIN_ROOM = 201, // 进入房间 -- LiveBGView
    CCS_JOIN_ROOM_ACK = 202, //  -- 先不处理
    CCS_JOIN_BROADCAST = 203, // 广播用户进入房间
    CCS_LEAVE_BROADCAST = 208, // 广播用户退出房间
    CCS_CHAT_APPLY = 301,  // 接受到连麦请求
    CCS_CHAT_CANCEL = 302, // 取消连麦请求 -- LiveBeInvited -- LiveInvite
    CCS_CHAT_ACCEPT = 303, // 同意连麦请求
    CCS_CHAT_REJECT = 304, // 拒绝请求
    CCS_CHAT_HANGUP = 305, // 挂断连麦请求
    CCS_CHAT_CHATING_BROADCAST = 306, // 广播用户连麦请求，此命令外面不能传
    CCS_CHAT_HANGUP_BROADCAST = 308, // 广播用户d断开连麦请求，此命令外面不能传
    CCS_CHAT_CHATTING = 320, // 用户正在连麦中，返回个数
    CCS_CHAT_MIC_ENABLE = 401, // 闭麦某个用户
    CCS_CHAT_MIC_ENABLE_BROADCAST = 402, // 闭麦某个用户的广播
} CCSRequestType;

NS_ASSUME_NONNULL_BEGIN

@protocol CCServiceDelegate <NSObject>

/// 发送进入房间消息后的接受到服务器该消息收到的返回
/// @param body -- (NSDictionary *)
//- (BOOL)didJoinRoomAck:(id)body;

/// 广播有人进入的消息
/// @param body 有人进入房间列表 -- (NSArray<WSRoomRequest*>*)
- (BOOL)didJoinRoomBroadcast:(id)body;

/// 广播有人退出的消息
/// @param body 有人退出房间列表 -- (NSArray<WSRoomRequest*>*)
- (BOOL)didLeaveRoomBroadcast:(id)body;

/// 房间被销毁
/// @param body -- (NSDictionary *)
- (BOOL)didRoomDestory:(id)body;

/// 接收到请求连麦的消息
/// @param body -- (NSDictionary *)
- (BOOL)didChatApply:(id)body;

/// 接收到取消连麦的消息
/// @param body -- (NSDictionary *)
- (BOOL)didChatCancel:(id)body;

/// 接收到接受连麦的消息
/// @param body -- (NSDictionary *)
- (BOOL)didChatAccept:(id)body;

/// 接收到拒绝连麦的消息
/// @param body -- (NSDictionary *)
- (BOOL)didChatReject:(id)body;

/// 接收到挂断连麦的消息
/// @param body -- (NSDictionary *)
- (BOOL)didChatHangup:(id)body;

/// 接收到有人连麦的广播
/// @param body -- (NSDictionary *)
- (BOOL)didChatingBroadcast:(id)body;

/// 接收到有人挂断连麦的广播
/// @param body -- (NSDictionary *)
- (BOOL)didHangupBroadcast:(id)body;

/// 接收到主播已经连麦满的消息
/// @param body -- (NSDictionary *)
- (BOOL)didChattingLimit:(id)body;

/// 广播有人自己改变麦克风状态的消息
/// @param body -- (NSDictionary *)
- (BOOL)didMicEnableBroadcast:(id)body;

/// 网络已经连接
- (void)didNetConnected;

/// 网络连接中
- (void)didnetConnecting;

/// 网络断开
- (void)didNetClose;

/// 网络出现异常
/// @param error 异常 error
- (void)didNetError:(NSError *)error;

@end

/// communication service 通信服务
@interface CCService : NSObject

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

/// 是否使用 WS，此接口请在使用 send + addObserver 前调用，用户是否使用 WS
/// @param ws YES - 使用
- (void)setUseWS:(BOOL)ws;

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

/// 发送退出房间的请求
/// @param req WSRoomRequest 结构体
- (void)sendLeaveRoom:(WSRoomRequest *)req complete:(SendComplete)complete;

@end

NS_ASSUME_NONNULL_END
