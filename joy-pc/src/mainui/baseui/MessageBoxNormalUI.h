#pragma once

#include <QWidget>
#include <QMouseEvent>
#include "ui_MessageBoxNormalUI.h"
#include "../../common/utils/Singleton.h"

enum class MessageBoxNormalUIShowType {
	NONE,

	// 点击 MainUI close
	MAINUI_QUIT_APP_WHEN_LIVING, // 当前正在直播，是否要退出程序
	MAINUI_QUIT_APP_WHEN_WATCHING, // 当前正在观看，是否要退出程序

	// 点击 MainUI 房间
	MAINUI_SELECT_WHEN_WATCHING, // 请先退出当前房间
	MAINUI_SELECT_WHEN_LIVING, // 请先结束当前直播

	// 点击 MainUI 开播按钮
	MAINUI_BEGIN_LIVING_WHEN_WATCHING, // 请先退出当前房间

	// 点击 LivingUI close
	LIVINGUI_QUIT_WHEN_LIVING,  // 当前正在直播，是否要退出直播  -- 没有用到
	LIVING_END,  // 主播间已结束

	LIVINGUI_BE_REFUSED, // 被拒绝
	LIVINGUI_TIMEOUT, // 超时
	LIVINGUI_PKING_WAIT, // 正在PK，请等待

	HTTP_ERROR_MSG, // Http 发送错误的消息
	WS_ERROR_MSG, // WS 发送错误的消息

	CAMERA_ERROR, // 摄像头被占用
	LIVING_NOT_START_ERROR, // 还没有开播
};

class MessageBoxNormalUIObserver {
public:
	virtual void onClickMsgOKBtn(MessageBoxNormalUIShowType t) = 0;
	virtual void onClickMsgCancelBtn(MessageBoxNormalUIShowType t) = 0;
};

class MessageBoxNormalUI : public QWidget, public Singleton<MessageBoxNormalUI> {
	Q_OBJECT
	
protected:
	friend class Singleton<MessageBoxNormalUI>;

public:
	MessageBoxNormalUI(QWidget *parent = Q_NULLPTR);
	~MessageBoxNormalUI();

	void showDialog(const QString& message, MessageBoxNormalUIShowType t, MessageBoxNormalUIObserver* observer);

public slots:
	void onClickOKBtn(bool);
	void onClickCancelBtn(bool);

private:
	void initEvent();
	void showOneBtn(bool isOne);

	void mousePressEvent(QMouseEvent *event);
	void mouseMoveEvent(QMouseEvent *event);
	void mouseReleaseEvent(QMouseEvent *event);

private:
	Ui::MessageBoxNormalUIClass _oUI;
	MessageBoxNormalUIShowType _eShowType;
	MessageBoxNormalUIObserver* _pObserver;

	bool _bDragFlag = false; // check the mouse down
	QPoint _oDragPosition;
};