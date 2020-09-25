/*!
 * \file ClientEquipmentUI.cpp
 *
 * \author Zhangjianping
 * \date 2020/07/31
 * \contact 114695092@qq.com
 *
 * 
 */
#include "ClientEquipmentUI.h"
#include "../../../common/utils/String.h"
#include <QScrollBar>
#include "../../RoomInfo.h"
#include <QDebug>
#include "../../LogicModel.h"
#include "../logic/LivingHttpLogic.h"
#include "AnchorCellUI.h"
#include "UserCellUI.h"
#include "../../../common/log/loggerExt.h"
#include "../../../common/qss/QssLoad.h"

using namespace base;
static const char* TAG = "ClientEquipmentUI";

ClientEquipmentUI::ClientEquipmentUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//无边框   
	setAttribute(Qt::WA_TranslucentBackground);//背景透明
	setAttribute(Qt::WA_QuitOnClose, true);

	initEvent();

	Utils::QssLoad::Load(this, "ClientEquipmentUI.qss");

	_oUI.userListWidget->setSelectionMode(QAbstractItemView::NoSelection);
	_oUI.userListWidget->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);//滚动条不可见
	_oUI.userListWidget->setVerticalScrollMode(QListWidget::ScrollPerPixel); //设置滚动条滚动的模式:按照像素滚动
	_oUI.userListWidget->verticalScrollBar()->setSingleStep(10);//每一步骤滚动10像素。
	_oUI.userListWidget->setFrameShape(QListWidget::NoFrame);
}

ClientEquipmentUI::~ClientEquipmentUI() {
}

void ClientEquipmentUI::setHttpLogic(std::shared_ptr<LivingHttpLogic> logic) {
	_pLivingHttpLogic = logic;
	connect(_pLivingHttpLogic.get(), SIGNAL(onGetAnchorListSuccess(const QString&)), this, SLOT(onGetAnchorListSuccess(const QString&)));
	connect(_pLivingHttpLogic.get(), SIGNAL(onGetAnchorListFailed()), this, SLOT(onGetAnchorListFailed()));
}

void ClientEquipmentUI::resetUI() {
	_oUI.userListWidget->show();
	if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Viewer) {
		_oUI.anchorListBtn->hide();
		_oUI.linkWidget->show();
		_oUI.equipmentWidget->hide();
		_oUI.otherWidget->show();
	}
	else {
		_oUI.anchorListBtn->show();
		_oUI.linkWidget->hide();
		_oUI.equipmentWidget->show();
		_oUI.otherWidget->hide();  // 如果是主播，需要等点击开播按钮后才显示此控件
	}

	reset();
	onClickUserListBtn(true);

	if (RoomInfo::GetInstance()->_oLinkUserList.size() != 0) {
		auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
		if ((*u)->_iUid != LocalUserInfo::GetInstance()->_iUid) {
			if ((*u)->_iRoomId != RoomInfo::GetInstance()->_iRoomId) {
				// 如果不是同房间下，PK 中
				switchLinkBtn(PKING);
			}
			else {
				switchLinkBtn(LINKING);
			}
		}
	}
}

void ClientEquipmentUI::resetCameraCombox() {
	_oUI.cameraComboBox->clear();
	_bResetCameraComboxOK = false;

	QStringList s;
	IVideoDeviceManager* manager = MediaManager::instance()->getThunderManager()->getVideoDeviceMgr();
	if (manager != NULL) {
		manager->enumVideoDevices(_oVideoDevList);
		for (int i = 0; i < _oVideoDevList.count; ++i) {
			s << QString::fromUtf8(_oVideoDevList.device[i].name);
		}
	}

	_oUI.cameraComboBox->addItems(s);

	// 设置默认
	if (_oVideoDevList.count != 0) {
		_oUI.cameraComboBox->setCurrentIndex(0);
	}
	_bResetCameraComboxOK = true;
}

void ClientEquipmentUI::resetMicphoneCombox() {
	_oUI.micphoneComboBox->clear();
	_bResetMicphoneComboxOK = false;

	QStringList s;
	IAudioDeviceManager* manager = MediaManager::instance()->getThunderManager()->getAudioDeviceMgr();
	if (manager != NULL) {
		manager->enumInputDevices(_oAudioDevList);
		for (int i = 0; i < _oAudioDevList.count; ++i) {
			s << QString::fromUtf8(_oAudioDevList.device[i].desc);
		}
	}

	_oUI.micphoneComboBox->addItems(s);

	// 设置默认
	if (_oAudioDevList.count != 0) {
		_oUI.micphoneComboBox->setCurrentIndex(0);
	}
	_bResetMicphoneComboxOK = true;
}

