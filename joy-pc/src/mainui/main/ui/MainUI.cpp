#include "MainUI.h"
#include <windows.h>
#include <corecrt_io.h>
#include "../../../common/log/loggerExt.h"
#include "../../../common/utils/String.h"
#include "../../sdk/thunderbolt/MediaManager.h"
#include "../../../common/setting/Setting.h"
#include "../logic/MainHttpLogic.h"
#include "../../UserInfo.h"
#include "../../../common/qss/QssLoad.h"
#include "../../sdk/beauty/BeautyManager.h"

#include <QDir>
#include <QStandardItemModel>
#include <qDebug>
#include <QScrollBar>
#include <QGraphicsDropShadowEffect>

using namespace base;
static const char* TAG = "MainUI";

MainUI::MainUI(QWidget *parent)
	: QMainWindow(parent) {

	// TODO: need to create later
	MediaManager::create();
	MediaManager::instance()->init(qstring2stdString(STR_APPID).c_str(), 0);
	MediaManager::instance()->getThunderManager()->setArea(AREA_DEFAULT);

	initHttp();

	initLog();

	BeautyManager::GetInstance()->setup();

	Setting::GetInstance()->setConfigPath(QCoreApplication::applicationDirPath() + STR_CONFIG_PATH);

	initLanguage();

	_oUI.setupUi(this);

	initLanguageBtn();

	resetAppNumber();

	initEvent();

	initWindow();

	initChatRoom();

	sendLoginRequest();

	Utils::QssLoad::Load(this, "MainUI.qss");
}

MainUI::~MainUI() {
	uinitLog();
	MediaManager::release();
	Setting::ReleaseInstance();
	Translator::ReleaseInstance();
	BeautyManager::ReleaseInstance();
}

void MainUI::initWindow() {
	setWindowFlags(Qt::FramelessWindowHint);//�ޱ߿�   
	setAttribute(Qt::WA_TranslucentBackground);//����͸��
	setAttribute(Qt::WA_QuitOnClose, true);

	_oUI.roomlistWidget->setSelectionMode(QAbstractItemView::NoSelection);
	_oUI.roomlistWidget->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);//���������ɼ�
	_oUI.roomlistWidget->setVerticalScrollMode(QListWidget::ScrollPerPixel); //���ù�����������ģʽ:�������ع���
	_oUI.roomlistWidget->verticalScrollBar()->setSingleStep(10);//ÿһ�������10���ء�

	setWindowTitle(QApplication::translate("AppInfo", "AppName", 0));
	setWindowIcon(QIcon(":/joy/app_ico"));

	QGraphicsDropShadowEffect *shadowEffect = new QGraphicsDropShadowEffect();
	shadowEffect->setBlurRadius(100);	//����Բ�ǰ뾶 ����
	shadowEffect->setColor(Qt::black);	// ���ñ߿���ɫ
	shadowEffect->setOffset(5);

	_oUI.centralWidget->setGraphicsEffect(shadowEffect);
}

void MainUI::initHttp() {
	_pMainHttpLogic.reset(new MainHttpLogic());
	connect(_pMainHttpLogic.get(), SIGNAL(onLoginSuccess(const QString&)), this, SLOT(onLoginSuccess(const QString&)));
	connect(_pMainHttpLogic.get(), SIGNAL(onLoginFailed()), this, SLOT(onLoginFailed()));
	connect(_pMainHttpLogic.get(), SIGNAL(onGetRoomListSuccess(const QString&)), this, SLOT(onGetRoomListSuccess(const QString&)));
	connect(_pMainHttpLogic.get(), SIGNAL(onGetRoomListFailed()), this, SLOT(onGetRoomListFailed()));
	connect(_pMainHttpLogic.get(), SIGNAL(onGetRoomInfoSuccess(const QString&)), this, SLOT(onGetRoomInfoSuccess(const QString&)));
	connect(_pMainHttpLogic.get(), SIGNAL(onGetRoomInfoFailed()), this, SLOT(onGetRoomInfoFailed()));
}

