//
//  LiveInvite.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#include "LiveInvite.h"
#include "../WSService.h"
#include "../../../mainui/RoomInfo.h"
#include "../../../mainui/UserInfo.h"

LiveInvite::LiveInvite(QObject* parent) : QObject(parent) {
	_oItem._iUid = 0;
	_oItem._iRoomId = 0;
}

LiveInvite::~LiveInvite() {

}

bool LiveInvite::sendInvote(const QString& uid, const QString& roomId) {
	if (_oItem._iUid != 0) {
		// 正在连麦
		return false;
	}

	{
		QMutexLocker locker(&_oItemMutex);
		_oItem._iUid = uid.toInt();
		_oItem._iRoomId = roomId.toInt();
	}

	WSInviteMessage msg;
	msg.MsgId = (int)WSRequestCmd::WS_CHAT_APPLY;
	msg.Body.SrcUid = LocalUserInfo::GetInstance()->_iUid;
	msg.Body.SrcRoomId = RoomInfo::GetInstance()->_iRoomId;
	msg.Body.DestUid = _oItem._iUid;
	msg.Body.DestRoomId = _oItem._iRoomId;
	msg.Body.ChatType = (int)RoomType::LIVE;
	CCService::GetInstance()->sendApply(msg.ToJson());
	return true;
}

bool LiveInvite::cancel() {
	if (_oItem._iUid == 0) {
		// 正在连麦
		return true;
	}

	WSInviteMessage msg;
	msg.MsgId = (int)WSRequestCmd::WS_CHAT_CANCEL;
	msg.Body.SrcUid = LocalUserInfo::GetInstance()->_iUid;
	msg.Body.SrcRoomId = RoomInfo::GetInstance()->_iRoomId;
	msg.Body.DestUid = _oItem._iUid;
	msg.Body.DestRoomId = _oItem._iRoomId;
	msg.Body.ChatType = (int)RoomType::LIVE;
	CCService::GetInstance()->sendCancel(msg.ToJson());

	QMutexLocker locker(&_oItemMutex);
	_oItem._iUid = 0;
	_oItem._iRoomId = 0;
	return true;
}

bool LiveInvite::handleMsg(CCSRequestCmd cmd, const WSInviteMessage& inviteMessage) {
	if (cmd == CCSRequestCmd::CCS_CHAT_CHATTING) {
		emit onInvite(LiveInviteActionType::LIVE_INVITE_TYPE_RUNNING, _oItem);
		// 重置
		_oItem._iRoomId = 0;
		_oItem._iUid = 0;
		return true;
	}

	auto find = false;
	{
		QMutexLocker locker(&_oItemMutex);
		if (inviteMessage.Body.SrcUid == _oItem._iUid && inviteMessage.Body.SrcRoomId == _oItem._iRoomId
			&& inviteMessage.Body.DestUid == LocalUserInfo::GetInstance()->_iUid
			&& inviteMessage.Body.DestRoomId == RoomInfo::GetInstance()->_iRoomId) {
			find = true;
		}
	}

	auto c = LiveInviteActionType::LIVE_INVITE_TYPE_ACCEPT;
	switch (cmd) {
	case CCSRequestCmd::CCS_CHAT_ACCEPT:
		c = LiveInviteActionType::LIVE_INVITE_TYPE_ACCEPT;
		break;
	case CCSRequestCmd::CCS_CHAT_REJECT:
		c = LiveInviteActionType::LIVE_INVITE_TYPE_REFUSE;
		break;
	case CCSRequestCmd::CCS_CHAT_CANCEL:
		c = LiveInviteActionType::LIVE_INVITE_TYPE_RUNNING;
		break;
	default:
		break;
	}

	if (find) {
		emit onInvite(c, _oItem);

		// 重置
		_oItem._iRoomId = 0;
		_oItem._iUid = 0;
	}

	return false;
}