void ClientEquipmentUI::resetPushModeCombox() {
	_oUI.publishModeComboBox->clear();
	_bResetPushComboxOK = false;

	//-1, 0 960x544
	//	1 320x240
	//	2 640x480
	//	3 960x544
	//	4 1280x720
	//	5 1920x1080
	//VIDEO_PUBLISH_MODE_DEFAULT = -1, // Undefined. The broadcast definition is determined by configuration
	//	VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION = 1, // Fluent
	//	VIDEO_PUBLISH_MODE_NORMAL_DEFINITION = 2, // Standard definition
	//	VIDEO_PUBLISH_MODE_HIGH_DEFINITION = 3, // High definition
	//	VIDEO_PUBLISH_MODE_SUPER_DEFINITION = 4, // Ultra definition
	//	VIDEO_PUBLISH_MODE_BLUERAY = 5, // Blue light
	QStringList s;
	//s << QApplication::translate("ClientEquipmentUI", "PushModeDefault", 0); // |-1
	s << QApplication::translate("ClientEquipmentUI", "PushModeSmooth", 0);//  | 1
	s << QApplication::translate("ClientEquipmentUI", "PushModeNormal", 0); //  2
	s << QApplication::translate("ClientEquipmentUI", "PushModeHigh", 0);  // 3
	//s << QApplication::translate("ClientEquipmentUI", "PushModeSuper", 0); //|4
	//s << QApplication::translate("ClientEquipmentUI", "PushModeBlueray", 0); // 5

	_oUI.publishModeComboBox->addItems(s);
	// 高清默认
	_oUI.publishModeComboBox->setCurrentIndex(1);
	_iPublishModeComboBoxCurrent = 1;
	_bResetPushComboxOK = true;

	// 设置默认
	VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = VIDEO_PUBLISH_MODE_NORMAL_DEFINITION;
	MediaManager::instance()->getThunderManager()->setVideoEncoderConfig(config);
}

void ClientEquipmentUI::reset() {
	_oUI.breakLinkBtn->hide();
	resetCameraCombox();
	resetMicphoneCombox();
	resetPushModeCombox();
	_bMute = false;
	_eThunderVideoMirrorMode = THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR;
	_bVideoStreamStop = false;

	_oUI.micphoneBtn->setStyleSheet(QStringLiteral("background-image: url(:/livingui/micphone_on_button);"));
	_oUI.cameraBtn->setStyleSheet(QStringLiteral("background-image: url(:/livingui/camera_on_button);"));
}

void ClientEquipmentUI::linkAnchorSuccess() {
	if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Anchor) {
		_oUI.linkWidget->hide();
		switchLinkBtn(BREAK);  // 按钮隐藏掉了，所以可以设置最初值
		_oUI.equipmentWidget->show();
		_oUI.breakLinkBtn->show();
	}
	else {
		if (RoomInfo::GetInstance()->_oLinkUserList.size() != 0) {
			auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
			if ((*u)->_iUid != LocalUserInfo::GetInstance()->_iUid) {
				// 如果连麦的不是自己
				_oUI.linkWidget->show();
				_oUI.equipmentWidget->hide();
				if ((*u)->_iRoomId != RoomInfo::GetInstance()->_iRoomId) {
					// 如果不是同房间下，PK 中
					switchLinkBtn(PKING);
				}
				else {
					switchLinkBtn(LINKING);
				}
			}
			else {
				// 如果连麦的是自己
				_oUI.linkWidget->hide();
				switchLinkBtn(BREAK);  // 按钮隐藏掉了，所以可以设置最初值
				_oUI.equipmentWidget->show();
			}
		}
	}

	if (_eListViewType == ListViewType::ANCHOR) {
		// 如果是主播列表，主播在连麦中需要去掉主播按钮
		for (auto t = _oAnchorList.begin(); t != _oAnchorList.end(); t++) {
			(*t)->beginingPK();
		}
	}
}

