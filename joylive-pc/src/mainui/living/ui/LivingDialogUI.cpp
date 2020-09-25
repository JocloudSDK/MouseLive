/*!
 * \file LivingDialogUI.cpp
 *
 * \author Zhangjianping
 * \date 2020/07/31
 * \contact 114695092@qq.com
 *
 * 
 */
#include "LivingDialogUI.h"
#include "../../../common/utils/String.h"
#include "ClientEquipmentUI.h"
#include "../../../common/websocket/LiveManager.h"
#include "../../baseui/MessageBoxPKUI.h"
#include "../../baseui/MessageBoxNormalUI.h"
#include "../../../common/log/loggerExt.h"
#include "../../../common/qss/QssLoad.h"
#include "../../../common/translate/Translate.h"
#include "../../../common/setting/Setting.h"
#include <thread>
#include <QGraphicsDropShadowEffect>

using namespace base;
static const char* TAG = "LivingDialogUI";

LivingDialogUI::LivingDialogUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	initEvent();
	initHttp();
	initWindow();
	initCenterList();
	initBeautyUI();
	initChatRoom();
	initThunderUI();
	initWS();

	Utils::QssLoad::Load(this, "LivingUI.qss");
}

LivingDialogUI::~LivingDialogUI() {
}

void LivingDialogUI::mousePressEvent(QMouseEvent *event) {
	if (event->button() == Qt::LeftButton) {
		_bDragFlag = true;
		_oDragPosition = event->globalPos() - this->pos();
		event->accept();
	}
}

void LivingDialogUI::mouseMoveEvent(QMouseEvent *event) {
	if (_bDragFlag && (event->buttons() && Qt::LeftButton)) {
		move(event->globalPos() - _oDragPosition);
		event->accept();
	}
}

void LivingDialogUI::mouseReleaseEvent(QMouseEvent *event) {
	_bDragFlag = false;
}

void LivingDialogUI::onClickMsgOKBtn(MessageBoxNormalUIShowType t) {
	// do nothing
}

void LivingDialogUI::onClickMsgCancelBtn(MessageBoxNormalUIShowType t) {
	// do nothing
}

void LivingDialogUI::onClickLinkOK(int64_t uid, int64_t roomId, MessageBoxPKUIShowType t) {
	switch (t) {
	case MessageBoxPKUIShowType::LIVINGUI_BE_APPLY_PK:
	{
		if (!LiveManager::GetInstance()->acceptConnectWithUser(QString::number(uid))) {
			// ������ʾ��
		}
		else {
			// ͬ������
			// ��������
			RoomInfo::GetInstance()->_oLinkUserList.clear();
			std::shared_ptr<UserLinkInfo> u = std::make_shared<UserLinkInfo>();
			u->_iRoomId = roomId;
			u->_iUid = uid;
			RoomInfo::GetInstance()->_oLinkUserList.emplace_back(std::move(u));
			_pThunderMeetUI->subcribe(uid, roomId);
			_pClientEquipmentUI->pkAnchorSuccess(uid);
		}
	}
		break;
	case MessageBoxPKUIShowType::LIVINGUI_BE_APPLY_MEET:
	{
		if (!LiveManager::GetInstance()->acceptConnectWithUser(QString::number(uid))) {
			// ������ʾ��
		}
		else {
			// ͬ������
			// ��������
			RoomInfo::GetInstance()->_oLinkUserList.clear();
			std::shared_ptr<UserLinkInfo> u = std::make_shared<UserLinkInfo>();
			u->_iRoomId = roomId;
			u->_iUid = uid;
			RoomInfo::GetInstance()->_oLinkUserList.emplace_back(std::move(u));
			_pThunderMeetUI->subcribe(uid, roomId);
			_pClientEquipmentUI->linkAnchorSuccess();
		}
	}
		break;
	}
}

void LivingDialogUI::onClickLinkCancel(int64_t uid, int64_t roomId, MessageBoxPKUIShowType t) {
	switch (t) {
	case MessageBoxPKUIShowType::LIVINGUI_BE_APPLY_PK:
	case MessageBoxPKUIShowType::LIVINGUI_BE_APPLY_MEET:
	{
		LiveManager::GetInstance()->refuseConnectWithUser(QString::number(uid));
		_pClientEquipmentUI->breakAnchor();
	}
		break;
	case MessageBoxPKUIShowType::LIVINGUI_SEND_APPLY_PK:
	case MessageBoxPKUIShowType::LIVINGUI_SEND_APPLY_MEET:
	{
		LiveManager::GetInstance()->cancelConnectToUser();
		_pClientEquipmentUI->breakAnchor();
	}
		break;
	}
}

