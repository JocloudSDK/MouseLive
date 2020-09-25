#pragma once

//
//  WSService.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#include <QObject>
#include <QString>
#include <string>
#include <memory>
#include "../utils/Singleton.h"
#include "../timer/Timer.h"
#include "WebSocketClient.h"

enum class WSRequestCmd {
    WS_JOIN_ROOM = 201, // 进入房间 -- LiveBGView
    WS_JOIN_ROOM_ACK = 202, //  -- 先不处理 -- WSService
    WS_JOIN_BROADCAST = 203, // 广播用户进入房间，此命令外面不能传  -- 先不处理 -- WSService
    WS_LEAVE_ROOM = 205, // 退出房间
    WS_LEAVE_BROADCAST = 208, // 广播用户退出房间，此命令外面不能传  -- 先不处理 -- WSService
    WS_CHAT_APPLY = 301,  // 接受到连麦请求
    WS_CHAT_CANCEL = 302, // 取消连麦请求 -- LiveBeInvited -- LiveInvite
    WS_CHAT_ACCEPT = 303, // 同意连麦请求
    WS_CHAT_REJECT = 304, // 拒绝请求
    WS_CHAT_HANGUP = 305, // 挂断连麦请求  -- LiveBGView
    WS_CHAT_CHATING_BROADCAST = 306, // 广播用户连麦请求，此命令外面不能传
    WS_CHAT_HANGUP_BROADCAST = 308, // 广播用户d断开连麦请求，此命令外面不能传
    WS_CHAT_CHATTING = 320, // 用户正在连麦中，返回个数
    WS_CHAT_MIC_ENABLE = 401, // 闭麦某个用户
    WS_CHAT_MIC_ENABLE_BROADCAST = 402, // 闭麦某个用户的广播
    WS_HEARTBEAT = 500, // 心跳请求  -- WSService
    WS_HEARTBEAT_ACK = 501, // 心跳请求回调 -- WSService
    WS_ERROR = 22222, // WS 返回的错误，先统一以这个处理
};

enum class WSServiceState {
    WS_DISCONNECT, // 非自己主动断开
    WS_DISCONNECT_SELF,  // 自己主动断开
    WS_CONNECTED, // 已经连接
    WS_CONNECTING, // 正在连接中，比如 WS 重新连接
};

class WSServiceObserver {
public:

	// 如果已经获取到数据，不想往下传，就返回 YES

	/// 接收到 WS 数据 回调
	/// @param cmd 命令 WSRequestType
	/// @param body 消息体
	virtual bool onRecvMsgWithCmd(WSRequestCmd cmd, const std::string& body) = 0;

	/// WS 网络错误 回调
	/// @param err 错误码
	virtual void onNetError(int err) = 0;

	/// WS 已经连接成功 回调
	virtual void onConnectSuccess() = 0;

	/// WS 关闭 回调
	virtual void onClose() = 0;

	/// WS 连接中，重连状态
	virtual void onConnecting() = 0;
};

class WSService : public QObject, public Singleton<WSService> {
	Q_OBJECT
protected:
	friend class Singleton<WSService>;
	WSService();
	~WSService();

public:
	void addObserver(WSServiceObserver* observer) {
		_pWSServiceObserver = observer;
	}

	void removeObserver() {
		_pWSServiceObserver = nullptr;
	}

	void connectToServer(const std::string& url);

	void close();

	/// 发送消息
	/// @param type 命令
	/// @param object 发送的消息
	void sendText(WSRequestCmd cmd, const std::string& body);

	WSServiceState getState() const { return _eState; }

protected slots:
	void signal_connected();
	void signal_disconnected();
	void signal_sendTextMessageResult(bool result);
	void signal_sendBinaryMessageResult(bool result);
	void signal_error(QString errorString);
	void signal_textFrameReceived(QString frame, bool isLastFrame);
	void signal_textMessageReceived(QString message);
	void sendHeartBeat();

private:
	void initHeartBeat();
	void destoryHeartBeat();
	void reconnect(bool needClose);
	bool isReconnect();

private:
	WSServiceObserver* _pWSServiceObserver;
	std::shared_ptr<WebSocketClientManager> _pWebSocketClientManager;

	JTimer _oHeartBeatTimer; //心跳定时器
	int _iSendHeartCount = 0; // 发送的心跳包数量
	int _iReceiveHeartCount = 0; // 接收的心跳包数量
	int _iLogCount = 0; // 打印日志使用
	WSServiceState _eState = WSServiceState::WS_DISCONNECT_SELF;
	int _iUpdateReconnectTime = 0;// 记录当前要重连时候的时间
	long long _iTimeout = -1; // 超时的时间
	bool _bSendDidConnecting = false;// 如果断网是否发送了，正在连接中消息
	std::string _strUrl;
};