void ClientEquipmentUI::pkAnchorSuccess(int64_t uid) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", std::to_string(uid)));
	for (auto t = _oAnchorList.begin(); t != _oAnchorList.end(); t++) {
		if (uid == (*t)->getUid()) {
			(*t)->beginPK();
			(*t)->beginingPK(); // 更新下自己
		}
		else {
			(*t)->beginingPK();
		}
	}
	_oUI.breakLinkBtn->show();
}

void ClientEquipmentUI::breakAnchor() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	if (_eListViewType == ListViewType::ANCHOR) {
		for (auto t = _oAnchorList.begin(); t != _oAnchorList.end(); t++) {
			(*t)->endPK();
		}
	}

	if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Viewer) {
		_oUI.linkWidget->show();
		_oUI.equipmentWidget->hide();
		switchLinkBtn(BREAK);

		reset();
	}
	_oUI.breakLinkBtn->hide();
}

void ClientEquipmentUI::otherLinkAnchor() {
	if (RoomInfo::GetInstance()->_oLinkUserList.size() != 0) {
		auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
		if ((*u)->_iUid != LocalUserInfo::GetInstance()->_iUid) {
			if ((*u)->_iRoomId != RoomInfo::GetInstance()->_iRoomId) {
				// 如果不是同房间下，PK 中
				switchLinkBtn(PKING);
			}
			else {
				switchLinkBtn(LINKING);
			}
		}
	}
}

void ClientEquipmentUI::changeLanguage() {
	_oUI.retranslateUi(this);

	switchLinkBtn(_eLinkBtnType);

	resetUserCount();

	for (auto t = _oAnchorList.begin(); t != _oAnchorList.end(); t++) {
		(*t)->changeLanguage();
	}

	resetAnchorCount();

	_oUI.publishModeComboBox->clear();
	_bResetPushComboxOK = false;
	QStringList s;
	s << QApplication::translate("ClientEquipmentUI", "PushModeSmooth", 0);//  | 1
	s << QApplication::translate("ClientEquipmentUI", "PushModeNormal", 0); //  2
	s << QApplication::translate("ClientEquipmentUI", "PushModeHigh", 0);  // 3

	_oUI.publishModeComboBox->addItems(s);
	// 高清默认
	_oUI.publishModeComboBox->setCurrentIndex(_iPublishModeComboBoxCurrent);
	_bResetPushComboxOK = true;
}

void ClientEquipmentUI::switchLinkBtn(LinkBtnType t) {
	QString str = QApplication::translate("ClientEquipmentUI", "linkAnchor", 0);
	bool enable = true;
	_eLinkBtnType = t;
	switch (t) {
	case ClientEquipmentUI::BREAK:
		str = QApplication::translate("ClientEquipmentUI", "linkAnchor", 0);
		break;
	case ClientEquipmentUI::LINKING:
		str = QApplication::translate("ClientEquipmentUI", "InLinking", 0);
		enable = false;
		break;
	case ClientEquipmentUI::SEND_LINK:
		str = QApplication::translate("ClientEquipmentUI", "SendingLinkRequest", 0);
		enable = false;
		break;
	case ClientEquipmentUI::PKING:
		str = QApplication::translate("ClientEquipmentUI", "InPKing", 0);
		enable = false;
		break;
	}

	_oUI.linkBtn->setEnabled(enable);
	_oUI.linkBtn->setText(str);
}

void ClientEquipmentUI::userJoin() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	reflushUserList();
}

void ClientEquipmentUI::userLeave(const QString& uid) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	reflushUserList();
	if (_eListViewType == ListViewType::ANCHOR) {
		auto find = false;
		int index = 0;
		for (auto t = _oAnchorList.begin(); t != _oAnchorList.end(); t++) {
			if ((*t)->getUid() == uid.toInt()) {
				find = true;
				_oAnchorList.erase(t);
				QListWidgetItem *item = _oUI.userListWidget->takeItem(index++);
				delete item;
				break;
			}
		}

		if (find) {
			for (auto t = _oAnchorList.begin(); t != _oAnchorList.end(); t++) {
				(*t)->endPK();
			}
		}
	}
}

void ClientEquipmentUI::setUserRole() {
}

void ClientEquipmentUI::resetUserCount() {
	QString str = QApplication::translate("ClientEquipmentUI", "UserListBtn", 0);
	str += " ";
	str += QString::number(RoomInfo::GetInstance()->_oAllNormalUserList.size());
	_oUI.userListBtn->setText(str);
}

