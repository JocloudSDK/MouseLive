//
//  LiveManagerEvent.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/21.
//  Copyright © 2020 sy. All rights reserved.
//

#ifndef LiveManagerEvent_h
#define LiveManagerEvent_h

#import <ThunderEngine.h>

@class LiveManager;
@class LiveRoomInfoModel;

@protocol LiveManagerSignalDelegate <NSObject>
@optional
/// @brief 用户加入
/// call back when user join
/// @param uid 用户ID
- (void)liveManager:(LiveManager *_Nonnull)manager didUserJoin:(NSString *_Nonnull)uid;

/// @brief 用户离开
/// call back when user leave
/// @param uid 用户ID
- (void)liveManager:(LiveManager *_Nonnull)manager didUserLeave:(NSString *_Nonnull)uid;

/// @brief 收到连麦邀请（单播）
/// call back when receive invite message
/// @param uid 用户ID
/// @param roomId 房间ID
- (void)liveManager:(LiveManager *_Nonnull)manager didBeInvitedBy:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

/// @brief 收到连麦取消（单播）
/// call back when receive invite cancel message
- (void)liveManager:(LiveManager *_Nonnull)manager didInviteCancelBy:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

/// @brief 连麦请求被接受（单播）
/// call back when invite request be accepted
- (void)liveManager:(LiveManager *_Nonnull)manager didInviteAcceptBy:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

/// @brief 连麦请求被拒绝（单播）
/// call back when invite request be refused
- (void)liveManager:(LiveManager *_Nonnull)manager didInviteRefuseBy:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

/// @brief 连麦请求超时（单播）
/// call back when invite request timeout
- (void)liveManager:(LiveManager *_Nonnull)manager didInviteTimeoutBy:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

/// @brief 正在连麦（单播）
/// call back when host is connecting with other user
- (void)liveManager:(LiveManager *_Nonnull)manager didInviteRunningBy:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

/// @brief 收到挂断连麦请求（单播）
/// call back when receive hung up message
- (void)liveManager:(LiveManager *_Nonnull)manager didReceiveHungupRequestFrom:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

/// @brief 主播正在和某人连麦（广播）
/// call back when anchor begin connection with one user
- (void)liveManager:(LiveManager *_Nonnull)manager anchorConnectedWith:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

/// @brief 主播断开了与某人的连麦（广播）
/// call back when anchor end connection with one user
- (void)liveManager:(LiveManager *_Nonnull)manager anchorDisconnectedWith:(NSString *_Nonnull)uid roomId:(NSString *_Nonnull)roomId;

#pragma mark - WS
/// @brief 发送消息失败
- (void)liveManager:(LiveManager *_Nonnull)manager didSendRequestFail:(NSError*_Nullable)error;

#pragma mark - Hummer
/// @brief 收到点对点消息
/// call back when receive p to p message
- (void)liveManager:(LiveManager *_Nonnull)manager didReceivedMessageFrom:(NSString *_Nonnull)uid message:(NSString *_Nonnull)message;

/// @brief 收到广播消息
/// call back when receive room message
- (void)liveManager:(LiveManager *_Nonnull)manager didReceivedRoomMessageFrom:(NSString *_Nonnull)uid message:(NSString *_Nonnull)message;

/// @brief 用户被踢
/// call back when one user be kicked off
- (void)liveManager:(LiveManager *_Nonnull)manager didUserBeKicked:(NSString *_Nonnull)uid;

/// @brief 自己被踢
/// call back when self be kicked off
- (void)liveManagerDidSelfBeKicked:(LiveManager *_Nonnull)manager;

/// @brief 用户麦克风状态被某人改变(WS)
/// call back when user's mic status changed by other
- (void)liveManager:(LiveManager *_Nonnull)manager didUserMicStatusChanged:(NSString *_Nonnull)uid byOther:(NSString *_Nonnull)otherUid status:(BOOL)status;

/// @brief 房间mic状态改变
/// call back when room mic status changed
- (void)liveManager:(LiveManager *_Nonnull)manager didRoomMicStatusChanged:(BOOL)micOn;

/// @brief 用户mute状态改变
/// call back when user's mute status changed
- (void)liveManager:(LiveManager *_Nonnull)manager didUser:(NSString *_Nonnull)uid muteStatusChanged:(BOOL)muted;