void MainUI::initLivingUI() {
	_pLivingDialogUI.reset(new LivingDialogUI());
	connect(_pLivingDialogUI.get(), SIGNAL(onLivingUILeaveRoom()), this, SLOT(onLivingUILeaveRoom()));
}

void MainUI::initChatRoom() {
	connect(ChatRoomManager::GetInstance(), SIGNAL(onLoginChatRoomSuccess()), this, SLOT(onLoginChatRoomSuccess()));
	connect(ChatRoomManager::GetInstance(), SIGNAL(onLoginChatRoomFailed()), this, SLOT(onLoginChatRoomFailed()));
}

void MainUI::beginLiving() {
	RoomInfo::GetInstance()->clearAll();
	RoomInfo::GetInstance()->_eRoomType = RoomType::LIVE;
	RoomInfo::GetInstance()->_eUserRole = RoomInfo::UserRole::Anchor;
	RoomInfo::GetInstance()->_iChatId = 0;
	RoomInfo::GetInstance()->_strRoomName = "";
	RoomInfo::GetInstance()->_pRoomAnchor->_strNickName = LocalUserInfo::GetInstance()->_strNickName;
	RoomInfo::GetInstance()->_pRoomAnchor->_strCover = LocalUserInfo::GetInstance()->_strCover;
	RoomInfo::GetInstance()->_pRoomAnchor->_iUid = LocalUserInfo::GetInstance()->_iUid;
	
	// living show
	initLivingUI();
	_pLivingDialogUI->showDialog();
}

void MainUI::sendLoginRequest() {
	// 1. �� config.ini ��ȡ uid
	// 2. û�ж�ȡ�� uid ���� 0
	// 3. ���� login ����
	
	int64_t uid = Setting::GetInstance()->readInt(STR_CONFIG_UID);
	LoginRequest req;
	req.Uid = uid;

	_pMainHttpLogic->login(QString::fromStdString(req.ToJson()));
}

void MainUI::sendGetRoomListRequest() {
	// 1. ���ͻ�ȡ�����б������

	GetRoomListRequest req;
	req.Uid = LocalUserInfo::GetInstance()->_iUid;
	req.RType = (int)RoomType::LIVE;  // ����д��Ĭ����

	_pMainHttpLogic->getRoomList(QString::fromStdString(req.ToJson()));
}

void MainUI::onClickMinBtn() {
	this->showMinimized();
}

void MainUI::onClickCloseBtn() {
	// 1. �жϵ�ǰ����ֱ�����ǹۿ�
	// 2. ��ʾ�Ի���
	// 3. ����Ի���ѡ���� ok���˳�
	if (_pLivingDialogUI) {
		if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Anchor) {
			// ��ʾ��
			MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("MainUI", "QuitAppWhenLiving", 0),
				MessageBoxNormalUIShowType::MAINUI_QUIT_APP_WHEN_LIVING, this);
		}
		else if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Viewer) {
			// ��ʾ��
			MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("MainUI", "QuitAppWhenWatching", 0),
				MessageBoxNormalUIShowType::MAINUI_QUIT_APP_WHEN_WATCHING, this);
		}
	}
	else {
		closeApp();
	}
}

void MainUI::onClickLiveBtn(bool) {
	if (_pLivingDialogUI == nullptr) {
		beginLiving();
	}
	else {
		if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Viewer) {
			// ��ʾ��
			MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("MainUI", "BeginLivingWhenInWatching", 0),
				MessageBoxNormalUIShowType::MAINUI_BEGIN_LIVING_WHEN_WATCHING, this);
		}
	}
}

void MainUI::onClickLiveRoomListBtn(bool) {
	// ���ͻ�ȡ�����б�����
	sendGetRoomListRequest();
}

