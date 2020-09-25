#pragma once
//
//  CCService.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/10.
//  Copyright © 2020 sy. All rights reserved.
//

#include "WSModel.h"
#include "../utils/Singleton.h"
#include <QObject>
#include <string>
#include <memory>

class CSWSService;

enum class CCSRequestCmd {
    CCS_JOIN_ROOM = 201, // 进入房间 -- LiveBGView
    CCS_JOIN_ROOM_ACK = 202, //  -- 先不处理
    CCS_JOIN_BROADCAST = 203, // 广播用户进入房间
    CCS_LEAVE_BROADCAST = 208, // 广播用户退出房间
    CCS_CHAT_APPLY = 301,  // 接受到连麦请求
    CCS_CHAT_CANCEL = 302, // 取消连麦请求 -- LiveBeInvited -- LiveInvite
    CCS_CHAT_ACCEPT = 303, // 同意连麦请求
    CCS_CHAT_REJECT = 304, // 拒绝请求
    CCS_CHAT_HANGUP = 305, // 挂断连麦请求
    CCS_CHAT_CHATING_BROADCAST = 306, // 广播用户连麦请求，此命令外面不能传
    CCS_CHAT_HANGUP_BROADCAST = 308, // 广播用户d断开连麦请求，此命令外面不能传
    CCS_CHAT_CHATTING = 320, // 用户正在连麦中，返回个数
    CCS_CHAT_MIC_ENABLE = 401, // 闭麦某个用户
    CCS_CHAT_MIC_ENABLE_BROADCAST = 402, // 闭麦某个用户的广播
};

class CCServiceObserver {
public:
	/// 发送进入房间消息后的接受到服务器该消息收到的返回
	virtual bool onJoinRoomAck(const std::string& body) = 0;

	/// 广播有人进入的消息
	/// @param body 有人进入房间列表 -- (NSArray<WSRoomRequest*>*)
	virtual bool onJoinRoomBroadcast(const std::string& body) = 0;

	/// 广播有人退出的消息
	/// @param body 有人退出房间列表 -- (NSArray<WSRoomRequest*>*)
	virtual bool onLeaveRoomBroadcast(const std::string& body) = 0;

	/// 房间被销毁
	/// @param body -- (NSDictionary *)
	virtual bool onRoomDestory(const std::string& body) = 0;

	/// 接收到请求连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatApply(const std::string& body) = 0;

	/// 接收到取消连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatCancel(const std::string& body) = 0;

	/// 接收到接受连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatAccept(const std::string& body) = 0;

	/// 接收到拒绝连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatReject(const std::string& body) = 0;

	/// 接收到挂断连麦的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChatHangup(const std::string& body) = 0;

	/// 接收到有人连麦的广播
	/// @param body -- (NSDictionary *)
	virtual bool onChatingBroadcast(const std::string& body) = 0;

	/// 接收到有人挂断连麦的广播
	/// @param body -- (NSDictionary *)
	virtual bool onHangupBroadcast(const std::string& body) = 0;

	/// 接收到主播已经连麦满的消息
	/// @param body -- (NSDictionary *)
	virtual bool onChattingLimit(const std::string& body) = 0;

	/// 广播有人自己改变麦克风状态的消息
	/// @param body -- (NSDictionary *)
	virtual bool onMicEnableBroadcast(const std::string& body) = 0;

	/// 网络已经连接
	virtual void onNetConnected() = 0;

	/// 网络连接中
	virtual void onNetConnecting() = 0;

	/// 网络断开
	virtual void onNetClose() = 0;

	/// 网络出现异常
	/// @param error 异常 error
	virtual void onNetError(const std::string& error) = 0;
};

class CCService : public Singleton<CCService> {
protected:
	friend class Singleton<CCService>;

	CCService();
	~CCService();

public:
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

private:
	CCServiceObserver* _pCCServiceObserver;
	std::shared_ptr<CSWSService> _pCSWSService;
};
