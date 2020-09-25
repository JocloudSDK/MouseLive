//
//  WSService.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

// 什么情况下会重连，如下：
// 1. 有 6 次以上没有收到心跳 ack 返回，重新连接
// 2. WS 返回 webSocketError，webSocketDidClose

// 解决：
// 1. 记录当前的时间，并设置超时连接的时间，由于切后台/息屏，不会出现断网，所以只有正常断网/弱网，就设置 20s 超时，重连并发送连接中消息
// 2. 一直重新连接，并给 ui 返回重连中，如果连接成功，取消一切重连状态；如果连接超时，返回 webClose
// 3. 如果切换到前台，发送给服务器已经切到前台了
// 4. 不用启用定时器了，1 中记录的时间，与当前时间做对比

#define MAX_TIMEOUT_DEFAULT 20000
#define MAX_TIMEOUT_SPECIAL 50000

#include "WSService.h"
#include "../utils/String.h"
#include "WSModel.h"
#include <QDateTime>
#include <thread>
#include <chrono>
#include "../log/loggerExt.h"

using namespace base;

static const char* TAG = "WSService";

static long long getNowForMillisecond() {
	return (long long)QDateTime::currentMSecsSinceEpoch();
}

static std::string enumToString(WSRequestCmd cmd) {
	switch (cmd) {
	case WSRequestCmd::WS_JOIN_ROOM:
		return "进入房间";
	case WSRequestCmd::WS_JOIN_BROADCAST:
		return "广播用户进入房间";
	case WSRequestCmd::WS_LEAVE_BROADCAST:
		return "广播用户退出房";
	case WSRequestCmd::WS_CHAT_APPLY:
		return "连麦请求";
	case WSRequestCmd::WS_CHAT_CANCEL:
		return "取消连麦请求";
	case WSRequestCmd::WS_CHAT_ACCEPT:
		return "同意连麦请求";
	case WSRequestCmd::WS_CHAT_REJECT:
		return "拒绝请求";
	case WSRequestCmd::WS_CHAT_HANGUP:
		return "挂断请求";
	case WSRequestCmd::WS_CHAT_CHATING_BROADCAST:
		return "广播用户连麦中请";
	case WSRequestCmd::WS_CHAT_HANGUP_BROADCAST:
		return "广播用户断开连麦请求";
	case WSRequestCmd::WS_CHAT_CHATTING: // 用户正在连麦中，返回个数
		return "用户在连麦中";
	case  WSRequestCmd::WS_CHAT_MIC_ENABLE: // 闭麦某个用户
		return "关闭某个用户";
	case WSRequestCmd::WS_CHAT_MIC_ENABLE_BROADCAST: // 闭麦某个用户的广播
		return "广播关闭某个用户";
	case WSRequestCmd::WS_LEAVE_ROOM: // 主动退出房间
		return "主动退出房";
	}
	return "错误";
}


WSService::WSService() {
	_pWebSocketClientManager.reset(new WebSocketClientManager);

	connect(_pWebSocketClientManager.get(), SIGNAL(signal_connected()),
		this, SLOT(signal_connected()));
	connect(_pWebSocketClientManager.get(), SIGNAL(signal_disconnected()),
		this, SLOT(signal_disconnected()));
	connect(_pWebSocketClientManager.get(), SIGNAL(signal_sendTextMessageResult(bool)),
		this, SLOT(signal_sendTextMessageResult(bool)));
	connect(_pWebSocketClientManager.get(), SIGNAL(signal_sendBinaryMessageResult(bool)),
		this, SLOT(signal_sendBinaryMessageResult(bool)));
	connect(_pWebSocketClientManager.get(), SIGNAL(signal_error(QString)),
		this, SLOT(signal_error(QString)));
	connect(_pWebSocketClientManager.get(), SIGNAL(signal_textFrameReceived(QString, bool)),
		this, SLOT(signal_textFrameReceived(QString, bool)));
	connect(_pWebSocketClientManager.get(), SIGNAL(signal_textMessageReceived(QString)),
		this, SLOT(signal_textMessageReceived(QString)));

	_oHeartBeatTimer.setInterval(500);
	connect(&_oHeartBeatTimer, SIGNAL(timeout()), this, SLOT(sendHeartBeat()));
}

