//
//  LiveBeInvited.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#include "LiveBeInvited.h"
#include "../../taskQueue/Task.h"
#include "../WSService.h"
#include "../../../mainui/RoomInfo.h"
#include "../../../mainui/UserInfo.h"

class TaskItem : public Task {
public:
	TaskItem(LiveBeInvited* observer) : _pObserver(observer) {}
	virtual ~TaskItem() {}

	virtual void process() override {}

	virtual void finished() override {
		_pObserver->finish();
	}

protected:
	LiveBeInvited* _pObserver;
};

LiveBeInvited::LiveBeInvited() {
	_oItem._iUid = 0;
	_oItem._iRoomId = 0;
	_pTaskQueue.reset(new TaskQueue());
}

LiveBeInvited::~LiveBeInvited() {
}

bool LiveBeInvited::accept(const QString& uid, QString& roomId) {
	{
		QMutexLocker locker(&_oTaskMutex);
		_iSeq = 0;
	}

	roomId = QString::number(_oItem._iRoomId);

	WSInviteMessage msg;
	msg.MsgId = (int)WSRequestCmd::WS_CHAT_ACCEPT;
	msg.Body.SrcUid = LocalUserInfo::GetInstance()->_iUid;
	msg.Body.SrcRoomId = RoomInfo::GetInstance()->_iRoomId;
	msg.Body.DestUid = _oItem._iUid;
	msg.Body.DestRoomId = _oItem._iRoomId;
	msg.Body.ChatType = (int)RoomType::LIVE;
	auto ret = CCService::GetInstance()->sendAccept(msg.ToJson());

	_oItem._iUid = 0;
	_oItem._iRoomId = 0;
	return ret;
}

bool LiveBeInvited::refuse(const QString& uid) {
	{
		QMutexLocker locker(&_oTaskMutex);
		_iSeq = 0;
	}

	WSInviteMessage msg;
	msg.MsgId = (int)WSRequestCmd::WS_CHAT_REJECT;
	msg.Body.SrcUid = LocalUserInfo::GetInstance()->_iUid;
	msg.Body.SrcRoomId = RoomInfo::GetInstance()->_iRoomId;
	msg.Body.DestUid = _oItem._iUid;
	msg.Body.DestRoomId = _oItem._iRoomId;
	msg.Body.ChatType = (int)RoomType::LIVE;
	auto ret = CCService::GetInstance()->sendReject(msg.ToJson());

	_oItem._iUid = 0;
	_oItem._iRoomId = 0;
	return ret;
}

void LiveBeInvited::complete(const QString& uid) {
	// do nothing
}

void LiveBeInvited::clearBeInvitedQueue() {
	{
		QMutexLocker locker(&_oTaskMutex);
		_pTaskQueue->cancelTask(_iSeq);
		_iSeq = 0;
	}

	WSInviteMessage msg;
	msg.MsgId = (int)WSRequestCmd::WS_CHAT_CANCEL;
	msg.Body.SrcUid = LocalUserInfo::GetInstance()->_iUid;
	msg.Body.SrcRoomId = RoomInfo::GetInstance()->_iRoomId;
	msg.Body.DestUid = _oItem._iUid;
	msg.Body.DestRoomId = _oItem._iRoomId;
	msg.Body.ChatType = (int)RoomType::LIVE;
	CCService::GetInstance()->sendCancel(msg.ToJson());

	_oItem._iRoomId = 0;
	_oItem._iUid = 0;
}

bool LiveBeInvited::handleInvite(const WSInviteMessage& inviteMessage) {
	// 如果接受到邀请
	QMutexLocker locaker(&_oTaskMutex);
	if (_iSeq != 0 || _oItem._iUid != 0) {
		// 发送拒绝连麦
		WSInviteMessage msg;
		msg.MsgId = (int)WSRequestCmd::WS_CHAT_REJECT;
		msg.Body.SrcUid = LocalUserInfo::GetInstance()->_iUid;
		msg.Body.SrcRoomId = RoomInfo::GetInstance()->_iRoomId;
		msg.Body.DestUid = inviteMessage.Body.SrcUid;
		msg.Body.DestRoomId = inviteMessage.Body.SrcRoomId;
		msg.Body.ChatType = (int)RoomType::LIVE;
		return CCService::GetInstance()->sendReject(msg.ToJson());
		return true;
	}

	_oItem._iUid = inviteMessage.Body.SrcUid;
	_oItem._iRoomId = inviteMessage.Body.SrcRoomId;
	_iSeq = _pTaskQueue->addTask(new TaskItem(this));
	return true;
}

bool LiveBeInvited::handleCancel(const WSInviteMessage& inviteMessage) {
	if (_iSeq == 0 || _oItem._iUid != inviteMessage.Body.SrcUid) {
		return false;
	}

	{
		QMutexLocker locaker(&_oTaskMutex);
		_pTaskQueue->cancelTask(_iSeq);
		_iSeq = 0;

		_oItem._iUid = 0;
		_oItem._iRoomId = 0;
	}

	emit onBeInvited(LiveBeInvitedActiontype::LIVE_BE_INVITED_CANCEL, _oItem);
	return true;
}

void LiveBeInvited::finish() {
	emit onBeInvited(LiveBeInvitedActiontype::LIVE_BE_INVITED_APPLY, _oItem);
	_iSeq = 0;
}

bool LiveBeInvited::handleMsg(CCSRequestCmd cmd, const WSInviteMessage& inviteMessage) {
	if (cmd == CCSRequestCmd::CCS_CHAT_APPLY) {
		return handleInvite(inviteMessage);
	}
	else if (cmd == CCSRequestCmd::CCS_CHAT_CANCEL) {
		return handleCancel(inviteMessage);
	}
	return false;
}
