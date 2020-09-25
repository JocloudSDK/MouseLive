//
//  CSWSService.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/14.
//  Copyright © 2020 sy. All rights reserved.
//

#include <string>
#include "WSService.h"

class CCServiceObserver;
class CSWSService : public WSServiceObserver {
public:
	CSWSService();
	~CSWSService();

	/// 加入房间
	void joinRoom();

	/// 离开房间
	void leaveRoom();

	/// 增加观察者
	/// @param observer id<CCServiceDelegate>
	void addObserver(CCServiceObserver* observer) { _pCCServiceObserver = observer; }

	/// 移除观察者
	/// @param observer id<CCServiceDelegate>
	void removeObserver(CCServiceObserver* observer) { _pCCServiceObserver = nullptr; }

	/// 是否使用 WS，此接口请在使用 send + addObserver 前调用，用户是否使用 WS
	/// @param ws YES - 使用
	void setUseWS(bool ws);

	/// 发送请求连麦请求 -- WS_CHAT_APPLY
	/// @param req WSInviteRequest 结构体
	bool sendApply(const std::string& body);

	/// 发送接受连麦请求 -- WS_CHAT_ACCEPT
	/// @param req WSInviteRequest 结构体
	bool sendAccept(const std::string& body);

	/// 发送拒绝连麦请求 -- WS_CHAT_REJECT
	/// @param req WSInviteRequest 结构体
	bool sendReject(const std::string& body);

	/// 发送取消连麦请求 -- WS_CHAT_CANCEL
	/// @param req WSInviteRequest 结构体
	bool sendCancel(const std::string& body);

	/// 发送挂断连麦请求 -- WS_CHAT_HANGUP
	/// @param req WSInviteRequest 结构体
	bool sendHangup(const std::string& body);

	/// 发送自己开麦/闭麦连麦请求 -- WS_CHAT_MIC_ENABLE
	/// @param req WSMicOffRequest 结构体
	bool sendMicEnable(const std::string& body);

	/// 发送进入房间的请求
	/// @param req WSRoomRequest 结构体
	bool sendJoinRoom(const std::string& body);

	/// 发送退出房间的请求
	/// @param req WSRoomRequest 结构体
	bool sendLeaveRoom(const std::string& body);

	/// 接收到 WS 数据 回调
	/// @param cmd 命令 WSRequestType
	/// @param body 消息体
	virtual bool onRecvMsgWithCmd(WSRequestCmd cmd, const std::string& body);

	/// WS 网络错误 回调
	/// @param err 错误码
	virtual void onNetError(int err);

	/// WS 已经连接成功 回调
	virtual void onConnectSuccess();

	/// WS 关闭 回调
	virtual void onClose();

	/// WS 连接中，重连状态
	virtual void onConnecting();

protected:
	bool handleWSError();
	bool handleJoinRoomAck();
	bool handleCmd(const std::string& body);

private:
	CCServiceObserver* _pCCServiceObserver;
	std::string _strJoinRoomReq;
};