void MainUI::onClickLanguageBtn(bool) {
	int l = Setting::GetInstance()->readInt(STR_CONFIG_LANGUAGE);
	QString str;
	if (l == Translator::LanguageType::ZH) {
		l = Translator::LanguageType::EN;
		str = QApplication::translate("MainUI", "LanguageChinese", 0);
		_oUI.appLogoGraphicsView->setStyleSheet(QStringLiteral("background-image: url(:/joy/logo_en);"));
	}
	else {
		l = Translator::LanguageType::ZH;
		str = QApplication::translate("MainUI", "LanguageEnglish", 0);
		_oUI.appLogoGraphicsView->setStyleSheet(QStringLiteral("background-image: url(:/joy/logo_zh);"));
	}
	Translator::GetInstance()->reloadLanguage(static_cast<Translator::LanguageType>(l));
	_oUI.retranslateUi(this);
	if (_pLivingDialogUI) {
		_pLivingDialogUI->changeLanguage();
	}
	_oUI.languageBtn->setText(str);
	setWindowTitle(QApplication::translate("AppInfo", "AppName", 0));
	_oUI.userUidLabel->setText(QString("UID:%1").arg(LocalUserInfo::GetInstance()->_iUid));
	resetAppNumber();
}

void MainUI::onLoginSuccess(const QString& body) {
	LoginResponse resp;
	LoginResponse::FromJson(&resp, qstring2stdString(body));

	if (resp.Code != (int)HttpErrorCode::SUCCESS) {
		// ��ʾ��ʾ��
		return;
	}

	// 1. ���� uid + token
	Setting::GetInstance()->write(STR_CONFIG_UID, resp.Data.Uid);
	LocalUserInfo::GetInstance()->_iUid = resp.Data.Uid;
	LocalUserInfo::GetInstance()->_strToken = resp.Data.Token;
	LocalUserInfo::GetInstance()->_strCover = stdString2QString(resp.Data.Cover);
	LocalUserInfo::GetInstance()->_strNickName = stdString2QString(resp.Data.NickName);

	_oUI.userUidLabel->setText(QString("UID:%1").arg(resp.Data.Uid));

	// 2. ��ȡ roomlist
	sendGetRoomListRequest();

	// 3. ��½ chatRoom
	ChatRoomManager::GetInstance()->login(resp.Data.Uid, resp.Data.Token);
}

void MainUI::onLoginFailed() {
	// 1. ��ʾ��
}

void MainUI::onGetRoomListSuccess(const QString& body) {
	// 1. ˢ�� roomlist
	GetRoomListResponse resp;
	GetRoomListResponse::FromJson(&resp, qstring2stdString(body));

	if (resp.Code != (int)HttpErrorCode::SUCCESS) {
		// ��ʾ��ʾ��
		return;
	}

	reflushRoomList(resp);
}

void MainUI::onGetRoomListFailed() {
	// 1. ��ʾ��
}

