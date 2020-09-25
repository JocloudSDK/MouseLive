#pragma once

#include <QString>
#include "LiveInviteItem.h"
#include "../WSModel.h"
#include "../CCService.h"
#include <QMutex>
#include <QObject>
#include "../../taskQueue/TaskQueue.h"
#include <memory>

enum class LiveBeInvitedActiontype {
	LIVE_BE_INVITED_CANCEL,
	LIVE_BE_INVITED_APPLY,
};

class LiveBeInvited : public QObject {
	Q_OBJECT
public:
	LiveBeInvited();
	~LiveBeInvited();

	/// 接受连麦请求 -- 返回连麦用户的 roomid
	/// @param uid 连麦用户的 uid
	bool accept(const QString& uid, QString& roomId);

	/// 拒绝连麦请求
	/// @param uid 连麦用户的 uid
	bool refuse(const QString& uid);

	/// 完成连麦请求
	/// @param uid 连麦用户的 uid
	void complete(const QString& uid);

	void clearBeInvitedQueue();

	/// 处理接到的请求
	/// @param cmd 请求 cmd
	/// @param body 请求内容
	bool handleMsg(CCSRequestCmd cmd, const WSInviteMessage& inviteMessage);

	void finish();

signals:
	void onBeInvited(LiveBeInvitedActiontype cmd, const LiveInviteItem& item);

private:
	bool handleInvite(const WSInviteMessage& inviteMessage);
	bool handleCancel(const WSInviteMessage& inviteMessage);

private:
	QMutex _oTaskMutex;
	std::shared_ptr<TaskQueue> _pTaskQueue;
	LiveInviteItem _oItem;
	int64_t _iSeq = 0;
};