void LivingDialogUI::initCenterList() {
	// �� ClientEquipmentUI ����
	_pClientEquipmentUI.reset(new ClientEquipmentUI(_oUI.centerListWidget));
	_pClientEquipmentUI->setObjectName(QStringLiteral("ClientEquipmentUI"));
	_pClientEquipmentUI->setGeometry(QRect(0, 0, 240, 637));
	_pClientEquipmentUI->setHttpLogic(_pLivingHttpLogic);

	connect(_pClientEquipmentUI.get(), SIGNAL(onLinkAnchor()), this, SLOT(onLinkAnchor()));
	connect(_pClientEquipmentUI.get(), SIGNAL(onPKRequest(int64_t, int64_t)), this, SLOT(onPKRequest(int64_t, int64_t)));
	connect(_pClientEquipmentUI.get(), SIGNAL(onBreakLink(int64_t, int64_t)), this, SLOT(onBreakLink(int64_t, int64_t)));
}

void LivingDialogUI::initBeautyUI() {
	// �� ClientEquipmentUI ����
	_pBeautyUI.reset(new BeautyUI(_oUI.rightBeautyWidget));
	_pBeautyUI->setObjectName(QStringLiteral("BeautyUI"));
	_pBeautyUI->setGeometry(QRect(0, 0, 240, 624));
	_pBeautyUI->setEnable(false);

	//connect(_pClientEquipmentUI.get(), SIGNAL(onLinkAnchor()), this, SLOT(onLinkAnchor()));
	//connect(_pClientEquipmentUI.get(), SIGNAL(onPKRequest(int64_t, int64_t)), this, SLOT(onPKRequest(int64_t, int64_t)));
	//connect(_pClientEquipmentUI.get(), SIGNAL(onBreakLink(int64_t, int64_t)), this, SLOT(onBreakLink(int64_t, int64_t)));
}


void LivingDialogUI::initThunderUI() {
	_pThunderMeetUI.reset(new ThunderMeetUI);
	connect(_pThunderMeetUI.get(), SIGNAL(onShowOneCanvas()), this, SLOT(onShowOneCanvas()));
	connect(_pThunderMeetUI.get(), SIGNAL(onShowTwoCanvas()), this, SLOT(onShowTwoCanvas()));
}

void LivingDialogUI::initEvent() {
	connect(_oUI.minBtn, SIGNAL(clicked()), this, SLOT(onClickMinBtn()));
	connect(_oUI.closeBtn, SIGNAL(clicked()), this, SLOT(onClickCloseBtn()));
	connect(_oUI.linkBreakBtn, SIGNAL(clicked(bool)), this, SLOT(onClickLinkBreakBtn(bool)));
	connect(_oUI.beginLivingBtn, SIGNAL(clicked(bool)), this, SLOT(onClickBeginLivingBtn(bool)));
}

void LivingDialogUI::initWindow() {
	setWindowFlags(Qt::FramelessWindowHint);//�ޱ߿�   
	//setAttribute(Qt::WA_TranslucentBackground);//����͸���� ��������͸�������� SDK ���ܻ滭
	setAttribute(Qt::WA_QuitOnClose, true);

	setWindowTitle(QApplication::translate("AppInfo", "AppName", 0));
	setWindowIcon(QIcon(":/joy/app_ico"));

	_oUI.linkUserInfoWidget->setAttribute(Qt::WA_TranslucentBackground);
	_oUI.linkUserInfoWidget->hide();  // ������ᵲס��Ƶ����

	// ��Ϊ���ܱ���͸�������Բ������ñ߿�
	//QGraphicsDropShadowEffect *shadowEffect = new QGraphicsDropShadowEffect();
	//shadowEffect->setBlurRadius(100);	//����Բ�ǰ뾶 ����
	//shadowEffect->setColor(Qt::black);	// ���ñ߿���ɫ
	//shadowEffect->setOffset(5);

	//_oUI.verticalWidget->setGraphicsEffect(shadowEffect);
}