void ClientEquipmentUI::resetAnchorCount() {
	QString str = QApplication::translate("ClientEquipmentUI", "AnchorListBtn", 0);
	str += " ";
	str += QString::number(_oAnchorList.size());
	_oUI.anchorListBtn->setText(str);
}

void ClientEquipmentUI::videoStreamStart() {
	_bVideoStreamStop = false;
	_oUI.otherWidget->show();  // 点击开始按钮后，需要显示麦克风等按钮
}

void ClientEquipmentUI::initEvent() {
	connect(_oUI.linkBtn, SIGNAL(clicked(bool)), this, SLOT(onClickLinkBtn(bool)));
	connect(_oUI.anchorListBtn, SIGNAL(clicked(bool)), this, SLOT(onClickAnchorListBtn(bool)));
	connect(_oUI.userListBtn, SIGNAL(clicked(bool)), this, SLOT(onClickUserListBtn(bool)));
	connect(_oUI.cameraBtn, SIGNAL(clicked(bool)), this, SLOT(onClickCameraBtn(bool)));
	connect(_oUI.micphoneBtn, SIGNAL(clicked(bool)), this, SLOT(onClickMicphoneBtn(bool)));
	connect(_oUI.mirrorBtn, SIGNAL(clicked(bool)), this, SLOT(onClickMirrorBtn(bool)));
	connect(_oUI.breakLinkBtn, SIGNAL(clicked(bool)), this, SLOT(onClickBreakLinkBtn(bool)));

	connect(_oUI.cameraComboBox, SIGNAL(currentIndexChanged(const QString &)), this, SLOT(onCameraSelect(const QString &)));
	connect(_oUI.micphoneComboBox, SIGNAL(currentIndexChanged(const QString &)), this, SLOT(onMicphoneSelect(const QString &)));
	connect(_oUI.publishModeComboBox, SIGNAL(currentIndexChanged(const QString &)), this, SLOT(onPushModeSelect(const QString &)));
}

void ClientEquipmentUI::onClickLinkBtn(bool) {
	switchLinkBtn(SEND_LINK);
	emit onLinkAnchor();
}

void ClientEquipmentUI::onClickAnchorListBtn(bool) {
	_eListViewType = ListViewType::ANCHOR;

	GetAnchorListRequest req;
	req.RType = (int)RoomType::LIVE;
	req.Uid = LocalUserInfo::GetInstance()->_iUid;
	_pLivingHttpLogic->getAnchorList(stdString2QString(req.ToJson()));
}

void ClientEquipmentUI::reflushUserList() {
	if (_eListViewType == ListViewType::USER) {
		// 显示用户列表框
		_oUI.userListWidget->clear();
		for (auto a = RoomInfo::GetInstance()->_oAllNormalUserList.begin();
			a != RoomInfo::GetInstance()->_oAllNormalUserList.end(); a++) {
			UserCellUI *userCell = new UserCellUI();
			QListWidgetItem *item = new QListWidgetItem();
			item->setSizeHint(QSize(240, 44));//设置宽度、高度 
			_oUI.userListWidget->addItem(item);
			_oUI.userListWidget->setItemWidget(item, userCell);
			item->setHidden(false);
			userCell->setData(*(*a).get());
		}

		resetUserCount();
	}
}

void ClientEquipmentUI::onClickUserListBtn(bool) {
	_eListViewType = ListViewType::USER;
	reflushUserList();
}

void ClientEquipmentUI::onClickCameraBtn(bool) {
	_bVideoStreamStop = !_bVideoStreamStop;
	if (_bVideoStreamStop) {
		MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->stopVideoDeviceCapture();
		_oUI.cameraBtn->setStyleSheet(QStringLiteral("background-image: url(:/livingui/camera_off_button);"));
	}
	else {
		int index = _oUI.cameraComboBox->currentIndex();
		MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->startVideoDeviceCapture(_oVideoDevList.device[index].index);
		_oUI.cameraBtn->setStyleSheet(QStringLiteral("background-image: url(:/livingui/camera_on_button);"));
	}
}

void ClientEquipmentUI::onClickMicphoneBtn(bool) {
	_bMute = !_bMute;
	MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setInputtingMute(_bMute);
	if (_bMute) {
		_oUI.micphoneBtn->setStyleSheet(QStringLiteral("background-image: url(:/livingui/micphone_off_button);"));
	}
	else {
		_oUI.micphoneBtn->setStyleSheet(QStringLiteral("background-image: url(:/livingui/micphone_on_button);"));
	}
}

