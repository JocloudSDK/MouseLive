#pragma once

#include <QtWidgets/QWidget>
#include <QMouseEvent>
#include <QCloseEvent>
#include "ui_LivingUI.h"
#include "../../RoomInfo.h"
#include "../../LogicModel.h"
#include "../logic/LivingHttpLogic.h"
#include "ThunderMeetUI.h"
#include "../../baseui/MessageBoxPKUI.h"
#include "../../baseui/MessageBoxNormalUI.h"
#include "../../sdk/chatroom/ChatRoomManager.h"
#include "BeautyUI.h"

class ClientEquipmentUI;
class LivingDialogUI : public QWidget,
	public MessageBoxPKUIObserver,
	public MessageBoxNormalUIObserver {
	Q_OBJECT

protected:
	enum WindowSizeType {
		UNKNOWN = 0,
		BIG = 1,   // 1352x690
		MIDDLE,  // 1092x690��PK ���� �����ʱ��
		SMALL  // 821x690   -- ����ģ�û��ʹ��
	};

public:
	LivingDialogUI(QWidget *parent = Q_NULLPTR);
	~LivingDialogUI();

	void showDialog();
	void hideDialog();
	void changeLanguage();

private:
	void initLogoView();
	void initEvent();
	void initWindow();
	void initHttp();
	void initMode();
	void initCenterList();
	void initBeautyUI();
	void initThunderUI();
	void initWS();
	void initChatRoom();

	void switchDialog(WindowSizeType from, WindowSizeType to);

	void leaveRoom();
	void linkUI();
	void beforeLiving();

	void initBigSize();
	void initMiddleSize();
	void initSmallSize();

	void sendCreateRoomRequest();

protected:
	void mousePressEvent(QMouseEvent *event);
	void mouseMoveEvent(QMouseEvent *event);
	void mouseReleaseEvent(QMouseEvent *event);

	void closeEvent(QCloseEvent *event);

	virtual void onClickMsgOKBtn(MessageBoxNormalUIShowType t);
	virtual void onClickMsgCancelBtn(MessageBoxNormalUIShowType t);

	virtual void onClickLinkOK(int64_t uid, int64_t roomId, MessageBoxPKUIShowType t); // ͬ������/PK����
	virtual void onClickLinkCancel(int64_t uid, int64_t roomId, MessageBoxPKUIShowType t); // ��ͬ������/PK����

signals:
	void onLivingUILeaveRoom();

public slots :
	void onClickMinBtn();
	void onClickCloseBtn();
	void onClickBeginLivingBtn(bool);
	void onClickLinkBreakBtn(bool);

	void onUserJoin(const QString& uid);
	void onUserLeave(const QString& uid);
	void onBeInvited(const QString& uid, const QString& roomId);
	void onInviteCancel(const QString& uid, const QString& roomId);
	void onInviteAccept(const QString& uid, const QString& roomId);
	void onInviteRefuse(const QString& uid, const QString& roomId);
	void onInviteTimeout(const QString& uid, const QString& roomId);
	void onInviteRunning(const QString& uid, const QString& roomId);
	void onReceiveHungupRequest(const QString& uid, const QString& roomId);
	void onAnchorConnected(const QString& uid, const QString& roomId);
	void onAnchorDisconnected(const QString& uid, const QString& roomId);
	void onSendRequestFail(const QString& error);
	void onReceivedMessage(const QString& uid, const QString& message);
	void onReceivedRoomMessage(const QString& uid, const QString& message);
	void onUserBeKicked(const QString& uid);
	void onSelfBeKicked();
	void onUserMicStatusChanged(const QString& localUid, const QString& otherUid, bool state);
	void onRoomMicStatusChanged(bool micOn);
	void onUserMuteStatusChanged(const QString& uid, bool muted);
	void onRoomMuteStatusChanged(bool muted);
	void onUserRoleChanged(const QString& uid, bool hasRole);
	void onNetConnectedJ();
	void onNetClosedJ();
	void onNetConnectingJ();
	void onNetErrorJ(const QString& error);

	void onLinkAnchor();
	void onPKRequest(int64_t uid, int64_t roomId);
	void onBreakLink(int64_t uid, int64_t roomId);  // ֻ�������ܹ��Ͽ�����
	void onSelectPublishMode(int m);

	void onShowOneCanvas();  // ��ʾ1���棬ֻ���Լ��Ƿ����Żص�
	void onShowTwoCanvas(); // ��ʾ2���棬ֻ���Լ��Ƿ����Żص�

	void onJoinChatRoomSuccess(int64_t chatRoomId);
	void onJoinChatRoomFailed();

	void onCreateRoomSuccess(const QString& body);
	void onCreateRoomFailed();
	void onSetChatIdSuccess(const QString& body);
	void onSetChatIdFailed();

	void onTimeout();

private:
	Ui::LivingRoomDialogClass _oUI;

	std::shared_ptr<LivingHttpLogic> _pLivingHttpLogic;
	WindowSizeType _eWindowSizeType;

	bool _bDragFlag = false; // check the mouse down
	QPoint _oDragPosition;
	std::shared_ptr<ClientEquipmentUI> _pClientEquipmentUI;
	std::shared_ptr<BeautyUI> _pBeautyUI;
	std::shared_ptr<ThunderMeetUI> _pThunderMeetUI;

	QTimer _oShowTimer;

	bool _bClose = false;
};