void LivingDialogUI::initWS() {
	connect(LiveManager::GetInstance(), SIGNAL(onUserJoin(const QString&)), this, SLOT(onUserJoin(const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onUserLeave(const QString&)), this, SLOT(onUserLeave(const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onBeInvited(const QString&, const QString&)), this, SLOT(onBeInvited(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onInviteCancel(const QString&, const QString&)), this, SLOT(onInviteCancel(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onInviteAccept(const QString&, const QString&)), this, SLOT(onInviteAccept(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onInviteRefuse(const QString&, const QString&)), this, SLOT(onInviteRefuse(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onInviteTimeout(const QString&, const QString&)), this, SLOT(onInviteTimeout(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onInviteRunning(const QString&, const QString&)), this, SLOT(onInviteRunning(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onReceiveHungupRequest(const QString&, const QString&)), this, SLOT(onReceiveHungupRequest(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onAnchorConnected(const QString&, const QString&)), this, SLOT(onAnchorConnected(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onAnchorDisconnected(const QString&, const QString&)), this, SLOT(onAnchorDisconnected(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onSendRequestFail(const QString&)), this, SLOT(onSendRequestFail(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onReceivedMessage(const QString&, const QString&)), this, SLOT(onReceivedMessage(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onReceivedRoomMessage(const QString&, const QString&)), this, SLOT(onReceivedRoomMessage(const QString&, const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onUserBeKicked(const QString&)), this, SLOT(onUserBeKicked(const QString&)));
	connect(LiveManager::GetInstance(), SIGNAL(onSelfBeKicked()), this, SLOT(onSelfBeKicked()));
	connect(LiveManager::GetInstance(), SIGNAL(onUserMicStatusChanged(const QString&, const QString&, bool)), this, SLOT(onUserMicStatusChanged(const QString&, const QString&, bool state)));
	connect(LiveManager::GetInstance(), SIGNAL(onRoomMicStatusChanged(bool)), this, SLOT(onUserBeKicked(bool)));
	connect(LiveManager::GetInstance(), SIGNAL(onUserMuteStatusChanged(const QString&, bool)), this, SLOT(onUserMuteStatusChanged(const QString&, bool)));
	connect(LiveManager::GetInstance(), SIGNAL(onRoomMuteStatusChanged(bool)), this, SLOT(onRoomMuteStatusChanged(bool)));
	connect(LiveManager::GetInstance(), SIGNAL(onUserRoleChanged(const QString, bool)), this, SLOT(onUserRoleChanged(const QString, bool)));
	connect(LiveManager::GetInstance(), SIGNAL(onNetConnectedJ()), this, SLOT(onNetConnectedJ()));
	connect(LiveManager::GetInstance(), SIGNAL(onNetClosedJ()), this, SLOT(onNetClosedJ()));
	connect(LiveManager::GetInstance(), SIGNAL(onNetConnectingJ()), this, SLOT(onNetConnectingJ()));
	connect(LiveManager::GetInstance(), SIGNAL(onNetErrorJ(const QString&)), this, SLOT(onNetErrorJ(const QString&)));
}

void LivingDialogUI::initChatRoom() {
	connect(ChatRoomManager::GetInstance(), SIGNAL(onJoinChatRoomSuccess(int64_t)), this, SLOT(onJoinChatRoomSuccess(int64_t)));
	connect(ChatRoomManager::GetInstance(), SIGNAL(onJoinChatRoomFailed()), this, SLOT(onJoinChatRoomFailed()));
}

void LivingDialogUI::initHttp() {
	_pLivingHttpLogic.reset(new LivingHttpLogic());
	connect(_pLivingHttpLogic.get(), SIGNAL(onSetChatIdSuccess(const QString&)), this, SLOT(onSetChatIdSuccess(const QString&)));
	connect(_pLivingHttpLogic.get(), SIGNAL(onSetChatIdFailed()), this, SLOT(onSetChatIdFailed()));
	connect(_pLivingHttpLogic.get(), SIGNAL(onCreateRoomSuccess(const QString&)), this, SLOT(onCreateRoomSuccess(const QString&)));
	connect(_pLivingHttpLogic.get(), SIGNAL(onCreateRoomFailed()), this, SLOT(onCreateRoomFailed()));
}

void LivingDialogUI::initMode() {
	WindowSizeType to = WindowSizeType::SMALL;
	switch (RoomInfo::GetInstance()->_eUserRole) {
	case RoomInfo::UserRole::Viewer:
	{
		// ���뷿����ǹ��ڣ����ܻ���2����
		// ������������ MIDDLE��������� SMALL
		// ���� SMALL
		//if (RoomInfo::GetInstance()->_oLinkUserList.size() != 0) {
		//	_eWindowSizeType = WindowSizeType::MIDDLE;
		//}

		// ����ǹ���
		_oUI.beginLivingBtn->hide();
		_eWindowSizeType = WindowSizeType::MIDDLE;
	}
		break;
	case RoomInfo::UserRole::Anchor:
	{
		// ���뷿�����������һ��ֻ��1����
		// ����һ���� SMALL
		// _eWindowSizeType = WindowSizeType::SMALL;

		// ���������
		// ������ť�����أ�����ˢ������
		//_oUI.beginLivingBtn->hide();

		_eWindowSizeType = WindowSizeType::BIG;
	}
		break;
	default:
		break;
	}
	_pBeautyUI->resetUI();
	switchDialog(WindowSizeType::UNKNOWN, _eWindowSizeType);
}

void LivingDialogUI::initLogoView() {
	int l = Setting::GetInstance()->readInt(STR_CONFIG_LANGUAGE);
	if (l == Translator::EN) {
		_oUI.logoGraphicsView->setStyleSheet(QStringLiteral("background-image: url(:/joy/logo_en);"));
	}
	else {
		_oUI.logoGraphicsView->setStyleSheet(QStringLiteral("background-image: url(:/joy/logo_zh);"));
	}
}

void LivingDialogUI::showDialog() {
	initLogoView();
	this->initMode();
	_pClientEquipmentUI->resetUI();

	// ͨ�������ť�󣬴�����ȡ winid����Ѵ��ڶ��ᣬ�����ܻ滭���������ö�ʱ����ͨ���ص��ķ�ʽ��ȡ
	_oShowTimer.setInterval(1);
	_oShowTimer.setSingleShot(true);
	connect(&_oShowTimer, SIGNAL(timeout()), this, SLOT(onTimeout()));
	_oShowTimer.start();
	this->show();
}

void LivingDialogUI::onTimeout() {
	if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Anchor) {
		beforeLiving();
	}
	else {
		linkUI();
	}
}

void LivingDialogUI::hideDialog() {
	leaveRoom();
	this->close();
}

void LivingDialogUI::changeLanguage() {
	_oUI.retranslateUi(this);
	_pBeautyUI->changeLanguage();
	_pClientEquipmentUI->changeLanguage();

	_oUI.roomIDLabel->setText(QString("RoomID: %1").arg(RoomInfo::GetInstance()->_iRoomId));
	_oUI.anchorIDLabel->setText(QString("UID: %1").arg(RoomInfo::GetInstance()->_pRoomAnchor->_iUid));

	QString strNick = QApplication::translate("LivingDialogUI", "NickLabel", 0);
	strNick += ": ";
	strNick += RoomInfo::GetInstance()->_pRoomAnchor->_strNickName;
	_oUI.nickLabel->setText(strNick);

	QString strRoomName = QApplication::translate("LivingDialogUI", "RoomNameLabel", 0);
	strRoomName += ": ";
	strRoomName += RoomInfo::GetInstance()->_strRoomName;
	_oUI.roomNameLabel->setText(strRoomName);

	initLogoView();
	setWindowTitle(QApplication::translate("AppInfo", "AppName", 0));
}

void LivingDialogUI::beforeLiving() {
	_oUI.roomIDLabel->setText(QString("RoomId:%1").arg(RoomInfo::GetInstance()->_iRoomId));
	_oUI.anchorIDLabel->setText(QString("UID:%1").arg(RoomInfo::GetInstance()->_pRoomAnchor->_iUid));

	QString strNick = QApplication::translate("LivingDialogUI", "NickLabel", 0);
	strNick += ": ";
	strNick += RoomInfo::GetInstance()->_pRoomAnchor->_strNickName;
	_oUI.nickLabel->setText(strNick);

	QString strRoomName = QApplication::translate("LivingDialogUI", "RoomNameLabel", 0);
	strRoomName += ": ";
	strRoomName += RoomInfo::GetInstance()->_strRoomName;
	_oUI.roomNameLabel->setText(strRoomName);

	_pThunderMeetUI->setLeftAndRightView(_oUI.anchorViewWidget, _oUI.linkViewWidget);
	_pThunderMeetUI->resetUI();
	_pThunderMeetUI->beginLiving();
}

void LivingDialogUI::linkUI() {
	_oUI.roomIDLabel->setText(QString("RoomId: %1").arg(RoomInfo::GetInstance()->_iRoomId));
	_oUI.anchorIDLabel->setText(QString("UID: %1").arg(RoomInfo::GetInstance()->_pRoomAnchor->_iUid));
	
	QString strNick = QApplication::translate("LivingDialogUI", "NickLabel", 0);
	strNick += ":";
	strNick += RoomInfo::GetInstance()->_pRoomAnchor->_strNickName;
	_oUI.nickLabel->setText(strNick);

	QString strRoomName = QApplication::translate("LivingDialogUI", "RoomNameLabel", 0);
	strRoomName += ":";
	strRoomName += RoomInfo::GetInstance()->_strRoomName;
	_oUI.roomNameLabel->setText(strRoomName);

	_pThunderMeetUI->setLeftAndRightView(_oUI.anchorViewWidget, _oUI.linkViewWidget);
	_pThunderMeetUI->resetUI();

	// ���뷿��
	int ret = _pThunderMeetUI->joinRoom(LocalUserInfo::GetInstance()->_iUid,
		RoomInfo::GetInstance()->_iRoomId, "");
	Logd(TAG, Log(__FUNCTION__).setMessage("joinRoom ret:%d", ret));
	if (ret != 0) {
		// ��ʾ��
		return;
	}

	// ���� chatroom
	ChatRoomManager::GetInstance()->joinRoom();

	// ws ��
	LiveManager::GetInstance()->joinWSRoom();
}

void LivingDialogUI::switchDialog(WindowSizeType from, WindowSizeType to) {
	_eWindowSizeType = to;

	switch (_eWindowSizeType)
	{
	case LivingDialogUI::BIG:
	{
		if (from == LivingDialogUI::UNKNOWN) {
			initBigSize();
		}
	}
		break;
	case LivingDialogUI::MIDDLE:
	{
		if (from == LivingDialogUI::UNKNOWN) {
			initMiddleSize();
		}
	}
		break;
	case LivingDialogUI::SMALL:
	{
		if (from == LivingDialogUI::UNKNOWN) {
			initSmallSize();
		}
	}
		break;
	default:
		break;
	}
}

void LivingDialogUI::initBigSize() {
	_oUI.linkViewWidget->hide();
	_oUI.rightBeautyWidget->show();
	this->resize(1352, 690);
	this->setMinimumSize(QSize(1352, 690));
	this->setMaximumSize(QSize(1352, 690));

	_pBeautyUI->setEnable(true);
}

void LivingDialogUI::initMiddleSize() {
	if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Viewer) {
		_oUI.linkViewWidget->hide();
		_oUI.rightBeautyWidget->hide();
		this->resize(1092, 690);
		this->setMinimumSize(QSize(1092, 690));
		this->setMaximumSize(QSize(1092, 690));

		_pBeautyUI->setEnable(false);
	}
}

void LivingDialogUI::initSmallSize() {
	_oUI.linkViewWidget->hide();
	_oUI.rightBeautyWidget->hide();
	this->resize(821, 702);
	this->setMinimumSize(QSize(821, 702));
	this->setMaximumSize(QSize(821, 702));
	_pBeautyUI->setEnable(false);
}

void LivingDialogUI::leaveRoom() {
	ChatRoomManager::GetInstance()->leaveRoom();
	_pThunderMeetUI->leaveRoom();
	LiveManager::GetInstance()->leaveWSRoom();

	// ���
	RoomInfo::GetInstance()->clearAll();
}

void LivingDialogUI::onClickMinBtn() {
	this->showMinimized();
}

void LivingDialogUI::onClickCloseBtn() {
	_bClose = true;
	leaveRoom();
	this->close();
	emit onLivingUILeaveRoom();
}

void LivingDialogUI::onClickBeginLivingBtn(bool) {
	_oUI.beginLivingBtn->hide();
	sendCreateRoomRequest();
}

void LivingDialogUI::onClickLinkBreakBtn(bool) {
	// ���� uid Ҳ��Ҫ��¼����¼�� room ��

	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));

	// ���ͶϿ���������
	auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
	if (u != RoomInfo::GetInstance()->_oLinkUserList.end()) {
		Logd(TAG, Log(__FUNCTION__).setMessage("in linking"));
		LiveManager::GetInstance()->hungupWithUser(QString::number((*u)->_iUid), QString::number((*u)->_iRoomId));

		// �������ͬһ�����䣬��Ҫˢ�������б�
		_pClientEquipmentUI->breakAnchor();
		_pThunderMeetUI->unsubcribe((*u)->_iUid, (*u)->_iRoomId);

		// ɾ�������û�
		RoomInfo::GetInstance()->_oLinkUserList.erase(u);
	}
}

void LivingDialogUI::onUserJoin(const QString& uid) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString()));
	std::shared_ptr<UserInfo> u = std::make_shared<UserInfo>();
	u->_iUid = uid.toInt();
	RoomInfo::GetInstance()->pushUserList(std::move(u));
	_pClientEquipmentUI->userJoin();
}

void LivingDialogUI::onUserLeave(const QString& uid) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString()));
	if (uid.toInt() == RoomInfo::GetInstance()->_pRoomAnchor->_iUid) {
		// ������Լ������˳�����Ҫ�˳���ʾ�����˳�����
		// ������
		// ֱ���Ѿ�����
		MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "LiveEnd", 0), MessageBoxNormalUIShowType::LIVING_END, nullptr);
		onClickCloseBtn();
	}
	else {
		auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
		if (u != RoomInfo::GetInstance()->_oLinkUserList.end()) {
			if ((*u)->_iUid == uid.toInt()) {
				// �������˳������������
				_pThunderMeetUI->unsubcribe((*u)->_iUid, (*u)->_iRoomId);
				_pClientEquipmentUI->breakAnchor();
			}

			RoomInfo::GetInstance()->_oLinkUserList.clear();
		}

		RoomInfo::GetInstance()->popUserList(uid.toInt());
		_pClientEquipmentUI->userLeave(uid);
	}
}

void LivingDialogUI::onBeInvited(const QString& uid, const QString& roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	// ������ ��ʾ��ʾ�򣬲鿴 onClickOK�� onClickCancel
	if (roomId.toInt() == RoomInfo::GetInstance()->_iRoomId) {
		// ͬ����
		// ��ȡ�ǳ�
		QString strNick = "";
		QString strCover = "";
		for (auto u = RoomInfo::GetInstance()->_oAllNormalUserList.begin();
			u != RoomInfo::GetInstance()->_oAllNormalUserList.end();
			u++) {
			if ((*u)->_iUid == uid.toInt()) {
				strNick = (*u)->_strNickName;
				strCover = (*u)->_strCover;
				break;
			}
		}

		strNick += QApplication::translate("LivingDialogUI", "Meet", 0);
		MessageBoxPKUI::GetInstance()->showDialog(strNick, strCover, uid.toInt(), roomId.toInt(),
			MessageBoxPKUIShowType::LIVINGUI_BE_APPLY_MEET, this, 15);
	}
	else {
		// PK������������ �ǳ�û�л�ȡ
		QString strNick = uid;
		QString strCover = "";
		strNick += QApplication::translate("LivingDialogUI", "PK", 0);
		MessageBoxPKUI::GetInstance()->showDialog(strNick, strCover, uid.toInt(), roomId.toInt(),
			MessageBoxPKUIShowType::LIVINGUI_BE_APPLY_PK, this, 15);
	}
}

void LivingDialogUI::onInviteCancel(const QString& uid, const QString& roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	MessageBoxPKUI::GetInstance()->hideDialog();
	_pClientEquipmentUI->breakAnchor();
}

void LivingDialogUI::onInviteAccept(const QString& uid, const QString& roomId) {
	// ������
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	RoomInfo::GetInstance()->_oLinkUserList.clear();
	std::shared_ptr<UserLinkInfo> u = std::make_shared<UserLinkInfo>();
	u->_iRoomId = roomId.toInt();
	u->_iUid = uid.toInt();
	RoomInfo::GetInstance()->_oLinkUserList.emplace_back(std::move(u));

	_pThunderMeetUI->subcribe(uid.toInt(), roomId.toInt());

	if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Anchor) {
		_pClientEquipmentUI->pkAnchorSuccess(uid.toInt());
	}
	else {
		_pClientEquipmentUI->linkAnchorSuccess();
	}

	MessageBoxPKUI::GetInstance()->hideDialog();
}

void LivingDialogUI::onInviteRefuse(const QString& uid, const QString& roomId) {
	// ���ܾ�����ʾ��ʾ��

	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	MessageBoxPKUI::GetInstance()->hideDialog();
	MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "RefuseByAnchor", 0), MessageBoxNormalUIShowType::LIVINGUI_BE_REFUSED, nullptr);
	_pClientEquipmentUI->breakAnchor();
}

