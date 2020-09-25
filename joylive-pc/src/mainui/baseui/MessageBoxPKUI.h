#pragma once

#include <QWidget>
#include <QMouseEvent>
#include "ui_MessageBoxPKUI.h"
#include "../../common/utils/Singleton.h"
#include "../../common/timer/Timer.h"

enum class MessageBoxPKUIShowType {
	NONE,
	LIVINGUI_BE_APPLY_PK,  // ������ PK
	LIVINGUI_BE_APPLY_MEET, // ����������

	LIVINGUI_SEND_APPLY_PK,  // �������� PK��Ӧ��ֻ��һ��ȡ����ť��������15s �ĵ���ʱ
	LIVINGUI_SEND_APPLY_MEET, // ������������Ӧ��ֻ��һ��ȡ����ť��������15s �ĵ���ʱ
};

class MessageBoxPKUIObserver {
public:
	virtual void onClickLinkOK(int64_t uid, int64_t roomId, MessageBoxPKUIShowType t) = 0; // ͬ������/PK����
	virtual void onClickLinkCancel(int64_t uid, int64_t roomId, MessageBoxPKUIShowType t) = 0; // ��ͬ������/PK����
};

class MessageBoxPKUI : public QWidget, public Singleton<MessageBoxPKUI> {
	Q_OBJECT
	
protected:
	friend class Singleton<MessageBoxPKUI>;

public:
	MessageBoxPKUI(QWidget *parent = Q_NULLPTR);
	~MessageBoxPKUI();

	void showDialog(const QString& message, const QString& cover, int64_t uid, int64_t roomId,
		MessageBoxPKUIShowType type, MessageBoxPKUIObserver* observer, int timeout = -1);

	void hideDialog();

public slots:
	void onClickOKBtn(bool);
	void onClickCancelBtn(bool);
	void onTimeout();

private:
	void initEvent();

	void mousePressEvent(QMouseEvent *event);
	void mouseMoveEvent(QMouseEvent *event);
	void mouseReleaseEvent(QMouseEvent *event);

private:
	Ui::MessageBoxPKUIClass _oUI;
	MessageBoxPKUIObserver* _pObserver;
	JTimer _oJTimer;
	int _iTimeout = -1;
	int _iTimeCount = 0;
	QString _strMessage;
	int64_t _iLinkUid;
	int64_t _iLinkRoomId;
	MessageBoxPKUIShowType _eShowType = MessageBoxPKUIShowType::NONE;

	bool _bDragFlag = false; // check the mouse down
	QPoint _oDragPosition;
};