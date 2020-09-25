#pragma once

#include <QString>

class LiveManagerObserver {
public:
	
	/// @brief 用户加入
	/// call back when user join
	/// @param uid 用户ID
	virtual void onUserJoin(const QString& uid) = 0;

	/// @brief 用户离开
	/// call back when user leave
	/// @param uid 用户ID
	virtual void onUserLeave(const QString& uid) = 0;

	/// @brief 收到连麦邀请（单播）
	/// call back when receive invite message
	/// @param uid 用户ID
	/// @param roomId 房间ID
	virtual void onBeInvited(const QString& uid, const QString& roomId) = 0;

	/// @brief 收到连麦取消（单播）
	/// call back when receive invite cancel message
	virtual void onInviteCancel(const QString& uid, const QString& roomId) = 0;

	/// @brief 连麦请求被接受（单播）
	/// call back when invite request be accepted
	virtual void onInviteAccept(const QString& uid, const QString& roomId) = 0;

	/// @brief 连麦请求被拒绝（单播）
	/// call back when invite request be refused
	virtual void onInviteRefuse(const QString& uid, const QString& roomId) = 0;

	/// @brief 连麦请求超时（单播）
	/// call back when invite request timeout
	virtual void onInviteTimeout(const QString& uid, const QString& roomId) = 0;

	/// @brief 正在连麦（单播）
	/// call back when host is connecting with other user
	virtual void onInviteRunning(const QString& uid, const QString& roomId) = 0;

	/// @brief 收到挂断连麦请求（单播）
	/// call back when receive hung up message
	virtual void onReceiveHungupRequest(const QString& uid, const QString& roomId) = 0;

	/// @brief 主播正在和某人连麦（广播）
	/// call back when anchor begin connection with one user
	virtual void onAnchorConnected(const QString& uid, const QString& roomId) = 0;

	/// @brief 主播断开了与某人的连麦（广播）
	/// call back when anchor end connection with one user
	virtual void onAnchorDisconnected(const QString& uid, const QString& roomId) = 0;

	/// @brief 发送消息失败
	virtual void onSendRequestFail(const QString& error) = 0;

	/// @brief 收到点对点消息
	/// call back when receive p to p message
	virtual void onReceivedMessage(const QString& uid, const QString& message) = 0;

	/// @brief 收到广播消息
	/// call back when receive room message
	virtual void onReceivedRoomMessage(const QString& uid, const QString& message) = 0;

	/// @brief 用户被踢
	/// call back when one user be kicked off
	virtual void onUserBeKicked(const QString& uid) = 0;

	/// @brief 自己被踢
	/// call back when self be kicked off
	virtual void onSelfBeKicked() = 0;

	/// @brief 用户麦克风状态被某人改变(WS)
	/// call back when user's mic status changed by other
	virtual void onUserMicStatusChanged(const QString& localUid, const QString& otherUid, bool state) = 0;

	/// @brief 房间mic状态改变
	/// call back when room mic status changed
	virtual void onRoomMicStatusChanged(bool micOn) = 0;

	/// @brief 用户mute状态改变
	/// call back when user's mute status changed
	virtual void onUserMuteStatusChanged(const QString& uid, bool muted) = 0;

	/// @brief 房间mute状态改变
	/// call back when room mute status changed
	virtual void onRoomMuteStatusChanged(bool muted) = 0;

	/// @brief 用户权限改变
	/// call back when user's role changed
	virtual void onUserRoleChanged(const QString& uid, bool hasRole) = 0;

	virtual void onNetConnected() = 0;

	virtual void onNetClosed() = 0;

	virtual void onNetConnecting() = 0;

	virtual void onNetError(const QString& error) = 0;
};
