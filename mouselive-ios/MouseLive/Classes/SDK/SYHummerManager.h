//
//  SYHummerManager.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <HMRCore/HMRCore.h>
#import <HMRChatRoom/HMRChatRoom.h>
#import "SYUser.h"

typedef void (^SYFetchMembersCompletionHandler) (NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error);
typedef void (^SYFetchAudienceMembersCompletionHandler) (NSArray<SYUser *> * _Nullable members, NSError * _Nullable error);
typedef void (^SYCharRoomCompletionHandler)(NSString * _Nullable roomId, NSError * _Nullable error);
typedef void (^SYCompletionHandler)(NSError * _Nullable error);

typedef enum : NSUInteger {
    HUMMER_ERROR_MUTED = 6666,  // 已经被禁言
    HUMMER_ERROR_NO_USER,  // 没有用户
    HUMMER_ERROR_KICK, // 踢出房间失败
    HUMMER_ERROR_MUTE, // 禁言或者解禁失败
    HUMMER_ERROR_MIC_OFF, // 开麦/闭麦
    HUMMER_ERROR_NO_PERMISSION, // 没有权限
    HUMMER_ERROR_ROLE, // 添加/撤销管理员失败
    HUMMER_ERROR_OPEN_FAILED, // 登陆失败
} HummerManagerError;

NS_ASSUME_NONNULL_BEGIN

@protocol SYHummerManagerObserver <NSObject>

/// 进入房间
/// @param user 进入房间的用户列表
- (void)didJoinWithArray:(NSArray<SYUser *> *)user;

/// 退出房间
/// @param user 退出房间的用户列表
- (void)didLeaveWithArray:(NSArray<SYUser *> *)user;

/// 接受某人给自己的发送的信令
/// @param uid 发送用户 uid
/// @param message 发送的信令
- (void)didReceivedSelfSignalMessageFrom:(NSString *)uid message:(NSString *)message;

/// 接受某人发送的信令 -- 没有实现
/// @param uid 发送用户 uid
/// @param message 发送的信令
- (void)didReceivedSignalMessageFrom:(NSString *)uid message:(NSString *)message;

/// 接受某人发给自己的文本消息 -- 没有实现
/// @param uid 发送用户 uid
/// @param message 发送的文本
- (void)didReceivedSelfBroadcastFrom:(NSString *)uid message:(NSString *)message;

/// 接受某人发送的文本消息
/// @param uid 发送用户 uid
/// @param message 发送的文本
- (void)didReceivedBroadcastFrom:(NSString *)uid message:(NSString *)message;

/// 踢人消息
/// @param user 被踢出的人员列表
- (void)didKickedWithArray:(NSArray<SYUser *> *)user;

/// 自己被踢出
- (void)didKickedSelf;

/// 获取 token 失败
- (void)didTokenFaield;

/// 人员个数有修改
/// @param count 返回当前的人员个数
- (void)didChangeMemberCount:(NSInteger)count;

/// 禁言/解禁的消息， 通过 isMute 判断自己是否被禁言 -- 这样判断自己是否合适？？？
/// @param user 被禁言/解禁的人员列表
/// @param muted yes - 禁言; no - 解禁
- (void)didMutedWithArray:(NSArray<SYUser *> *)user muted:(BOOL)muted;

/// 全体禁言/解禁
/// @param muted YES - 禁言; NO - 解禁
- (void)didAllMuted:(BOOL)muted;

/// 全体禁麦/开麦
/// @param micOff YES - 禁麦; NO - 开麦
- (void)didAllMicOff:(BOOL)micOff;

/// 提升管理员，通过判断 isAdmin 判断是否是自己管理员 -- 这样判断自己是否合适？？？
/// @param uid 被提升管理员的 uid
- (void)didAddRoleWithUid:(NSString *)uid;

/// 撤销管理员，通过判断 isAdmin 判断是否是自己管理员 -- 这样判断自己是否合适？？？
/// @param uid 被撤销管理员的 uid
- (void)didRemoveRoleWithUid:(NSString *)uid;

/// 房间已经被销毁
- (void)didDismissByOperator;

/// 网络已经断开
- (void)didNetDisconnect;

@end

@interface SYHummerManager : NSObject