void MainUI::onGetRoomInfoSuccess(const QString& body) {
	GetRoomInfoResponse resp;
	GetRoomInfoResponse::FromJson(&resp, qstring2stdString(body));

	if (resp.Code != (int)HttpErrorCode::SUCCESS) {
		// ��ʾ��ʾ��
		onClickLiveRoomListBtn(true);
		return;
	}

	if (resp.Data.RoomInfo.RType != (int)RoomType::LIVE) {
		// ��ʾ��ʾ��
		return;
	}

	RoomInfo::GetInstance()->clearAll();
	RoomInfo::GetInstance()->_eRoomType = (RoomType)resp.Data.RoomInfo.RType;
	RoomInfo::GetInstance()->_iRoomId = resp.Data.RoomInfo.RoomId;
	RoomInfo::GetInstance()->_eUserRole = RoomInfo::UserRole::Viewer;
	RoomInfo::GetInstance()->_iChatId = resp.Data.RoomInfo.RChatId;
	RoomInfo::GetInstance()->_strRoomName = stdString2QString(resp.Data.RoomInfo.RName);
	RoomInfo::GetInstance()->_pRoomAnchor->_strNickName = stdString2QString(resp.Data.RoomInfo.ROwner.NickName);
	RoomInfo::GetInstance()->_pRoomAnchor->_strCover = stdString2QString(resp.Data.RoomInfo.ROwner.Cover);
	RoomInfo::GetInstance()->_pRoomAnchor->_iUid = resp.Data.RoomInfo.ROwner.Uid;

	// �����˷���
	for (auto t = resp.Data.UserList.arr.begin(); t != resp.Data.UserList.arr.end(); t++) {
		std::shared_ptr<UserInfo> u = std::make_shared<UserInfo>();
		u->setUserInfo((*t));
		RoomInfo::GetInstance()->_oAllNormalUserList.emplace_back(u);

		if ((*t).LinkUid != 0 && (*t).Uid == resp.Data.RoomInfo.ROwner.Uid) {
			std::shared_ptr<UserLinkInfo> ul = std::make_shared<UserLinkInfo>();
			ul->_iRoomId = (*t).LinkRoomId;
			ul->_iUid = (*t).LinkUid;
			RoomInfo::GetInstance()->_oLinkUserList.emplace_back(ul);
		}
	}

	// ����Լ�
	std::shared_ptr<UserInfo> u = std::make_shared<UserInfo>();
	u->_iUid = LocalUserInfo::GetInstance()->_iUid;
	u->_bMicEnable = LocalUserInfo::GetInstance()->_bMicEnable;
	u->_bSelfMicEnable = LocalUserInfo::GetInstance()->_bSelfMicEnable;
	u->_iLinkRoomId = LocalUserInfo::GetInstance()->_iLinkRoomId;
	u->_iLinkUid = LocalUserInfo::GetInstance()->_iLinkUid;
	u->_strNickName = LocalUserInfo::GetInstance()->_strNickName;
	u->_strCover = LocalUserInfo::GetInstance()->_strCover;
	RoomInfo::GetInstance()->_oAllNormalUserList.emplace_back(u);

	initLivingUI();
	_pLivingDialogUI->showDialog();
}

void MainUI::onGetRoomInfoFailed() {

}

void MainUI::onSelectRoom(const GetRoomListResponse::RoomInfoResponse& roomInfo) {
	// Ӧ�����»�ȡֱ������Ϣ��Ȼ����� type �ж�
	// ���뷿��

	if (_pLivingDialogUI) {
		_iSelectRoomId = roomInfo.RoomId;

		if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Anchor) {
			// ��ʾ��
			MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("MainUI", "SelectWhenInLiving", 0),
				MessageBoxNormalUIShowType::MAINUI_SELECT_WHEN_LIVING, this);
		}
		else if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Viewer) {
			// ��ʾ��
			MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("MainUI", "SelectWhenInWatching", 0),
				MessageBoxNormalUIShowType::MAINUI_SELECT_WHEN_WATCHING, this);
		}
		return;
	}

	_iSelectRoomId = 0;
	GetRoomInfoRequest req;
	req.RType = (int)RoomType::LIVE;
	req.RoomId = roomInfo.RoomId;
	req.Uid = LocalUserInfo::GetInstance()->_iUid;
	_pMainHttpLogic->getRoomInfo(stdString2QString(req.ToJson()));
}

void MainUI::onLivingUILeaveRoom() {
	_pLivingDialogUI = nullptr;

	// ˢ����
	onClickLiveRoomListBtn(true);
}

void MainUI::onLoginChatRoomSuccess() {
	Logd(TAG, Log(__FUNCTION__).setMessage("login chat room success"));
}

void MainUI::onLoginChatRoomFailed() {
	Logd(TAG, Log(__FUNCTION__).setMessage("login chat room failed"));
	MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("MainUI", "ChatJoinRoomFailed", 0), MessageBoxNormalUIShowType::WS_ERROR_MSG, nullptr);
}

void MainUI::mousePressEvent(QMouseEvent *event) {
	if (event->button() == Qt::LeftButton) {
		_bDragFlag = true;
		_oDragPosition = event->globalPos() - this->pos();
		event->accept();
	}
}

void MainUI::mouseMoveEvent(QMouseEvent *event) {
	if (_bDragFlag && (event->buttons() && Qt::LeftButton)) {
		move(event->globalPos() - _oDragPosition);
		event->accept();
	}
}