void LivingDialogUI::onInviteTimeout(const QString& uid, const QString& roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	_pClientEquipmentUI->breakAnchor();
}

void LivingDialogUI::onInviteRunning(const QString& uid, const QString& roomId) {
	// ��ǰ����������ʾ��ʾ��
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	MessageBoxPKUI::GetInstance()->hideDialog();
	if (RoomInfo::GetInstance()->_iRoomId != roomId.toInt()) {
		MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "PKLingPleaseWait", 0), MessageBoxNormalUIShowType::LIVINGUI_PKING_WAIT, nullptr);
	}
	else {
		MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "LinkingPleaseWait", 0), MessageBoxNormalUIShowType::LIVINGUI_PKING_WAIT, nullptr);
	}
	_pClientEquipmentUI->breakAnchor();
}

void LivingDialogUI::onReceiveHungupRequest(const QString& uid, const QString& roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	// �Ͽ����� ����Ȳ�ʹ��
	//_pThunderMeetUI->unsubcribe(uid.toInt(), roomId.toInt());
	_pClientEquipmentUI->breakAnchor();
}

void LivingDialogUI::onAnchorConnected(const QString& uid, const QString& roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	// ����������ɹ�

	RoomInfo::GetInstance()->_oLinkUserList.clear();
	std::shared_ptr<UserLinkInfo> u = std::make_shared<UserLinkInfo>();
	u->_iRoomId = roomId.toInt();
	u->_iUid = uid.toInt();
	RoomInfo::GetInstance()->_oLinkUserList.emplace_back(std::move(u));

	if (uid.toInt() == LocalUserInfo::GetInstance()->_iUid) {
		// ������Լ�
		initBigSize(); // ������
	}

	_pThunderMeetUI->subcribe(uid.toInt(), roomId.toInt());
	_pClientEquipmentUI->linkAnchorSuccess();
}

