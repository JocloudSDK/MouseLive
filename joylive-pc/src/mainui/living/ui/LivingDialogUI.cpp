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
			// 错误提示框
		}
		else {
			// 同意请求
			// 接收邀请
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
			// 错误提示框
		}
		else {
			// 同意请求
			// 接收邀请
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
	// 把 ClientEquipmentUI 放入
	_pClientEquipmentUI.reset(new ClientEquipmentUI(_oUI.centerListWidget));
	_pClientEquipmentUI->setObjectName(QStringLiteral("ClientEquipmentUI"));
	_pClientEquipmentUI->setGeometry(QRect(0, 0, 240, 637));
	_pClientEquipmentUI->setHttpLogic(_pLivingHttpLogic);

	connect(_pClientEquipmentUI.get(), SIGNAL(onLinkAnchor()), this, SLOT(onLinkAnchor()));
	connect(_pClientEquipmentUI.get(), SIGNAL(onPKRequest(int64_t, int64_t)), this, SLOT(onPKRequest(int64_t, int64_t)));
	connect(_pClientEquipmentUI.get(), SIGNAL(onBreakLink(int64_t, int64_t)), this, SLOT(onBreakLink(int64_t, int64_t)));
}

void LivingDialogUI::initBeautyUI() {
	// 把 ClientEquipmentUI 放入
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
	setWindowFlags(Qt::FramelessWindowHint);//无边框   
	//setAttribute(Qt::WA_TranslucentBackground);//背景透明。 背景不能透明，否则 SDK 不能绘画
	setAttribute(Qt::WA_QuitOnClose, true);

	setWindowTitle(QApplication::translate("AppInfo", "AppName", 0));
	setWindowIcon(QIcon(":/joy/app_ico"));

	_oUI.linkUserInfoWidget->setAttribute(Qt::WA_TranslucentBackground);
	_oUI.linkUserInfoWidget->hide();  // 有这个会挡住视频画面

	// 因为不能背景透明，所以不能设置边框
	//QGraphicsDropShadowEffect *shadowEffect = new QGraphicsDropShadowEffect();
	//shadowEffect->setBlurRadius(100);	//设置圆角半径 像素
	//shadowEffect->setColor(Qt::black);	// 设置边框颜色
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
		// 进入房间的是观众，可能会有2个人
		// 如果有连麦就是 MIDDLE，否则就是 SMALL
		// 测试 SMALL
		//if (RoomInfo::GetInstance()->_oLinkUserList.size() != 0) {
		//	_eWindowSizeType = WindowSizeType::MIDDLE;
		//}

		// 如果是观众
		_oUI.beginLivingBtn->hide();
		_eWindowSizeType = WindowSizeType::MIDDLE;
	}
		break;
	case RoomInfo::UserRole::Anchor:
	{
		// 进入房间的是主播，一定只有1个人
		// 现在一定是 SMALL
		// _eWindowSizeType = WindowSizeType::SMALL;

		// 如果是主播
		// 开播按钮先隐藏，出现刷新问题
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

	// 通过点击按钮后，触发获取 winid，会把窗口冻结，即不能绘画，所以启用定时器，通过回调的方式获取
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

	// 进入房间
	int ret = _pThunderMeetUI->joinRoom(LocalUserInfo::GetInstance()->_iUid,
		RoomInfo::GetInstance()->_iRoomId, "");
	Logd(TAG, Log(__FUNCTION__).setMessage("joinRoom ret:%d", ret));
	if (ret != 0) {
		// 提示框
		return;
	}

	// 进入 chatroom
	ChatRoomManager::GetInstance()->joinRoom();

	// ws 打开
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

	// 清空
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
	// 连麦 uid 也需要记录，记录到 room 中

	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));

	// 发送断开连麦请求
	auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
	if (u != RoomInfo::GetInstance()->_oLinkUserList.end()) {
		Logd(TAG, Log(__FUNCTION__).setMessage("in linking"));
		LiveManager::GetInstance()->hungupWithUser(QString::number((*u)->_iUid), QString::number((*u)->_iRoomId));

		// 如果不是同一个房间，需要刷新主播列表
		_pClientEquipmentUI->breakAnchor();
		_pThunderMeetUI->unsubcribe((*u)->_iUid, (*u)->_iRoomId);

		// 删除连麦用户
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
		// 如果是自己主播退出，需要退出提示，并退出房间
		// 弹出框
		// 直播已经结束
		MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "LiveEnd", 0), MessageBoxNormalUIShowType::LIVING_END, nullptr);
		onClickCloseBtn();
	}
	else {
		auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
		if (u != RoomInfo::GetInstance()->_oLinkUserList.end()) {
			if ((*u)->_iUid == uid.toInt()) {
				// 连麦人退出房间才走这里
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
	// 被邀请 显示提示框，查看 onClickOK， onClickCancel
	if (roomId.toInt() == RoomInfo::GetInstance()->_iRoomId) {
		// 同房间
		// 获取昵称
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
		// PK，其他主播的 昵称没有获取
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
	// 被接受
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
	// 被拒绝，显示提示框

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
	// 当前正在连麦，显示提示框
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
	// 断开连麦 这个先不使用
	//_pThunderMeetUI->unsubcribe(uid.toInt(), roomId.toInt());
	_pClientEquipmentUI->breakAnchor();
}

void LivingDialogUI::onAnchorConnected(const QString& uid, const QString& roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	// 和主播连麦成功

	RoomInfo::GetInstance()->_oLinkUserList.clear();
	std::shared_ptr<UserLinkInfo> u = std::make_shared<UserLinkInfo>();
	u->_iRoomId = roomId.toInt();
	u->_iUid = uid.toInt();
	RoomInfo::GetInstance()->_oLinkUserList.emplace_back(std::move(u));

	if (uid.toInt() == LocalUserInfo::GetInstance()->_iUid) {
		// 如果是自己
		initBigSize(); // 打开美颜
	}

	_pThunderMeetUI->subcribe(uid.toInt(), roomId.toInt());
	_pClientEquipmentUI->linkAnchorSuccess();
}

void LivingDialogUI::onAnchorDisconnected(const QString& uid, const QString& roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("roomId", roomId.toStdString()));
	// 主播断开我成功

	RoomInfo::GetInstance()->_oLinkUserList.clear();
	_pThunderMeetUI->unsubcribe(uid.toInt(), roomId.toInt());
	_pClientEquipmentUI->breakAnchor();

	if (uid.toInt() == LocalUserInfo::GetInstance()->_iUid) {
		// 如果是自己
		initMiddleSize(); // 关闭美颜
	}
}

void LivingDialogUI::onSendRequestFail(const QString& error) {
	// 先不做
}

void LivingDialogUI::onReceivedMessage(const QString& uid, const QString& message) {
	// 先不做
}

void LivingDialogUI::onReceivedRoomMessage(const QString& uid, const QString& message) {
	// 先不做
}

void LivingDialogUI::onUserBeKicked(const QString& uid) {
	// 先不做
}

void LivingDialogUI::onSelfBeKicked() {
	// 先不做
}

void LivingDialogUI::onUserMicStatusChanged(const QString& localUid, const QString& otherUid, bool state) {
	// 先不做
}

void LivingDialogUI::onRoomMicStatusChanged(bool micOn) {
	// 先不做
}

void LivingDialogUI::onUserMuteStatusChanged(const QString& uid, bool muted) {
	// 先不做
}

void LivingDialogUI::onRoomMuteStatusChanged(bool muted) {
	// 先不做
}

void LivingDialogUI::onUserRoleChanged(const QString& uid, bool hasRole) {
	// 先不做
}

void LivingDialogUI::onNetConnectedJ() {
	// 先不做
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
}

void LivingDialogUI::onNetClosedJ() {
	// 先不做
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
}

void LivingDialogUI::onNetConnectingJ() {
	// 先不做
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
}

void LivingDialogUI::onNetErrorJ(const QString& error) {
	// 提示框
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
}

void LivingDialogUI::onLinkAnchor() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	// 发送连麦请求
	if (!LiveManager::GetInstance()->applyConnectToUser(QString::number(RoomInfo::GetInstance()->_pRoomAnchor->_iUid),
		QString::number(RoomInfo::GetInstance()->_iRoomId))) {
		// 错误提示框
		//MessageBoxNormalUI::GetInstance()->showDialog(__FUNCTION__, MessageBoxNormalUI::ShowType::NOCLICK, nullptr);
	}
	else {
		// 等待 15 时间
		MessageBoxPKUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "SendMeetApply", 0), "", RoomInfo::GetInstance()->_pRoomAnchor->_iUid, RoomInfo::GetInstance()->_iRoomId,
			MessageBoxPKUIShowType::LIVINGUI_SEND_APPLY_MEET ,this, 15);
	}
}