void MainUI::mouseReleaseEvent(QMouseEvent *event) {
	_bDragFlag = false;
}

void MainUI::closeApp() {
	MessageBoxNormalUI::GetInstance()->hide();
	MessageBoxPKUI::GetInstance()->hide();
	if (_bClose) {
		return;
	}

	_bClose = true;
	if (_pLivingDialogUI) {
		_pLivingDialogUI->hideDialog();
	}
	ChatRoomManager::GetInstance()->logout();
	this->close();
}

// �±��������е���ر�ѡ����ߺ�棬û�а취��ʾ��ʾ�����
void MainUI::closeEvent(QCloseEvent *event) {
	closeApp();
}

void MainUI::onClickMsgOKBtn(MessageBoxNormalUIShowType t) {
	switch (t) {
	case MessageBoxNormalUIShowType::MAINUI_QUIT_APP_WHEN_LIVING:
	case MessageBoxNormalUIShowType::MAINUI_QUIT_APP_WHEN_WATCHING:
	{
		closeApp();
	}
		break;
	case MessageBoxNormalUIShowType::MAINUI_SELECT_WHEN_LIVING:
	case MessageBoxNormalUIShowType::MAINUI_SELECT_WHEN_WATCHING:
	{
		if (_pLivingDialogUI) {
			_pLivingDialogUI->hideDialog();
			_pLivingDialogUI.reset();
		}
		
		// ���ͷ�����Ϣ����
		GetRoomInfoRequest req;
		req.RType = (int)RoomType::LIVE;
		req.RoomId = _iSelectRoomId;
		req.Uid = LocalUserInfo::GetInstance()->_iUid;
		_pMainHttpLogic->getRoomInfo(stdString2QString(req.ToJson()));
		_iSelectRoomId = 0;
	}
		break;
	case MessageBoxNormalUIShowType::MAINUI_BEGIN_LIVING_WHEN_WATCHING:
	{
		if (_pLivingDialogUI) {
			_pLivingDialogUI->hideDialog();
			_pLivingDialogUI.reset();
		}

		beginLiving();
	}
		break;
	case MessageBoxNormalUIShowType::HTTP_ERROR_MSG:
		break;
	case MessageBoxNormalUIShowType::WS_ERROR_MSG:
		break;
	default:
		break;
	}
}

void MainUI::onClickMsgCancelBtn(MessageBoxNormalUIShowType t) {
	// do nothing
}

void MainUI::initEvent() {
	connect(_oUI.minBtn, SIGNAL(clicked()), this, SLOT(onClickMinBtn()));
	connect(_oUI.closeBtn, SIGNAL(clicked()), this, SLOT(onClickCloseBtn()));
	connect(_oUI.liveBtn, SIGNAL(clicked(bool)), this, SLOT(onClickLiveBtn(bool)));
	connect(_oUI.liveRoomListBtn, SIGNAL(clicked(bool)), this, SLOT(onClickLiveRoomListBtn(bool)));
	connect(_oUI.languageBtn, SIGNAL(clicked(bool)), this, SLOT(onClickLanguageBtn(bool)));
}

void MainUI::reflush() {
	_oUI.retranslateUi(this);
	retranslateUI();
}

// =========== language =============
void MainUI::initLanguage() {
	int l = Setting::GetInstance()->readInt(STR_CONFIG_LANGUAGE);
	Translator::GetInstance()->reloadLanguage(static_cast<Translator::LanguageType>(l));
}

void MainUI::initLanguageBtn() {
	int l = Setting::GetInstance()->readInt(STR_CONFIG_LANGUAGE);
	QString str;
	if (l == Translator::LanguageType::EN) {
		str = QApplication::translate("MainUI", "LanguageChinese", 0);
		_oUI.appLogoGraphicsView->setStyleSheet(QStringLiteral("background-image: url(:/joy/logo_en);"));
	}
	else {
		str = QApplication::translate("MainUI", "LanguageEnglish", 0);
		_oUI.appLogoGraphicsView->setStyleSheet(QStringLiteral("background-image: url(:/joy/logo_zh);"));
	}
	_oUI.languageBtn->setText(str);
}

