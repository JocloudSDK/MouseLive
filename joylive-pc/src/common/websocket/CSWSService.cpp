//
//  CSWSService.m
//  MouseLive
//
//  Created by 张建平 on 2020/4/14.
//  Copyright © 2020 sy. All rights reserved.
//

#include "CSWSService.h"
#include "CCService.h"
#include "WSService.h"
#include "../../mainui/Constans.h"
#include "../utils/String.h"
#include "../log/loggerExt.h"

using namespace base;

static const char* TAG = "CSWSService";

CSWSService::CSWSService() : _pCCServiceObserver(nullptr) {
}

CSWSService::~CSWSService() {

}

void CSWSService::joinRoom() {
	WSService::GetInstance()->addObserver(this);
	WSService::GetInstance()->connectToServer(qstring2stdString(STR_WEBSOCKET_BASE));
}

void CSWSService::leaveRoom() {
	WSService::GetInstance()->close();
	_strJoinRoomReq = "";
}

void CSWSService::setUseWS(bool ws) {

}

bool CSWSService::sendApply(const std::string& body) {
	WSService::GetInstance()->sendText(WSRequestCmd::WS_CHAT_APPLY, body);
	return true;
}

bool CSWSService::sendAccept(const std::string& body) {
	WSService::GetInstance()->sendText(WSRequestCmd::WS_CHAT_ACCEPT, body);
	return true;
}

bool CSWSService::sendReject(const std::string& body) {
	WSService::GetInstance()->sendText(WSRequestCmd::WS_CHAT_REJECT, body);
	return true;
}

bool CSWSService::sendCancel(const std::string& body) {
	WSService::GetInstance()->sendText(WSRequestCmd::WS_CHAT_CANCEL, body);
	return true;
}

bool CSWSService::sendHangup(const std::string& body) {
	WSService::GetInstance()->sendText(WSRequestCmd::WS_CHAT_HANGUP, body);
	return true;
}

bool CSWSService::sendMicEnable(const std::string& body) {
	WSService::GetInstance()->sendText(WSRequestCmd::WS_CHAT_MIC_ENABLE, body);
	return true;
}

bool CSWSService::sendJoinRoom(const std::string& body) {
	_strJoinRoomReq = body;
	if (WSService::GetInstance()->getState() == WSServiceState::WS_CONNECTED) {
		Logd(TAG, Log(__FUNCTION__).setMessage("WS_JOIN_ROOM").addDetail("_strJoinRoomReq", _strJoinRoomReq));
		WSService::GetInstance()->sendText(WSRequestCmd::WS_JOIN_ROOM, body);
	}
	return true;
}

bool CSWSService::sendLeaveRoom(const std::string& body) {
	WSService::GetInstance()->sendText(WSRequestCmd::WS_LEAVE_ROOM, body);
	return true;
}

void CSWSService::onNetError(int err) {
	if (_pCCServiceObserver) {
		_pCCServiceObserver->onNetError(std::to_string(err));
	}
}

void CSWSService::onConnectSuccess() {
	if (_strJoinRoomReq != "") {
		// 连接上，就需要发送 join room 消息
		Logd(TAG, Log(__FUNCTION__).setMessage("WS_JOIN_ROOM").addDetail("_strJoinRoomReq", _strJoinRoomReq));
		WSService::GetInstance()->sendText(WSRequestCmd::WS_JOIN_ROOM, _strJoinRoomReq);
	}
}

void CSWSService::onClose() {
	if (_pCCServiceObserver) {
		_pCCServiceObserver->onNetClose();
	}
}

void CSWSService::onConnecting() {
	if (_pCCServiceObserver) {
		_pCCServiceObserver->onNetConnecting();
	}
}

bool CSWSService::handleWSError() {
	if (_pCCServiceObserver) {
		_pCCServiceObserver->onNetError("123");
	}
	return true;
}

bool CSWSService::handleJoinRoomAck() {
	if (_pCCServiceObserver) {
		_pCCServiceObserver->onNetConnected();
	}
	return true;
}

bool CSWSService::onRecvMsgWithCmd(WSRequestCmd cmd, const std::string& body) {
	switch (cmd)
	{
	case WSRequestCmd::WS_JOIN_ROOM:
		return handleJoinRoomAck();
	case WSRequestCmd::WS_JOIN_BROADCAST:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onJoinRoomBroadcast(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_LEAVE_BROADCAST:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onLeaveRoomBroadcast(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_APPLY:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onChatApply(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_CANCEL:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onChatCancel(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_ACCEPT:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onChatAccept(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_REJECT:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onChatReject(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_HANGUP:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onChatHangup(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_CHATING_BROADCAST:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onChatingBroadcast(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_HANGUP_BROADCAST:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onHangupBroadcast(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_CHATTING:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onChattingLimit(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_CHAT_MIC_ENABLE_BROADCAST:
	{
		auto ret = false;
		if (_pCCServiceObserver) {
			ret = _pCCServiceObserver->onMicEnableBroadcast(body);
		}
		return ret;
	}
	case WSRequestCmd::WS_ERROR:
		return handleWSError();
	default:
		break;
	}
	return true;
}
