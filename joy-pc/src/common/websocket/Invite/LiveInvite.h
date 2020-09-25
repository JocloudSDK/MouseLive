#pragma once

//
//  LiveInvite.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#include "LiveInviteItem.h"
#include "../WSModel.h"
#include "../CCService.h"
#include <QMutex>
#include <QObject>

enum class LiveInviteActionType {
    LIVE_INVITE_TYPE_ACCEPT,
    LIVE_INVITE_TYPE_REFUSE,
    LIVE_INVITE_TYPE_RUNNING,
    LIVE_INVITE_TYPE_TIME_OUT,
    LIVE_INVITE_TYPE_CHATING,
};

class LiveInvite : public QObject {
	Q_OBJECT
public:
	LiveInvite(QObject* parent = nullptr);
	~LiveInvite();

	/// 发送申请连麦请求
	/// @param uid 要连麦用户 uid
	/// @param roomid 要连麦用户 roomid
	bool sendInvote(const QString& uid, const QString& roomId);

	/// 取消连麦
	bool cancel();

	/// 处理接到的请求
	/// @param cmd 请求 cmd
	/// @param body 请求内容
	bool handleMsg(CCSRequestCmd cmd, const WSInviteMessage& inviteMessage);

signals:
	void onInvite(LiveInviteActionType cmd, const LiveInviteItem& item);

private:
	LiveInviteItem _oItem;
	QMutex _oItemMutex;
};

