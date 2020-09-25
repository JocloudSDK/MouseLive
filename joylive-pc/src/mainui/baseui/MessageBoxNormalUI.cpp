#include "MessageBoxNormalUI.h"
#include "../Constans.h"
#include "../../common/log/loggerExt.h"
#include "../../common/qss/QssLoad.h"
#include <QGraphicsDropShadowEffect>

using namespace base;
static const char* TAG = "MessageBoxNormalUI";

MessageBoxNormalUI::MessageBoxNormalUI(QWidget *parent) : QWidget(parent) {
	_oUI.setupUi(this);

	initEvent();

	_pObserver = nullptr;
	this->setWindowFlags(Qt::FramelessWindowHint);//去除窗体边框
	this->setWindowModality(Qt::ApplicationModal);//设置窗体模态，要求该窗体没有父类，否则无效
	setAttribute(Qt::WA_TranslucentBackground);//背景透明。

	Utils::QssLoad::Load(this, "MessageUI.qss");

	QGraphicsDropShadowEffect *shadowEffect = new QGraphicsDropShadowEffect();
	shadowEffect->setBlurRadius(100);	//设置圆角半径 像素
	shadowEffect->setColor(Qt::black);	// 设置边框颜色
	shadowEffect->setOffset(5);

	_oUI.centerWidget->setGraphicsEffect(shadowEffect);

	this->hide();
}

MessageBoxNormalUI::~MessageBoxNormalUI() {
}

void MessageBoxNormalUI::showOneBtn(bool isOne) {
	if (isOne) {
		_oUI.cancelBtn->hide();
		_oUI.okBtn->setGeometry(QRect(49, 93, 260, 40));
	}
	else {
		_oUI.cancelBtn->show();
		_oUI.okBtn->setGeometry(QRect(190, 90, 120, 40));
	}
}

void MessageBoxNormalUI::showDialog(const QString& message, MessageBoxNormalUIShowType t, MessageBoxNormalUIObserver* observer) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("Type", std::to_string((int)t)));
	switch (t) {
	case MessageBoxNormalUIShowType::NONE:
		return;
	case MessageBoxNormalUIShowType::MAINUI_QUIT_APP_WHEN_WATCHING:
	case MessageBoxNormalUIShowType::MAINUI_SELECT_WHEN_WATCHING:
	case MessageBoxNormalUIShowType::MAINUI_BEGIN_LIVING_WHEN_WATCHING:
	{
		showOneBtn(false);
		_oUI.okBtn->setText(QApplication::translate("MessageBoxNormalUI", "Logout", 0)); // 退出
		_oUI.cancelBtn->setText(QApplication::translate("MessageBoxNormalUI", "Cancel", 0)); // 取消
	}
		break;
	case MessageBoxNormalUIShowType::MAINUI_QUIT_APP_WHEN_LIVING:
	case MessageBoxNormalUIShowType::MAINUI_SELECT_WHEN_LIVING:
	case MessageBoxNormalUIShowType::LIVINGUI_QUIT_WHEN_LIVING:
	{
		showOneBtn(false);
		_oUI.okBtn->setText(QApplication::translate("MessageBoxNormalUI", "End", 0)); // 结束
		_oUI.cancelBtn->setText(QApplication::translate("MessageBoxNormalUI", "Cancel", 0)); // 取消
	}
		break;
	case MessageBoxNormalUIShowType::LIVING_END:
	case MessageBoxNormalUIShowType::LIVINGUI_BE_REFUSED:
	case MessageBoxNormalUIShowType::LIVINGUI_PKING_WAIT:
	case MessageBoxNormalUIShowType::LIVINGUI_TIMEOUT:
	case MessageBoxNormalUIShowType::HTTP_ERROR_MSG:
	case MessageBoxNormalUIShowType::WS_ERROR_MSG:
	case MessageBoxNormalUIShowType::CAMERA_ERROR:
	case MessageBoxNormalUIShowType::LIVING_NOT_START_ERROR:
	{
		showOneBtn(true);
		_oUI.okBtn->setText(QApplication::translate("MessageBoxNormalUI", "IKnown", 0)); // 我知道了
	}
		break;
	default:
		return;
	}

	_eShowType = t;
	_pObserver = observer;
	_oUI.messageLabel->setText(message);
	this->show();
	setWindowTitle(QApplication::translate("AppInfo", "AppName", 0));
}

void MessageBoxNormalUI::onClickOKBtn(bool) {
	if (_pObserver) {
		Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("_eShowType", std::to_string((int)_eShowType)));
		_pObserver->onClickMsgOKBtn(_eShowType);
	}
	_eShowType = MessageBoxNormalUIShowType::NONE;
	_pObserver = nullptr;
	this->hide();
}

void MessageBoxNormalUI::onClickCancelBtn(bool) {
	if (_pObserver) {
		Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("_eShowType", std::to_string((int)_eShowType)));
		_pObserver->onClickMsgCancelBtn(_eShowType);
	}
	_eShowType = MessageBoxNormalUIShowType::NONE;
	_pObserver = nullptr;
	this->hide();
}

void MessageBoxNormalUI::initEvent() {
	connect(_oUI.okBtn, SIGNAL(clicked(bool)), this, SLOT(onClickOKBtn(bool)));
	connect(_oUI.cancelBtn, SIGNAL(clicked(bool)), this, SLOT(onClickCancelBtn(bool)));
}

void MessageBoxNormalUI::mousePressEvent(QMouseEvent *event) {
	if (event->button() == Qt::LeftButton) {
		_bDragFlag = true;
		_oDragPosition = event->globalPos() - this->pos();
		event->accept();
	}
}

void MessageBoxNormalUI::mouseMoveEvent(QMouseEvent *event) {
	if (_bDragFlag && (event->buttons() && Qt::LeftButton)) {
		move(event->globalPos() - _oDragPosition);
		event->accept();
	}
}

void MessageBoxNormalUI::mouseReleaseEvent(QMouseEvent *event) {
	_bDragFlag = false;
}