void ClientEquipmentUI::onClickMirrorBtn(bool) {
	if (_eThunderVideoMirrorMode == THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR) {
		_eThunderVideoMirrorMode = THUNDER_VIDEO_MIRROR_MODE_PREVIEW_NO_MIRROR_PUBLISH_MIRROR;
	}
	else {
		_eThunderVideoMirrorMode = THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR;
	}
	MediaManager::instance()->getThunderManager()->setLocalVideoMirrorMode(_eThunderVideoMirrorMode);
}

void ClientEquipmentUI::onClickBreakLinkBtn(bool) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));

	// 只有主播断开连麦按钮
	if (RoomInfo::GetInstance()->_oLinkUserList.size() != 0) {
		Logd(TAG, Log(__FUNCTION__).setMessage("in linking"));

		auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
		emit onBreakLink((*u)->_iUid, (*u)->_iRoomId);
	}
	_oUI.breakLinkBtn->hide();
}

void ClientEquipmentUI::onCameraSelect(const QString &) {
	int index = _oUI.cameraComboBox->currentIndex();
	if (!_bResetCameraComboxOK || index < 0) {
		return;
	}
	if (!_bVideoStreamStop) {
		MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->startVideoDeviceCapture(_oVideoDevList.device[index].index);
	}
}

void ClientEquipmentUI::onMicphoneSelect(const QString &) {
	int index = _oUI.micphoneComboBox->currentIndex();
	if (!_bResetMicphoneComboxOK || index < 0) {
		return;
	}
	MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setInputtingDevice(_oAudioDevList.device[index].id);

	// 设置上一次的状态  -- 这块没用啊
	MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setInputtingMute(_bMute);
}

void ClientEquipmentUI::onPushModeSelect(const QString &) {
	int index = _oUI.publishModeComboBox->currentIndex();
	if (!_bResetPushComboxOK || index < 0) {
		return;
	}

	//VideoPublishMode mode = VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION;
	//if (index == 0) {
	//	mode = VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION;
	//}
	//else if (index == 1) {
	//	mode = VIDEO_PUBLISH_MODE_NORMAL_DEFINITION;
	//}
	//else if (index == 2) {
	//	mode = VIDEO_PUBLISH_MODE_SUPER_DEFINITION;
	//}

	VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = VideoPublishMode(index + 1);
	MediaManager::instance()->getThunderManager()->setVideoEncoderConfig(config);

	_iPublishModeComboBoxCurrent = index;

	// 把值传入到 ThunderMeetUI.h 中
	emit onSelectPublishMode(index + 1);
}

void ClientEquipmentUI::onGetAnchorListSuccess(const QString& body) {
	// 这块的流程上有点问题，应该是在点击 预览上的开播按钮才发送的
	GetAnchorListResponse resp;
	GetAnchorListResponse::FromJson(&resp, qstring2stdString(body));

	if (resp.Code != (int)HttpErrorCode::SUCCESS) {
		// 显示提示框
		return;
	}

	_oAnchorList.clear();
	_oUI.userListWidget->clear();

	int64_t linkUid = 0;
	if (RoomInfo::GetInstance()->_oLinkUserList.size() != 0) {
		auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
		linkUid = (*u)->_iUid;
	}

	for (auto a = resp.Data.arr.begin(); a != resp.Data.arr.end(); a++) {
		// 过滤自己
		if ((*a).AId != RoomInfo::GetInstance()->_pRoomAnchor->_iUid) {
			AnchorCellUI *anchorCell = new AnchorCellUI();
			connect(anchorCell, SIGNAL(onPKRequest(int64_t, int64_t)), this, SLOT(onPKRequestJ(int64_t, int64_t)));
			QListWidgetItem *item = new QListWidgetItem();
			item->setSizeHint(QSize(240, 44));//设置宽度、高度 
			_oUI.userListWidget->addItem(item);
			_oUI.userListWidget->setItemWidget(item, anchorCell);
			item->setHidden(false);
			anchorCell->setData((*a), linkUid);
			_oAnchorList.emplace_back(anchorCell);
		}
	}

	resetAnchorCount();
}

void ClientEquipmentUI::onGetAnchorListFailed() {
	// 提示框
}

void ClientEquipmentUI::onPKRequestJ(int64_t uid, int64_t roomId) {
	emit onPKRequest(uid, roomId);
}