@property (nonatomic, copy, readonly) NSString *uid;  // 用户Uid
@property (nonatomic, assign, readonly) BOOL isLoggedIn;  // 是否已登录
@property (nonatomic, assign, readonly) BOOL isMuted; // 用户是否被禁言
@property (nonatomic, assign, readonly) BOOL isAdmin; // 是否是管理员
@property (nonatomic, assign, readonly) BOOL isOwner; // 房主
@property (nonatomic, assign, readonly) BOOL isMicOff; // 用户是否禁麦
@property (nonatomic, assign, readonly) BOOL isAllMuted;  // 用于内部发送请求
@property (nonatomic, assign, readonly) BOOL isAllMicOff;  // 用于内部发送请求

/// 单实例，初始化 SDK
+ (instancetype)sharedManager;

/// 增加观察者
/// @param Observer 观察者
- (void)addHummerObserver:(id<SYHummerManagerObserver>)Observer;

/// 移除观察者
/// @param Observer 观察者
- (void)removeHummerObserver:(id<SYHummerManagerObserver>)Observer;

/// 登陆
/// @param uid 登陆用户 uid
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)loginWithUid:(NSString *)uid completionHandler:(SYCompletionHandler)completionHandler;

/// 退出
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)logoutWithCompletionHandler:(SYCompletionHandler)completionHandler;

/// 创建聊天室，如果是主播
/// @param completionHandler 处理回调，返回 roomid -- SYCharRoomCompletionHandler
- (void)createChatRoomWithCompletionHandler:(SYCharRoomCompletionHandler)completionHandler;

/// 加入聊天室
/// @param roomId 房间 id
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)joinChatRoomWithRoomId:(NSString *)roomId completionHandler:(SYCompletionHandler)completionHandler;

/// 退出聊天室
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)leaveChatRoomWithCompletionHandler:(SYCompletionHandler)completionHandler;

/// 获取带有禁言和管理员状态的成员列表
/// @param completionHandler 处理回调，返回 带有禁言和管理员状态的成员列表 -- SYFetchMembersCompletionHandler
- (void)fetchMembersWithCompletionHandler:(SYFetchMembersCompletionHandler)completionHandler;

/// 发送给某人信令
/// @param receiverUid 要发送给某人 uid
/// @param message 发送的信令
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)sendSignalToTarget:(NSString *)receiverUid message:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler;

/// 发送给房间内所有人信令
/// @param message 发送的信令
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)sendSignalToAll:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler;

/// 发送给某人消息
/// @param receiverUid 要发送给某人 uid
/// @param message 发送的消息
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)sendMessageToTarget:(NSString *)receiverUid message:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler;

/// 发送给房间内所有人消息
/// @param message 发送的消息
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)sendMessageToAll:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler;

// 要去除掉
// 发送单播消息 //  ----
- (void)sendSignalMessage:(NSString *)message receiver:(NSString *)receiverUid completionHandler:(SYCompletionHandler)completionHandler;

// 要去除掉
// 发送广播消息
- (void)sendBroadcastMessage:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler;

/// 踢人
/// @param uid 被踢用户 uid
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)sendKickWithUid:(NSString *)uid completionHandler:(SYCompletionHandler)completionHandler;

/// 单人禁言/解禁
/// @param uid 被操作用户 uid
/// @param muted yes - 禁言; no - 解禁
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)sendMutedWithUid:(NSString *)uid muted:(BOOL)muted completionHandler:(SYCompletionHandler)completionHandler;

/// 全体禁言/解禁
/// @param muted yes - 禁言; no - 解禁
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)sendAllMutedWithMuted:(BOOL)muted completionHandler:(SYCompletionHandler)completionHandler;

/// 提升管理员
/// @param uid 被提升管理员的用户 uid
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)addAdminWithUid:(NSString *)uid completionHandler:(SYCompletionHandler)completionHandler;

// 撤销管理员
/// 撤销管理员
/// @param uid 被撤销管理员的用户 uid
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)removeAdminWithUid:(NSString *)uid completionHandler:(SYCompletionHandler)completionHandler;

/// 全体禁麦/开麦
/// @param off yes - 禁麦; no - 开麦
/// @param completionHandler 处理回调 -- SYCompletionHandler
- (void)sendAllMicOffWithOff:(BOOL)off completionHandler:(SYCompletionHandler)completionHandler;

- (void)createChatRoomSuccess:(StrCompletion)success fail:(ErrorComplete)fail;

- (void)fetchMutedUsers:(SYFetchMembersCompletionHandler)completionHandler;

- (void)fetchRoleMember:(SYFetchMembersCompletionHandler)completionHandler;

- (void)fetchRoomInfo:(SYCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
