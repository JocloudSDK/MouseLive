#include "MessageBoxPKUI.h"
#include "../Constans.h"
#include "../../common/log/loggerExt.h"
#include "../../common/qss/QssLoad.h"
#include <QGraphicsDropShadowEffect>

using namespace base;
static const char* TAG = "MessageBoxNormalUI";

MessageBoxPKUI::MessageBoxPKUI(QWidget *parent) : QWidget(parent) {
	_oUI.setupUi(this);

	initEvent();

	_pObserver = nullptr;
	this->setWindowFlags(Qt::FramelessWindowHint);//去除窗体边框
	this->setWindowModality(Qt::ApplicationModal);//设置窗体模态，要求该窗体没有父类，否则无效
	setAttribute(Qt::WA_TranslucentBackground);//背景透明。
	this->hide();

	Utils::QssLoad::Load(this, "MessageUI.qss");

	QGraphicsDropShadowEffect *shadowEffect = new QGraphicsDropShadowEffect();
	shadowEffect->setBlurRadius(100);	//设置圆角半径 像素
	shadowEffect->setColor(Qt::black);	// 设置边框颜色
	shadowEffect->setOffset(5);

	_oUI.centerWidget->setGraphicsEffect(shadowEffect);

	_oJTimer.setInterval(1000);
	connect(&_oJTimer, SIGNAL(timeout()), this, SLOT(onTimeout()));
}

MessageBoxPKUI::~MessageBoxPKUI() {
}

void MessageBoxPKUI::showDialog(const QString& message, const QString& cover, int64_t uid, int64_t roomId,
	MessageBoxPKUIShowType type, MessageBoxPKUIObserver* observer, int timeout) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("Type", std::to_string((int)type))
		.addDetail("uid", std::to_string(uid)).addDetail("roomid", std::to_string(roomId)));
	
	_eShowType = type;
	_pObserver = observer;

	_strMessage = message;
	QString str = message;
	if (timeout != -1) {
		str += ", " + QString::number(timeout) + " " + QApplication::translate("MessageBoxPKUI", "Second", 0);
		_iTimeout = timeout;
		_oJTimer.start();
	}

	_iLinkUid = uid;
	_iLinkRoomId = roomId;
	_oUI.messageLabel->setText(str);

	switch (type)
	{
	case MessageBoxPKUIShowType::LIVINGUI_BE_APPLY_PK:
	case MessageBoxPKUIShowType::LIVINGUI_BE_APPLY_MEET:
	{
		// 2 个按钮
		_oUI.okBtn->show();
		_oUI.cancelBtn->show();
		_oUI.cancelBtn->setGeometry(QRect(50, 170, 120, 40));
		_oUI.cancelBtn->setText(QApplication::translate("MessageBoxPKUI", "Refuse", 0));
		_oUI.okBtn->setText(QApplication::translate("MessageBoxPKUI", "OK", 0));
	}
		break;
	case MessageBoxPKUIShowType::LIVINGUI_SEND_APPLY_PK:
	case MessageBoxPKUIShowType::LIVINGUI_SEND_APPLY_MEET:
	{
		// 不要按钮
		_oUI.okBtn->hide();
		_oUI.cancelBtn->hide();
		//_oUI.cancelBtn->setGeometry(QRect(60, 170, 240, 40));
		//_oUI.cancelBtn->setText(QApplication::translate("MessageBoxPKUI", "Cancel", 0));
	}
		break;
	}

	this->show();
	setWindowTitle(QApplication::translate("AppInfo", "AppName", 0));
}

void MessageBoxPKUI::hideDialog() {
	_oJTimer.stop();
	_strMessage = "";
	_iTimeout = -1;
	_iTimeCount = 0;
	_pObserver = nullptr;
	_iLinkUid = 0;
	_iLinkRoomId = 0;
	this->hide();
}

void MessageBoxPKUI::onTimeout() {
	int t = _iTimeout - (++_iTimeCount);
	if (t <= 1) {
		Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
		onClickCancelBtn(true);
	}
	else {
		QString str = _strMessage + " " + QString::number(t) + QApplication::translate("MessageBoxPKUI", "Second", 0) + "...";
		_oUI.messageLabel->setText(str);
	}
}

void MessageBoxPKUI::onClickOKBtn(bool) {
	if (_pObserver) {
		Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("_eShowType", std::to_string((int)_eShowType))
			.addDetail("_iLinkUid", std::to_string(_iLinkUid)).addDetail("_iLinkRoomId", std::to_string(_iLinkRoomId)));
		_pObserver->onClickLinkOK(_iLinkUid, _iLinkRoomId, _eShowType);
	}
	_eShowType = MessageBoxPKUIShowType::NONE;
	_oJTimer.stop();
	_strMessage = "";
	_iTimeout = -1;
	_iTimeCount = 0;
	_pObserver = nullptr;
	_iLinkUid = 0;
	_iLinkRoomId = 0;
	this->hide();
}

void MessageBoxPKUI::onClickCancelBtn(bool) {
	if (_pObserver) {
		Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("_eShowType", std::to_string((int)_eShowType))
			.addDetail("_iLinkUid", std::to_string(_iLinkUid)).addDetail("_iLinkRoomId", std::to_string(_iLinkRoomId)));
		_pObserver->onClickLinkCancel(_iLinkUid, _iLinkRoomId, _eShowType);
	}
	_eShowType = MessageBoxPKUIShowType::NONE;
	_oJTimer.stop();
	_strMessage = "";
	_iTimeout = -1;
	_iTimeCount = 0;
	_pObserver = nullptr;
	_iLinkUid = 0;
	_iLinkRoomId = 0;
	this->hide();
}

void MessageBoxPKUI::initEvent() {
	connect(_oUI.okBtn, SIGNAL(clicked(bool)), this, SLOT(onClickOKBtn(bool)));
	connect(_oUI.cancelBtn, SIGNAL(clicked(bool)), this, SLOT(onClickCancelBtn(bool)));
}

void MessageBoxPKUI::mousePressEvent(QMouseEvent *event) {
	if (event->button() == Qt::LeftButton) {
		_bDragFlag = true;
		_oDragPosition = event->globalPos() - this->pos();
		event->accept();
	}
}

void MessageBoxPKUI::mouseMoveEvent(QMouseEvent *event) {
	if (_bDragFlag && (event->buttons() && Qt::LeftButton)) {
		move(event->globalPos() - _oDragPosition);
		event->accept();
	}
}

void MessageBoxPKUI::mouseReleaseEvent(QMouseEvent *event) {
	_bDragFlag = false;
}