void MainUI::retranslateUI() {
	resetAppNumber();
}

void MainUI::reflushRoomList(const GetRoomListResponse& resp) {
	_oUI.roomlistWidget->clear();

	if (!resp.Data.RoomList.arr.empty()) {
		QWidget* newColumnWidget = nullptr;

		std::list<GetRoomListResponse::RoomInfoResponse> _oList;

		// �ȹ��˵����� RTC ��
		for (auto r = resp.Data.RoomList.arr.begin(); r != resp.Data.RoomList.arr.end(); r++) {
			if ((*r).RPublishMode == (int)PushMode::RTC) {
				GetRoomListResponse::RoomInfoResponse res = (*r);
				_oList.emplace_back(res);
			}
		}

		for (auto r = _oList.begin(); r != _oList.end(); r++) {
			if ((*r).RPublishMode == (int)PushMode::RTC) {
				newColumnWidget = new QWidget;
				newColumnWidget->setGeometry(QRect(0, 0, 309, 177));
				newColumnWidget->setObjectName(QStringLiteral("newColumnWidget"));

				RoomInfoCellUI *room = new RoomInfoCellUI(newColumnWidget);
				room->setRoomInfo((*r));
				room->setGeometry(0, 0, 152, 177);   //width height
				connect(room, SIGNAL(onSelectRoom(const GetRoomListResponse::RoomInfoResponse&)),
					this, SLOT(onSelectRoom(const GetRoomListResponse::RoomInfoResponse&)));

				r++;
				if (r != _oList.end()) {
					RoomInfoCellUI *room1 = new RoomInfoCellUI(newColumnWidget);
					room1->setRoomInfo((*r));
					room1->setGeometry(157, 0, 152, 177);   //width height
					connect(room1, SIGNAL(onSelectRoom(const GetRoomListResponse::RoomInfoResponse&)),
						this, SLOT(onSelectRoom(const GetRoomListResponse::RoomInfoResponse&)));
				}
				else {
					r--;
				}

				QListWidgetItem *item = new QListWidgetItem();
				item->setSizeHint(QSize(309, 177));//���ÿ�ȡ��߶� 
				_oUI.roomlistWidget->addItem(item);
				_oUI.roomlistWidget->setItemWidget(item, newColumnWidget);
				item->setHidden(false);
			}
		}
	}

	//for (auto a = RoomInfo::GetInstance()->_oAllNormalUserList.begin();
	//	a != RoomInfo::GetInstance()->_oAllNormalUserList.end(); a++) {
	//	UserCellUI *userCell = new UserCellUI();
	//	QListWidgetItem *item = new QListWidgetItem();
	//	item->setSizeHint(QSize(240, 44));//���ÿ�ȡ��߶� 
	//	_oUI.userListWidget->addItem(item);
	//	_oUI.userListWidget->setItemWidget(item, userCell);
	//	item->setHidden(false);
	//	userCell->setData(*(*a).get());
	//}


	//auto pLayout = _oUI.scrollArea->widget()->layout();
	//if (!resp.Data.RoomList.arr.empty()) {
	//	for (auto r: resp.Data.RoomList.arr) {
	//		if (r.RPublishMode == (int)PushMode::RTC) {
	//			RoomInfoCellUI *room = new RoomInfoCellUI(_oUI.scrollAreaWidgetContents);
	//			room->setRoomInfo(r);
	//			//room->setGeometry(0, 0, 195, 225);   //width height
	//			room->setMinimumSize(QSize(152, 177));   //width height
	//			connect(room, SIGNAL(onSelectRoom(const GetRoomListResponse::RoomInfoResponse&)),
	//				this, SLOT(onSelectRoom(const GetRoomListResponse::RoomInfoResponse&)));
	//			pLayout->addWidget(room);//�Ѱ�ť��ӵ����ֿؼ���
	//		}
	//	}
	//}
}