void LivingDialogUI::onAnchorDisconnected(const QString& uid, const QString& roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	// �����Ͽ��ҳɹ�

	RoomInfo::GetInstance()->_oLinkUserList.clear();
	_pThunderMeetUI->unsubcribe(uid.toInt(), roomId.toInt());
	_pClientEquipmentUI->breakAnchor();

	if (uid.toInt() == LocalUserInfo::GetInstance()->_iUid) {
		// ������Լ�
		initMiddleSize(); // �ر�����
	}
}

void LivingDialogUI::onSendRequestFail(const QString& error) {
	// �Ȳ���
}

void LivingDialogUI::onReceivedMessage(const QString& uid, const QString& message) {
	// �Ȳ���
}

void LivingDialogUI::onReceivedRoomMessage(const QString& uid, const QString& message) {
	// �Ȳ���
}

void LivingDialogUI::onUserBeKicked(const QString& uid) {
	// �Ȳ���
}

void LivingDialogUI::onSelfBeKicked() {
	// �Ȳ���
}

void LivingDialogUI::onUserMicStatusChanged(const QString& localUid, const QString& otherUid, bool state) {
	// �Ȳ���
}

void LivingDialogUI::onRoomMicStatusChanged(bool micOn) {
	// �Ȳ���
}

void LivingDialogUI::onUserMuteStatusChanged(const QString& uid, bool muted) {
	// �Ȳ���
}

