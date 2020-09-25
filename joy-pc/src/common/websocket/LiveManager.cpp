#include "LiveManager.h"
#include "../../mainui/RoomInfo.h"
#include "../../mainui/UserInfo.h"
#include "WSModel.h"
#include "WSService.h"
#include "../utils/String.h"

LiveManager::LiveManager(QObject* parent) : QObject(parent) {
	CCService::GetInstance()->addObserver(this);

}

LiveManager::~LiveManager() {

}

void LiveManager::onBeInvited(LiveBeInvitedActiontype cmd, const LiveInviteItem& item) {
	switch (cmd) {
	case LiveBeInvitedActiontype::LIVE_BE_INVITED_APPLY:
		emit onBeInvited(QString::number(item._iUid), QString::number(item._iRoomId));
		break;
	case LiveBeInvitedActiontype::LIVE_BE_INVITED_CANCEL:
		emit onInviteCancel(QString::number(item._iUid), QString::number(item._iRoomId));
		break;
	default:
		break;
	}
}

void LiveManager::onInvite(LiveInviteActionType cmd, const LiveInviteItem& item) {
	switch (cmd) {
	case LiveInviteActionType::LIVE_INVITE_TYPE_ACCEPT:
		emit onInviteAccept(QString::number(item._iUid), QString::number(item._iRoomId));
		break;
	case LiveInviteActionType::LIVE_INVITE_TYPE_REFUSE:
		emit onInviteRefuse(QString::number(item._iUid), QString::number(item._iRoomId));
		break;
	case LiveInviteActionType::LIVE_INVITE_TYPE_RUNNING:
		emit onInviteRunning(QString::number(item._iUid), QString::number(item._iRoomId));
		break;
	case LiveInviteActionType::LIVE_INVITE_TYPE_TIME_OUT:
		emit onInviteTimeout(QString::number(item._iUid), QString::number(item._iRoomId));
		break;
	default:
		break;
	}
}

bool LiveManager::onJoinRoomAck(const std::string& body) {
	return true;
}

bool LiveManager::onJoinRoomBroadcast(const std::string& body) {
	WSRoomMessage msg;
	WSRoomMessage::FromJson(&msg, body);
	return handleJoinBroadcast(msg);
}

bool LiveManager::onLeaveRoomBroadcast(const std::string& body) {
	WSRoomMessage msg;
	WSRoomMessage::FromJson(&msg, body);
	return handleLeaveBroadcast(msg);
}

bool LiveManager::onRoomDestory(const std::string& body) {
	return true;
}

bool LiveManager::onChatApply(const std::string& body) {
	WSInviteMessage msg;
	WSInviteMessage::FromJson(&msg, body);
	return _pLiveBeInvited->handleMsg(CCSRequestCmd::CCS_CHAT_APPLY, msg);
}

bool LiveManager::onChatCancel(const std::string& body) {
	WSInviteMessage msg;
	WSInviteMessage::FromJson(&msg, body);
	auto ret = _pLiveBeInvited->handleMsg(CCSRequestCmd::CCS_CHAT_CANCEL, msg);
	if (!ret) {
		ret = _pLiveInvite->handleMsg(CCSRequestCmd::CCS_CHAT_CANCEL, msg);
	}
	return ret;
}

bool LiveManager::onChatAccept(const std::string& body) {
	WSInviteMessage msg;
	WSInviteMessage::FromJson(&msg, body);
	return _pLiveInvite->handleMsg(CCSRequestCmd::CCS_CHAT_ACCEPT, msg);
}

bool LiveManager::onChatReject(const std::string& body) {
	WSInviteMessage msg;
	WSInviteMessage::FromJson(&msg, body);
	return _pLiveInvite->handleMsg(CCSRequestCmd::CCS_CHAT_REJECT, msg);
}

bool LiveManager::onChatHangup(const std::string& body) {
	WSInviteMessage msg;
	WSInviteMessage::FromJson(&msg, body);
	return handleHangup(msg);
}

bool LiveManager::onChatingBroadcast(const std::string& body) {
	WSInviteMessage msg;
	WSInviteMessage::FromJson(&msg, body);
	return handleChatingBroadcast(msg);
}

bool LiveManager::onHangupBroadcast(const std::string& body) {
	WSInviteMessage msg;
	WSInviteMessage::FromJson(&msg, body);
	return handleHangupBroatcast(msg);
}

bool LiveManager::onChattingLimit(const std::string& body) {
	WSInviteMessage msg;
	WSInviteMessage::FromJson(&msg, body);
	return _pLiveInvite->handleMsg(CCSRequestCmd::CCS_CHAT_CHATTING, msg);
}

bool LiveManager::onMicEnableBroadcast(const std::string& body) {
	return true;
	//WSInviteMessage msg;
	//WSInviteMessage::FromJson(&msg, body);
	//return handleMicOffBroadcast(msg);
}

void LiveManager::onNetConnected() {
	emit onNetConnectedJ();
}

void LiveManager::onNetConnecting() {
	emit onNetConnectingJ();
}

void LiveManager::onNetClose() {
	emit onNetClosedJ();
}

void LiveManager::onNetError(const std::string& error) {
	emit onNetErrorJ(stdString2QString(error));
}


bool LiveManager::handleJoinBroadcast(const WSRoomMessage& message) {
	if (message.Body.LiveRoomId == RoomInfo::GetInstance()->_iRoomId) {
		emit onUserJoin(QString::number(message.Body.Uid));
	}
	return true;
}

bool LiveManager::handleLeaveBroadcast(const WSRoomMessage& message) {
	emit onUserLeave(QString::number(message.Body.Uid));
	return true;
}

