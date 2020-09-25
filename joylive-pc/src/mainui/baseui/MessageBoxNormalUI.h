#pragma once

#include <QWidget>
#include <QMouseEvent>
#include "ui_MessageBoxNormalUI.h"
#include "../../common/utils/Singleton.h"

enum class MessageBoxNormalUIShowType {
	NONE,

	// ��� MainUI close
	MAINUI_QUIT_APP_WHEN_LIVING, // ��ǰ����ֱ�����Ƿ�Ҫ�˳�����
	MAINUI_QUIT_APP_WHEN_WATCHING, // ��ǰ���ڹۿ����Ƿ�Ҫ�˳�����

	// ��� MainUI ����
	MAINUI_SELECT_WHEN_WATCHING, // �����˳���ǰ����
	MAINUI_SELECT_WHEN_LIVING, // ���Ƚ�����ǰֱ��

	// ��� MainUI ������ť
	MAINUI_BEGIN_LIVING_WHEN_WATCHING, // �����˳���ǰ����

	// ��� LivingUI close
	LIVINGUI_QUIT_WHEN_LIVING,  // ��ǰ����ֱ�����Ƿ�Ҫ�˳�ֱ��  -- û���õ�
	LIVING_END,  // �������ѽ���

	LIVINGUI_BE_REFUSED, // ���ܾ�
	LIVINGUI_TIMEOUT, // ��ʱ
	LIVINGUI_PKING_WAIT, // ����PK����ȴ�

	HTTP_ERROR_MSG, // Http ���ʹ������Ϣ
	WS_ERROR_MSG, // WS ���ʹ������Ϣ

	CAMERA_ERROR, // ����ͷ��ռ��
	LIVING_NOT_START_ERROR, // ��û�п���
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