WSService::~WSService() {
}

void WSService::connectToServer(const std::string& url) {
	_strUrl = url;

	_pWebSocketClientManager->slot_start();
	_pWebSocketClientManager->slot_connectedTo(stdString2QString(_strUrl));
}

void WSService::close() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	_eState = WSServiceState::WS_DISCONNECT_SELF;
	destoryHeartBeat();
	_pWebSocketClientManager->slot_stop();
	Logd(TAG, Log(__FUNCTION__).setMessage("exit"));
}

void WSService::sendText(WSRequestCmd cmd, const std::string& body) {
	if (cmd != WSRequestCmd::WS_HEARTBEAT) {
		Logd(TAG, Log(__FUNCTION__).setMessage("message: %s", body.c_str())
			.addDetail("cmd", enumToString(cmd).c_str()));
	}
	_pWebSocketClientManager->slot_sendTextMessage(stdString2QString(body));
}


void WSService::signal_connected() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	if (_eState != WSServiceState::WS_CONNECTING && _eState != WSServiceState::WS_DISCONNECT_SELF) {
		// 如果状态不对就返回
		Logd(TAG, Log(__FUNCTION__).setMessage("error state:%d", _eState));
		return;
	}

	_eState = WSServiceState::WS_CONNECTED;
	_iTimeout = -1;
	_iUpdateReconnectTime = 0;
	_bSendDidConnecting = true;

	Logd(TAG, Log(__FUNCTION__).setMessage("send onConnectSuccess"));
	if (_pWSServiceObserver) {
		_pWSServiceObserver->onConnectSuccess();
	}

	//initHeartBeat();

	Logd(TAG, Log(__FUNCTION__).setMessage("exit"));
}

void WSService::signal_disconnected() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	if (_eState != WSServiceState::WS_DISCONNECT_SELF) {
		// 1. 如果没有超时，就继续重连
		if (isReconnect()) {
			this_thread::sleep_for(chrono::seconds(1));
			return;
		}

		// 2. 如果超过，就发送 ws close
		Logd(TAG, Log(__FUNCTION__).setMessage("send onClose"));
		if (_pWSServiceObserver) {
			_pWSServiceObserver->onClose();
		}
	}
	Logd(TAG, Log(__FUNCTION__).setMessage("exit"));
}

void WSService::signal_sendTextMessageResult(bool result) {

}

void WSService::signal_sendBinaryMessageResult(bool result) {

}

void WSService::signal_error(QString errorString) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("error", errorString.toStdString()));
	// 1. 如果没有超时，就继续重连
	if (isReconnect()) {
		this_thread::sleep_for(chrono::seconds(1));
		return;
	}

	// 2. 如果超过，就发送 ws error
	Logd(TAG, Log(__FUNCTION__).setMessage("send onNetError"));
	if (_pWSServiceObserver) {
		_pWSServiceObserver->onNetError(-10);
	}
	Logd(TAG, Log(__FUNCTION__).setMessage("exit"));
}

void WSService::signal_textFrameReceived(QString frame, bool isLastFrame) {

}