// =========== language =============

// =========== app number =============

void MainUI::resetAppNumber() {
	int number = getBuildNumber();
	if (number == -1) {
		number = 0;
	}
	QString appBuild = QString("V1.0.1,#%1,TB:2.9.6,CR:1.4.0,OF:1.4.2").arg(number);
	_oUI.appVersionLabel->setText(appBuild);
}

int MainUI::getBuildNumber() {
	int number = -1;
	FILE* fp = nullptr;
	fopen_s(&fp, "./number.txt", "r+");
	if (fp) {
		fseek(fp, 0, SEEK_END);
		int len = ftell(fp);
		fseek(fp, 0, SEEK_SET);
		if (len > 0 && len <= 10) {
			fscanf(fp, "%d", &number);
		}
		fclose(fp);
	}
	return number < 0 ? -1 : number;
}
// =========== app number =============
// =========== create log =============
void MainUI::createLogDir(const std::string& path) {
	// 1. Determine whether the log directory has been created, if not, do not create it
	// 2. Create a directory
	if (access(path.c_str(), 0) == -1) {
		if (::CreateDirectoryA(path.c_str(), NULL)) {
			Logd(TAG, Log("createLogDir").setMessage("Dir path[%s] create OK!!!!", path.c_str()));
		}
		else {
			Logd(TAG, Log("createLogDir").setMessage("Dir path[%s] create Failed!!!!", path.c_str()));
		}
	}
	else {
		Logd(TAG, Log("createLogDir").setMessage("Dir path[%s] is exist!!!!", path.c_str()));
	}
}

void MainUI::initLog() {
	// 1. Get the current directory address
	QString localPath = QCoreApplication::applicationDirPath();
	if (localPath.isEmpty()) {
		Logw(TAG, Log("initLogFile").setMessage("Get localPath is empty!!!"));
		return;
	}

	// 2. Determine whether the log directory has been created, if not, do not create it
	QString userData = localPath + USER_DATA_PATH;
	QString logPath = localPath + USER_DATA_SYSLOG_PATH;
	QString uiPath = localPath + USER_DATA_UILOG_PATH;
	QString sdkPath = localPath + USER_DATA_SDKLOG_PATH;
	createLogDir(qstring2stdString(userData));
	createLogDir(qstring2stdString(logPath));
	createLogDir(qstring2stdString(uiPath));
	createLogDir(qstring2stdString(sdkPath));

	MediaManager::instance()->getThunderManager()->setLogFilePath(qstring2stdString(sdkPath).c_str());

#ifdef DEBUG
	MediaManager::instance()->getThunderManager()->setLogLevel(LOG_LEVEL_TRACE);
#else
	// 3. Create a log file
	CreateLogFile(qstring2stdString(uiPath), "Joy");

	// 4. set sdk log level
	MediaManager::instance()->getThunderManager()->setLogLevel(LOG_LEVEL_WARN);

	// 5. if set sdkPath += L"\\1.txt", set sdk log level is LOG_LEVEL_TRACE, means all log
	sdkPath += "/1.txt";
	if (access(qstring2stdString(sdkPath).c_str(), 0) != -1) {
		MediaManager::instance()->getThunderManager()->setLogLevel(LOG_LEVEL_TRACE);
	}
#endif // DEBUG
}

void MainUI::uinitLog() {
	DestoryLogFile();
	MediaManager::release();
}

// =========== create log =============

// ������Ϣ����
//static void handleString(QString& msg) {
//	QFontMetrics fontMetrics(ui.login_error_label->font());
//	int fontSize = fontMetrics.width(msg);//��ȡ֮ǰ���õ��ַ��������ش�С
//	QString str = msg;
//	if (fontSize > ui.login_error_label->width())
//	{
//		str = fontMetrics.elidedText(msg, Qt::ElideRight, this->width());//����һ������ʡ�Ժŵ��ַ���
//	}
//	ui.login_error_label->setText(str);
//}