void LivingDialogUI::onPKRequest(int64_t uid, int64_t roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", std::to_string(uid))
		.addDetail("roomId", std::to_string(roomId)));

	// 如果没有开播，不能PK
	if (RoomInfo::GetInstance()->_iRoomId == 0) {
		MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("LivingDialogUI", "LivingNotStart", 0), MessageBoxNormalUIShowType::LIVING_NOT_START_ERROR, nullptr);
		return;
	}

	// 发送 PK 请求
	if (!LiveManager::GetInstance()->applyConnectToUser(QString::number(uid), QString::number(roomId))) {
		// 错误提示框
		//MessageBoxNormalUI::GetInstance()->showDialog(__FUNCTION__, MessageBoxNormalUI::ShowType::NOCLICK, nullptr);
	}
	else {
		// 等待 15 时间
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
	// 隐藏断开连麦等控件
	_oUI.linkUserInfoWidget->hide();
	repaint();
}

void LivingDialogUI::onShowTwoCanvas() {
	repaint();
	// 显示断开连麦等控件

	// 昵称 + uid
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
	// 提示框
}

void LivingDialogUI::onSetChatIdSuccess(const QString& body) {
	SetChatIdResponse resp;
	SetChatIdResponse::FromJson(&resp, qstring2stdString(body));

	if (resp.Code != (int)HttpErrorCode::SUCCESS) {
		// 显示提示框
		return;
	}
}