void WSService::signal_textMessageReceived(QString message) {
	WSBaseParseResponse resp;
	WSBaseParseResponse::FromJson(&resp, qstring2stdString(message));

	if (resp.MsgId == (int)WSRequestCmd::WS_HEARTBEAT_ACK) {
		_iReceiveHeartCount++;
		if (_iReceiveHeartCount != _iSendHeartCount) {
			Logd(TAG, Log(__FUNCTION__).setMessage("接收心跳, send:%d, receive : %d drop count : %d", 
				_iSendHeartCount, _iReceiveHeartCount, _iSendHeartCount - _iReceiveHeartCount));
		}

		_iReceiveHeartCount = 0;
		_iSendHeartCount = 0;
		return;
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("message: %s", qstring2stdString(message).c_str())
		.addDetail("cmd", enumToString((WSRequestCmd)resp.MsgId).c_str()));
	}

	if (resp.MsgId >= 10000 || resp.MsgId == 0) {
		// 错误了
		if (_eState == WSServiceState::WS_CONNECTED) {
			if (_pWSServiceObserver) {
				_pWSServiceObserver->onRecvMsgWithCmd(WSRequestCmd::WS_ERROR, qstring2stdString(message));
			}
		}
		return;
	}

	if (resp.Body.Code == "Ack") {
		// 只有 joinroom 的 ack 返回才有用
		if (resp.MsgId != (int)WSRequestCmd::WS_JOIN_ROOM) {
			return;
		}
		else {
			// 如果是 joinRoom 的 ack 返回，启动心跳，心跳需要和后台确认下
			initHeartBeat();
		}
	}

	if (_eState != WSServiceState::WS_CONNECTED) {
		Logd(TAG, Log(__FUNCTION__).setMessage("exit error, state:%d", _eState));
		return;
	}

	if (_pWSServiceObserver) {
		_pWSServiceObserver->onRecvMsgWithCmd((WSRequestCmd)resp.MsgId, qstring2stdString(message));
	}
}

void WSService::initHeartBeat() {
	//心跳没有被关闭
	if (_oHeartBeatTimer.isRunning()) {
		return;
	}
	Logd(TAG, Log(__FUNCTION__).setMessage("begin heart beat"));
	_oHeartBeatTimer.start();
}

void WSService::destoryHeartBeat() {
	_oHeartBeatTimer.stop();
	Logd(TAG, Log(__FUNCTION__).setMessage("end heart beat"));
}


//发送心跳
void WSService::sendHeartBeat() {
	if (_pWebSocketClientManager->running()) {
		_iLogCount++;
		if (_iLogCount >= 6) {
			// 每 6 次，打印日志
			//                YYLogDebug(@"[MouseLive-WSService] 发送心跳 sendCount:%d, receiveHeartCount:%d", weakSelf.sendHeartCount, weakSelf.receiveHeartCount);
			_iLogCount = 0;
		}

		// 发送心跳包
		_iSendHeartCount++;

		// send
		this->sendText(WSRequestCmd::WS_HEARTBEAT, "{\"MsgId\": 500,\"Body\" : \"OK\"}");
	}

	// 3s 没有收到心跳的 ack，认为已经要重连连接了
	if (_iSendHeartCount - _iReceiveHeartCount >= 6) {
		Logd(TAG, Log(__FUNCTION__).setMessage("3s timeout!!!!!!"));
		reconnect(true);

		// 记录当前时间
		_iTimeout = MAX_TIMEOUT_DEFAULT;
		_iUpdateReconnectTime = getNowForMillisecond();
	}
}

void WSService::reconnect(bool needClose) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	_eState = WSServiceState::WS_CONNECTING;

	if (needClose) {
		this->destoryHeartBeat();
		_pWebSocketClientManager->slot_stop();
	}

	// 2. 连接
	_pWebSocketClientManager->slot_start();
	_pWebSocketClientManager->slot_connectedTo(stdString2QString(_strUrl));
	_iSendHeartCount = 0;
	_iReceiveHeartCount = 0;
	_iLogCount = 0;

	if (_bSendDidConnecting) {
		_bSendDidConnecting = false;
		Logd(TAG, Log(__FUNCTION__).setMessage("send onConnecting"));
		if (_pWSServiceObserver) {
			_pWSServiceObserver->onConnecting();
		}
	}

	Logd(TAG, Log(__FUNCTION__).setMessage("exit"));
}

bool WSService::isReconnect() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	bool reconect = false;
	long long now = getNowForMillisecond();
	if (_iUpdateReconnectTime == 0) {
		// 1. 记录当前时间
		_iTimeout = MAX_TIMEOUT_DEFAULT;
		_iUpdateReconnectTime = getNowForMillisecond();

		// 2. 重连
		reconnect(true);
		reconect = true;
	}
	else {
#if 0
		if (now - _iUpdateReconnectTime < _iTimeout) {
			reconnect(true);
			reconect = true;
		}
#endif
		// 一直重连
		reconnect(true);
		reconect = true;
	}

	Logd(TAG, Log(__FUNCTION__).setMessage("exit, reconnect:%d", reconect));
	return reconect;
}