void LivingDialogUI::onRoomMuteStatusChanged(bool muted) {
	// �Ȳ���
}

void LivingDialogUI::onUserRoleChanged(const QString& uid, bool hasRole) {
	// �Ȳ���
}

void LivingDialogUI::onNetConnectedJ() {
	// �Ȳ���
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
}

void LivingDialogUI::onNetClosedJ() {
	// �Ȳ���
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
}

void LivingDialogUI::onNetConnectingJ() {
	// �Ȳ���
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
}

void LivingDialogUI::onNetErrorJ(const QString& error) {
	// ��ʾ��
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
}

void LivingDialogUI::onLinkAnchor() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	// ������������
	if (!LiveManager::GetInstance()->applyConnectToUser(QString::number(RoomInfo::GetInstance()->_pRoomAnchor->_iUid),
		QString::number(RoomInfo::GetInstance()->_iRoomId))) {
		// ������ʾ��
		//MessageBoxNormalUI::GetInstance()->showDialog(__FUNCTION__, MessageBoxNormalUI::ShowType::NOCLICK, nullptr);
	}
	else {
		// �ȴ� 15 ʱ��
		MessageBoxPKUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "SendMeetApply", 0), "", RoomInfo::GetInstance()->_pRoomAnchor->_iUid, RoomInfo::GetInstance()->_iRoomId,
			MessageBoxPKUIShowType::LIVINGUI_SEND_APPLY_MEET ,this, 15);
	}
}

