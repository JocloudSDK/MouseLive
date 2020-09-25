#pragma once

#include "LiveManagerObserver.h"
#include "../utils/Singleton.h"
#include "CCService.h"
#include "Invite/LiveBeInvited.h"
#include "Invite/LiveInvite.h"
#include <QObject>

class LiveManager : public QObject,public Singleton<LiveManager>, public CCServiceObserver  {
	Q_OBJECT
protected:
	friend class Singleton<LiveManager>;
	LiveManager(QObject* parent = nullptr);
	~LiveManager();

public:

	/// 发送进入房间消息后的接受到服务器该消息收到的返回
	virtual bool onJoinRoomAck(const std::string& body);

	/// 广播有人进入的消息
	/// @param body 有人进入房间列表 -- (NSArray<WSRoomRequest*>*)
	virtual bool onJoinRoomBroadcast(const std::string& body);

	/// 广播有人退出的消息
	/// @param body 有人退出房间列表 -- (NSArray<WSRoomRequest*>*)
	virtual bool onLeaveRoomBroadcast(const std::string& body);

	/// 房间被销毁
	/// @param body -- (NSDictionary *)
	virtual bool onRoomDestory(const std::string& body);

	/// 接收到请求连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatApply(const std::string& body);

	/// 接收到取消连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatCancel(const std::string& body);

	/// 接收到接受连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatAccept(const std::string& body);

	/// 接收到拒绝连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatReject(const std::string& body);

	/// 接收到挂断连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatHangup(const std::string& body);

	/// 接收到有人连麦的广播
	/// @param body -- (NSDictionary *)
	virtual bool onChatingBroadcast(const std::string& body);

	/// 接收到有人挂断连麦的广播
	/// @param body -- (NSDictionary *)
	virtual bool onHangupBroadcast(const std::string& body);

	/// 接收到主播已经连麦满的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChattingLimit(const std::string& body);

	/// 广播有人自己改变麦克风状态的消息
	/// @param body -- (NSDictionary *)
	virtual bool onMicEnableBroadcast(const std::string& body);

	/// 网络已经连接
	virtual void onNetConnected();

	/// 网络连接中
	virtual void onNetConnecting();

	/// 网络断开
	virtual void onNetClose();

	/// 网络出现异常
	/// @param error 异常 error
	virtual void onNetError(const std::string& error);

	/// @brief 申请连麦
	/// apply connection to user
	/// @param uid 用户ID
	/// @param roomId 房间ID
	bool applyConnectToUser(const QString& uid, const QString& roomId);

	/// @brief 取消连麦
	bool cancelConnectToUser();

	/// @brief 接受连麦申请
	/// accept connection request
	/// @param uid 用户ID
	bool acceptConnectWithUser(const QString& uid);

	/// @brief 拒绝连麦
	/// refuse connnection request
	/// @param uid 用户ID
	bool refuseConnectWithUser(const QString& uid);

	/// @brief 清空所以未处理连麦请求，当达到连麦上线的时候主动调用
	/// clear connection request queue
	void clearBeInvitedQueue();

	/// @brief 挂断连麦
	/// hungup connection
	/// @param uid 用户ID
	/// @param roomId 房间ID
	bool hungupWithUser(const QString& uid, const QString& roomId);

	void joinWSRoom();

	void leaveWSRoom();

signals:

	/// @brief 用户加入
	/// call back when user join
	/// @param uid 用户ID
	void onUserJoin(const QString& uid);

	/// @brief 用户离开
	/// call back when user leave
	/// @param uid 用户ID
	void onUserLeave(const QString& uid);

	/// @brief 收到连麦邀请（单播）
	/// call back when receive invite message
	/// @param uid 用户ID
	/// @param roomId 房间ID
	void onBeInvited(const QString& uid, const QString& roomId);

	/// @brief 收到连麦取消（单播）
	/// call back when receive invite cancel message
	void onInviteCancel(const QString& uid, const QString& roomId);

	/// @brief 连麦请求被接受（单播）
	/// call back when invite request be accepted
	void onInviteAccept(const QString& uid, const QString& roomId);

	/// @brief 连麦请求被拒绝（单播）
	/// call back when invite request be refused
	void onInviteRefuse(const QString& uid, const QString& roomId);

	/// @brief 连麦请求超时（单播）
	/// call back when invite request timeout
	void onInviteTimeout(const QString& uid, const QString& roomId);

	/// @brief 正在连麦（单播）
	/// call back when host is connecting with other user
	void onInviteRunning(const QString& uid, const QString& roomId);

	/// @brief 收到挂断连麦请求（单播）
	/// call back when receive hung up message
	void onReceiveHungupRequest(const QString& uid, const QString& roomId);

	/// @brief 主播正在和某人连麦（广播）
	/// call back when anchor begin connection with one user
	void onAnchorConnected(const QString& uid, const QString& roomId);

	/// @brief 主播断开了与某人的连麦（广播）
	/// call back when anchor end connection with one user
	void onAnchorDisconnected(const QString& uid, const QString& roomId);

	/// @brief 发送消息失败
	void onSendRequestFail(const QString& error);

	/// @brief 收到点对点消息
	/// call back when receive p to p message
	void onReceivedMessage(const QString& uid, const QString& message);

	/// @brief 收到广播消息
	/// call back when receive room message
	void onReceivedRoomMessage(const QString& uid, const QString& message);

	/// @brief 用户被踢
	/// call back when one user be kicked off
	void onUserBeKicked(const QString& uid);

	/// @brief 自己被踢
	/// call back when self be kicked off
	void onSelfBeKicked();

	/// @brief 用户麦克风状态被某人改变(WS)
	/// call back when user's mic status changed by other
	void onUserMicStatusChanged(const QString& localUid, const QString& otherUid, bool state);

	/// @brief 房间mic状态改变
	/// call back when room mic status changed
	void onRoomMicStatusChanged(bool micOn);

	/// @brief 用户mute状态改变
	/// call back when user's mute status changed
	void onUserMuteStatusChanged(const QString& uid, bool muted);

	/// @brief 房间mute状态改变
	/// call back when room mute status changed
	void onRoomMuteStatusChanged(bool muted);

	/// @brief 用户权限改变
	/// call back when user's role changed
	void onUserRoleChanged(const QString& uid, bool hasRole);

	void onNetConnectedJ();

	void onNetClosedJ();

	void onNetConnectingJ();

	void onNetErrorJ(const QString& error);

private:
	void resetAll();

public slots:
	void onBeInvited(LiveBeInvitedActiontype cmd, const LiveInviteItem& item);
	void onInvite(LiveInviteActionType cmd, const LiveInviteItem& item);

protected:
	bool LiveManager::handleJoinBroadcast(const WSRoomMessage& message);
	bool LiveManager::handleLeaveBroadcast(const WSRoomMessage& message);
	bool LiveManager::handleHangup(const WSInviteMessage& message);
	bool LiveManager::handleChatingBroadcast(const WSInviteMessage& message);
	bool LiveManager::handleHangupBroatcast(const WSInviteMessage& message);
	bool LiveManager::handleMicOffBroadcast(const WSInviteMessage& message);

private:
	std::shared_ptr<LiveInvite> _pLiveInvite;
	std::shared_ptr<LiveBeInvited> _pLiveBeInvited;
};