void LivingDialogUI::onSetChatIdFailed() {

}

// 下边任务栏中点击关闭选项或者红叉
void LivingDialogUI::closeEvent(QCloseEvent *event) {
	if (!_bClose) {
		onClickCloseBtn();
	}
}

void LivingDialogUI::sendCreateRoomRequest() {
	// 1. 发送创建房间的请求

	CreateRoomRequest req;
	req.Uid = LocalUserInfo::GetInstance()->_iUid;
	req.RType = (int)RoomType::LIVE;  // 这里写入默认了
	req.RPublishMode = (int)PushMode::RTC;
	req.RLevel = 1; // 高清

	_pLivingHttpLogic->createRoom(QString::fromStdString(req.ToJson()));
}

void LivingDialogUI::onCreateRoomSuccess(const QString& body) {
	// 这块的流程上有点问题，应该是在点击 预览上的开播按钮才发送的
	CreateRoomResponse resp;
	CreateRoomResponse::FromJson(&resp, qstring2stdString(body));

	if (resp.Code != (int)HttpErrorCode::SUCCESS) {
		// 显示提示框
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

	// 添加自己 -- 这块是要改的，因为房主是要在最上面的
	std::shared_ptr<UserInfo> u = std::make_shared<UserInfo>();
	u->_iUid = LocalUserInfo::GetInstance()->_iUid;
	u->_bMicEnable = LocalUserInfo::GetInstance()->_bMicEnable;
	u->_bSelfMicEnable = LocalUserInfo::GetInstance()->_bSelfMicEnable;
	u->_iLinkRoomId = LocalUserInfo::GetInstance()->_iLinkRoomId;
	u->_iLinkUid = LocalUserInfo::GetInstance()->_iLinkUid;
	u->_strNickName = LocalUserInfo::GetInstance()->_strNickName;
	u->_strCover = LocalUserInfo::GetInstance()->_strCover;
	RoomInfo::GetInstance()->_oAllNormalUserList.emplace_back(u);

	// 点击开播按钮需要通知下
	_pClientEquipmentUI->videoStreamStart();

	linkUI();
}

void LivingDialogUI::onCreateRoomFailed() {
	// 1. 提示框
}