void LivingDialogUI::onPKRequest(int64_t uid, int64_t roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", std::to_string(uid))
		.addDetail("roomId", std::to_string(roomId)));

	// ���û�п���������PK
	if (RoomInfo::GetInstance()->_iRoomId == 0) {
		MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "LivingNotStart", 0), MessageBoxNormalUIShowType::LIVING_NOT_START_ERROR, nullptr);
		return;
	}

	// ���� PK ����
	if (!LiveManager::GetInstance()->applyConnectToUser(QString::number(uid), QString::number(roomId))) {
		// ������ʾ��
		//MessageBoxNormalUI::GetInstance()->showDialog(__FUNCTION__, MessageBoxNormalUI::ShowType::NOCLICK, nullptr);
	}
	else {
		// �ȴ� 15 ʱ��
		MessageBoxPKUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "SendPKApply", 0), "", uid, roomId,
			MessageBoxPKUIShowType::LIVINGUI_SEND_APPLY_PK, this, 15);
	}
}

void LivingDialogUI::onBreakLink(int64_t uid, int64_t roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", std::to_string(uid))
		.addDetail("roomId", std::to_string(roomId)));
	onClickLinkBreakBtn(true);
}

void LivingDialogUI::onSelectPublishMode(int m) {
	_pThunderMeetUI->setCurrentPublishMode((VideoPublishMode)m);
}

