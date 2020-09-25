//
//  WSService.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    WS_JOIN_ROOM = 201, // 进入房间 -- LiveBGView
    //WS_JOIN_ROOM_ACK = 202, //  -- 先不处理 -- WSService
    WS_JOIN_BROADCAST = 203, // 广播用户进入房间，此命令外面不能传  -- 先不处理 -- WSService
    WS_LEAVE_ROOM = 205, // 退出房间
    WS_LEAVE_BROADCAST = 208, // 广播用户退出房间，此命令外面不能传  -- 先不处理 -- WSService
    WS_CHAT_APPLY = 301,  // 接受到连麦请求
    WS_CHAT_CANCEL = 302, // 取消连麦请求 -- LiveBeInvited -- LiveInvite
    WS_CHAT_ACCEPT = 303, // 同意连麦请求
    WS_CHAT_REJECT = 304, // 拒绝请求
    WS_CHAT_HANGUP = 305, // 挂断连麦请求  -- LiveBGView
    WS_CHAT_CHATING_BROADCAST = 306, // 广播用户连麦请求，此命令外面不能传
    WS_CHAT_HANGUP_BROADCAST = 308, // 广播用户d断开连麦请求，此命令外面不能传
    WS_CHAT_CHATTING = 320, // 用户正在连麦中，返回个数
    WS_CHAT_MIC_ENABLE = 401, // 闭麦某个用户
    WS_CHAT_MIC_ENABLE_BROADCAST = 402, // 闭麦某个用户的广播
    WS_HEARTBEAT = 500, // 心跳请求  -- WSService
    WS_HEARTBEAT_ACK = 501, // 心跳请求回调 -- WSService
    WS_ERROR = 22222, // WS 返回的错误，先统一以这个处理
} WSRequestType;

typedef enum : NSUInteger {
    WS_DISCONNECT, // 非自己主动断开
    WS_DISCONNECT_SELF,  // 自己主动断开
    WS_CONNECTED, // 已经连接
    WS_CONNECTING, // 正在连接中，比如 WS 重新连接
} WSServiceState;

NS_ASSUME_NONNULL_BEGIN

@protocol WSServiceDelegate <NSObject>

// 如果已经获取到数据，不想往下传，就返回 YES

/// 接收到 WS 数据 回调
/// @param cmd 命令 WSRequestType
/// @param body 消息体
- (BOOL)websocketRecvMsgWithCmd:(NSNumber *)cmd body:(NSDictionary *)body;

/// WS 网络错误 回调
/// @param err 错误码
- (void)websocketDidNetError:(int)err;

/// WS 已经连接成功 回调
- (void)webSocketDidOpen;

/// WS 关闭 回调
- (void)webSocketDidClose;

/// WS 连接中，重连状态
- (void)webSocketDidConnecting;

@end

@interface WSService : NSObject

@property (nonatomic, assign, readonly) WSServiceState state;

+ (instancetype)sharedInstance;

/// WS 连接
- (void)connect;

/// 添加观察者
/// @param delegate 观察者
- (void)addObserver:(id<WSServiceDelegate>) delegate;

/// 移除观察者
/// @param delegate 观察者
- (void)removeObserver:(id<WSServiceDelegate>) delegate;

/// WS 关闭连接
- (void)close;

/// 发送消息
/// @param type 命令
/// @param object 发送的消息 -- NSDictionary*
- (void)sendWithParam:(WSRequestType)type object:(id)object;

/// 切到后台
- (void)handleAppDidBecomeActive;

/// 切到前台
- (void)handleAppWillResignActive;

@end

NS_ASSUME_NONNULL_END