bool LiveManager::handleHangup(const WSInviteMessage& message) {
	emit onReceiveHungupRequest(QString::number(message.Body.SrcUid), QString::number(message.Body.SrcRoomId));
	return true;
}

bool LiveManager::handleChatingBroadcast(const WSInviteMessage& message) {
	int64_t uid = 0;
	int64_t roomId = 0;
	if (message.Body.SrcUid == RoomInfo::GetInstance()->_pRoomAnchor->_iUid) {
		uid = message.Body.DestUid;
		roomId = message.Body.DestRoomId;
	}
	else {
		uid = message.Body.SrcUid;
		roomId = message.Body.SrcRoomId;
	}

	if (uid && roomId) {
		emit onAnchorConnected(QString::number(uid), QString::number(roomId));
	}
	return true;
}

bool LiveManager::handleHangupBroatcast(const WSInviteMessage& message) {
	int64_t uid = 0;
	int64_t roomId = 0;
	if (message.Body.SrcUid == RoomInfo::GetInstance()->_pRoomAnchor->_iUid) {
		uid = message.Body.DestUid;
		roomId = message.Body.DestRoomId;
	}
	else {
		if (message.Body.DestUid == RoomInfo::GetInstance()->_pRoomAnchor->_iUid) {
			uid = message.Body.SrcUid;
			roomId = message.Body.SrcRoomId;
		}
		else {
			uid = message.Body.DestUid;
			roomId = message.Body.DestRoomId;
		}
	}

	if (uid && roomId) {
		emit onAnchorDisconnected(QString::number(uid), QString::number(roomId));
	}
	return true;
}

bool LiveManager::handleMicOffBroadcast(const WSInviteMessage& message) {
	//YYLogFuncEntry([self class], _cmd, nil);
	//WSMicOffRequest *q = (WSMicOffRequest *)[WSMicOffRequest yy_modelWithJSON : body];
	//NSString *uid = [NSString stringWithFormat : @"%lld", q.DestUid];
	//	NSString *srcUid = [NSString stringWithFormat : @"%lld", q.SrcUid];

	//	if ([self.signalDelegate respondsToSelector : @selector(liveManager : didUserMicStatusChanged : byOther : status : )]) {
	//	dispatch_async(dispatch_get_main_queue(), ^{
	//		[self.signalDelegate liveManager : self didUserMicStatusChanged : uid byOther : srcUid status : q.MicEnable];
	//	});
	//}
	//return YES;
	//YYLogFuncExit([self class], _cmd);
	return true;
}

bool LiveManager::applyConnectToUser(const QString& uid, const QString& roomId) {
	return _pLiveInvite->sendInvote(uid, roomId);
}

bool LiveManager::cancelConnectToUser() {
	return _pLiveInvite->cancel();
}

bool LiveManager::acceptConnectWithUser(const QString& uid) {
	QString roomId;
	return _pLiveBeInvited->accept(uid, roomId);
}

bool LiveManager::refuseConnectWithUser(const QString& uid) {
	return _pLiveBeInvited->refuse(uid);
}

void LiveManager::clearBeInvitedQueue() {
	_pLiveBeInvited->clearBeInvitedQueue();
}

bool LiveManager::hungupWithUser(const QString& uid, const QString& roomId) {
	WSInviteMessage msg;
	msg.MsgId = (int)WSRequestCmd::WS_CHAT_HANGUP;
	msg.Body.SrcUid = LocalUserInfo::GetInstance()->_iUid;
	msg.Body.SrcRoomId = RoomInfo::GetInstance()->_iRoomId;
	msg.Body.DestUid = uid.toInt();
	msg.Body.DestRoomId = roomId.toInt();
	msg.Body.ChatType = (int)RoomType::LIVE;
	return CCService::GetInstance()->sendHangup(msg.ToJson());
}

void LiveManager::joinWSRoom() {
	resetAll();
	CCService::GetInstance()->setUseWS(true);
	CCService::GetInstance()->addObserver(this);
	CCService::GetInstance()->joinRoom();

	WSRoomMessage roomMessage;
	roomMessage.MsgId = (int)WSRequestCmd::WS_JOIN_ROOM;
	roomMessage.Body.Uid = LocalUserInfo::GetInstance()->_iUid;
	roomMessage.Body.LiveRoomId = RoomInfo::GetInstance()->_iRoomId;
	roomMessage.Body.ChatRoomId = 0;

	CCService::GetInstance()->sendJoinRoom(roomMessage.ToJson());
}

void LiveManager::leaveWSRoom() {
	WSRoomMessage roomMessage;
	roomMessage.MsgId = (int)WSRequestCmd::WS_LEAVE_ROOM;
	roomMessage.Body.Uid = LocalUserInfo::GetInstance()->_iUid;
	roomMessage.Body.LiveRoomId = RoomInfo::GetInstance()->_iRoomId;
	roomMessage.Body.ChatRoomId = 0;

	CCService::GetInstance()->sendLeaveRoom(roomMessage.ToJson());

	CCService::GetInstance()->leaveRoom();
	_pLiveBeInvited.reset();
	_pLiveInvite.reset();
}

void LiveManager::resetAll() {
	_pLiveBeInvited.reset(new LiveBeInvited());
	_pLiveInvite.reset(new LiveInvite());
	connect(_pLiveBeInvited.get(), SIGNAL(onBeInvited(LiveBeInvitedActiontype, const LiveInviteItem&)),
		this, SLOT(onBeInvited(LiveBeInvitedActiontype, const LiveInviteItem&)));

	connect(_pLiveInvite.get(), SIGNAL(onInvite(LiveInviteActionType, const LiveInviteItem&)),
		this, SLOT(onInvite(LiveInviteActionType, const LiveInviteItem&)));
}