void LivingDialogUI::onShowOneCanvas() {
	// ���ضϿ�����ȿؼ�
	_oUI.linkUserInfoWidget->hide();
	repaint();
}

void LivingDialogUI::onShowTwoCanvas() {
	repaint();
	// ��ʾ�Ͽ�����ȿؼ�

	// �ǳ� + uid
	//_oUI.linkUserNickLabel.setText();
	//_oUI.linkUserUIdLabel->setText();
	//_oUI.linkUserInfoWidget->show();
}

void LivingDialogUI::onJoinChatRoomSuccess(int64_t chatRoomId) {
	RoomInfo::GetInstance()->_iChatId = chatRoomId;

	SetChatIdRequest req;
	req.RChatId = chatRoomId;
	req.RoomId = RoomInfo::GetInstance()->_iRoomId;
	req.RType = (int)RoomType::LIVE;
	req.Uid = LocalUserInfo::GetInstance()->_iUid;
	_pLivingHttpLogic->setChatId(stdString2QString(req.ToJson()));
}

void LivingDialogUI::onJoinChatRoomFailed() {
	// ��ʾ��
}

void LivingDialogUI::onSetChatIdSuccess(const QString& body) {
	SetChatIdResponse resp;
	SetChatIdResponse::FromJson(&resp, qstring2stdString(body));

	if (resp.Code != (int)HttpErrorCode::SUCCESS) {
		// ��ʾ��ʾ��
		return;
	}
}

void LivingDialogUI::onSetChatIdFailed() {

}

// �±��������е���ر�ѡ����ߺ��
void LivingDialogUI::closeEvent(QCloseEvent *event) {
	if (!_bClose) {
		onClickCloseBtn();
	}
}

void LivingDialogUI::sendCreateRoomRequest() {
	// 1. ���ʹ������������

	CreateRoomRequest req;
	req.Uid = LocalUserInfo::GetInstance()->_iUid;
	req.RType = (int)RoomType::LIVE;  // ����д��Ĭ����
	req.RPublishMode = (int)PushMode::RTC;
	req.RLevel = 1; // ����

	_pLivingHttpLogic->createRoom(QString::fromStdString(req.ToJson()));
}

void LivingDialogUI::onCreateRoomSuccess(const QString& body) {
	// �����������е����⣬Ӧ�����ڵ�� Ԥ���ϵĿ�����ť�ŷ��͵�
	CreateRoomResponse resp;
	CreateRoomResponse::FromJson(&resp, qstring2stdString(body));

	if (resp.Code != (int)HttpErrorCode::SUCCESS) {
		// ��ʾ��ʾ��
		return;
	}

	RoomInfo::GetInstance()->clearAll();
	RoomInfo::GetInstance()->_eRoomType = (RoomType)resp.Data.RType;
	RoomInfo::GetInstance()->_iRoomId = resp.Data.RoomId;
	RoomInfo::GetInstance()->_eUserRole = RoomInfo::UserRole::Anchor;
	RoomInfo::GetInstance()->_iChatId = resp.Data.RChatId;
	RoomInfo::GetInstance()->_strRoomName = stdString2QString(resp.Data.RName);
	RoomInfo::GetInstance()->_pRoomAnchor->_strNickName = stdString2QString(resp.Data.ROwner.NickName);
	RoomInfo::GetInstance()->_pRoomAnchor->_strCover = stdString2QString(resp.Data.ROwner.Cover);
	RoomInfo::GetInstance()->_pRoomAnchor->_iUid = resp.Data.ROwner.Uid;

	// ����Լ� -- �����Ҫ�ĵģ���Ϊ������Ҫ���������
	std::shared_ptr<UserInfo> u = std::make_shared<UserInfo>();
	u->_iUid = LocalUserInfo::GetInstance()->_iUid;
	u->_bMicEnable = LocalUserInfo::GetInstance()->_bMicEnable;
	u->_bSelfMicEnable = LocalUserInfo::GetInstance()->_bSelfMicEnable;
	u->_iLinkRoomId = LocalUserInfo::GetInstance()->_iLinkRoomId;
	u->_iLinkUid = LocalUserInfo::GetInstance()->_iLinkUid;
	u->_strNickName = LocalUserInfo::GetInstance()->_strNickName;
	u->_strCover = LocalUserInfo::GetInstance()->_strCover;
	RoomInfo::GetInstance()->_oAllNormalUserList.emplace_back(u);

	// ���������ť��Ҫ֪ͨ��
	_pClientEquipmentUI->videoStreamStart();

	linkUI();
}

void LivingDialogUI::onCreateRoomFailed() {
	// 1. ��ʾ��
}