/// @brief 房间mute状态改变
/// call back when room mute status changed
- (void)liveManager:(LiveManager *_Nonnull)manager didRoomMuteStatusChanged:(BOOL)muted;

/// @brief 用户权限改变
/// call back when user's role changed
- (void)liveManager:(LiveManager *_Nonnull)manager didUser:(NSString *_Nonnull)uid roleChanged:(BOOL)hasRole;

/// @brief 获取mute用户列表成功
/// call back after fetch mute users success
- (void)liveManager:(LiveManager *_Nonnull)manager fetchMuteUsersSuccess:(NSArray<NSString*> *_Nullable)fetchUsers muteUsers:(NSArray<NSString*> *_Nullable)muteUsers;

/// @brief 获取mute用户列表失败
/// call back after fetch mute users failed
- (void)liveManager:(LiveManager *_Nonnull)manager fetchMuteUsersFailed:(NSError *_Nullable)error;

/// @brief 获取管理员列表成功
/// call back after fetch administrators success
- (void)liveManager:(LiveManager *_Nonnull)manager fetchAdminsSuccess:(NSArray<NSString*> *_Nullable)fetchUsers admins:(NSArray<NSString*> *_Nullable)admins;

/// @brief 获取管理员列表失败
/// call back after fetch adminstators failed
- (void)liveManager:(LiveManager *_Nonnull)manager fetchAdminsFailed:(NSError *_Nullable)error;

@end

@protocol LiveManagerDelegate <NSObject>
@optional
/// @brief 创建服务器房间成功
/// call back when create room success(business server)
- (void)liveManager:(LiveManager *_Nonnull)manager createRoomSuccess:(LiveRoomInfoModel *_Nonnull)roomInfo;

/// @brief 创建服务器房间失败
/// call back when create room failed(business server)
- (void)liveManager:(LiveManager *_Nonnull)manager createRoomFailed:(NSError *_Nullable)error;

/// @brief 创建Hummer房间成功
/// call back when create chat room success(Hummer)
- (void)liveManager:(LiveManager *_Nonnull)manager createChatRoomSuccess:(NSString *_Nonnull)ChatId;

/// @brief 创建Hummer房间失败
/// call back when create chat room failed(Hummer)
- (void)liveManager:(LiveManager *_Nonnull)manager createChatRoomFailed:(NSError *_Nullable)error;

/// @brief 加入Hummer房间成功
/// call back when join chat room success
- (void)liveManager:(LiveManager *_Nonnull)manager joinChatRoomSuccess:(NSString *_Nonnull)ChatId;

/// @brief 加入Hummer房间失败
/// call back when join chat room failed
- (void)liveManager:(LiveManager *_Nonnull)manager joinChatRoomFailed:(NSError *_Nullable)error;

/// @brief 获取房间列表成功
/// call back when get room list success
- (void)liveManager:(LiveManager *_Nonnull)manager getRoomList:(NSArray<LiveRoomInfoModel*> * _Nullable)roomList type:(LiveType)type;

/// @brief 获取房间列表失败
/// call back when get room list failed
- (void)liveManager:(LiveManager *_Nonnull)manager getRoomListFailed:(NSError *_Nonnull)error;

/// @brief 获取房间信息成功
/// call back when get room info success
- (void)liveManager:(LiveManager *_Nonnull)manager getRoomInfoSuccess:(LiveRoomInfoModel *_Nonnull)roomInfo userList:(NSArray<LiveUserModel*> *_Nullable)userList;

/// @brief 获取房间信息失败
/// call back when get room info failed
- (void)liveManager:(LiveManager *_Nonnull)manager getRoomInfoFailed:(NSError *_Nullable)error;

/// @brief 获取用户信息成功
/// call back when get user info success
- (void)liveManager:(LiveManager *_Nonnull)manager getUserInfoSuccess:(LiveUserModel *_Nonnull)userInfo;

/// @brief 获取用户信息失败
/// call back when get user info failed
- (void)liveManager:(LiveManager *_Nonnull)manager getUserInfoFailed:(NSError *_Nullable)error;

- (void)liveManagerDidNetConnected:(LiveManager *_Nonnull)manager;

- (void)liveManagerDidNetClosed:(LiveManager *_Nonnull)manager;

- (void)liveManagerNetConnecting:(LiveManager *_Nonnull)manager;

- (void)liveManager:(LiveManager *_Nonnull)manager didNetError:(NSError *_Nullable)error;

@end

#endif /* LiveManagerEvent_h */
