/*!
 * \file ThunderMeetUI.cpp
 *
 * \author Zhangjianping
 * \date 2020/07/31
 * \contact 114695092@qq.com
 *
 * 
 */
#include "ThunderMeetUI.h"
#include "../../RoomInfo.h"
#include "../../../common/log/loggerExt.h"
#include "../../baseui/MessageBoxNormalUI.h"
#include "../../../../3rd/Thunderbolt/include/IThunderEngine.h"
#include "../../sdk/beauty/BeautyManager.h"

using namespace base;
static const char* TAG = "ThunderMeetUI";

class ThunderVideoCapture : public Thunder::IVideoCaptureObserver {
public:
	ThunderVideoCapture() {}
	~ThunderVideoCapture() {}

	bool onCaptureVideoFrame(Thunder::VideoFrame& videoFrame) override {
		BeautyManager::GetInstance()->updateFrame(videoFrame);
		return true;
	}
};

ThunderMeetUI::ThunderMeetUI() {
	initEvent();
}

ThunderMeetUI::~ThunderMeetUI() {
}

void ThunderMeetUI::initEvent() {
	connect(MediaManager::instance(), SIGNAL(onJoinRoomSuccessJ(const QString&, const QString&, int)), this, SLOT(onJoinRoomSuccessJ(const QString&, const QString&, int)));
	connect(MediaManager::instance(), SIGNAL(onLeaveRoomJ()), this, SLOT(onLeaveRoomJ()));
	connect(MediaManager::instance(), SIGNAL(onRemoteAudioStoppedJ(const QString&, bool)), this, SLOT(onRemoteAudioStoppedJ(const QString&, bool)));
	connect(MediaManager::instance(), SIGNAL(onRemoteVideoStoppedJ(const QString&, bool)), this, SLOT(onRemoteVideoStoppedJ(const QString&, bool)));
	connect(MediaManager::instance(), SIGNAL(onConnectionStatusJ(ThunderConnectionStatus)), this, SLOT(onConnectionStatusJ(ThunderConnectionStatus)));
	connect(MediaManager::instance(), SIGNAL(onTokenWillExpireJ(const QString&)), this, SLOT(onTokenWillExpireJ(const QString&)));
	connect(MediaManager::instance(), SIGNAL(onVideoCaptureStatusJ(int)), this, SLOT(onVideoCaptureStatusJ(int)));
	connect(MediaManager::instance(), SIGNAL(onFirstLocalVideoFrameSentJ(int)), this, SLOT(onFirstLocalVideoFrameSentJ(int)));
	connect(MediaManager::instance(), SIGNAL(onRemoteVideoPlayJ(const QString&, int, int, int)), this, SLOT(onRemoteVideoPlayJ(const QString&, int, int, int)));
	connect(MediaManager::instance(), SIGNAL(onVideoSizeChangedJ(const QString&, int, int, int)), this, SLOT(onVideoSizeChangedJ(const QString&, int, int, int)));
}

void ThunderMeetUI::resetUI() {
	_oRight.hide();
	_iSubcribeUid = 0;
	_iSubcribeRoomId = 0;

	_pThunderVideoCapture.reset(new ThunderVideoCapture);
	MediaManager::instance()->getThunderManager()->registerVideoCaptureObserver(_pThunderVideoCapture.get());
}

void ThunderMeetUI::setLeftAndRightView(QWidget* left, QWidget* right) {
	_oLeft._pCanvas = left;
	_oRight._pCanvas = right;
	_oLeft._iHwnd = (HWND)left->winId();
	_oRight._iHwnd = (HWND)right->winId();

	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("_oLeft._iHwnd", std::to_string((long long)_oLeft._iHwnd))
		.addDetail("_oRight._iHwnd", std::to_string((long long)_oRight._iHwnd)));
}

void ThunderMeetUI::subcribe(int64_t uid, int64_t roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("uid", std::to_string(uid)).addDetail("roomid", std::to_string(roomId)));
	if (_iSubcribeUid == uid && _iSubcribeRoomId == roomId) {
		// 重复
		Logd(TAG, Log(__FUNCTION__).setMessage("repeat"));
		return;
	}

	_iSubcribeUid = uid;
	_iSubcribeRoomId = roomId;
	
	if (roomId != RoomInfo::GetInstance()->_iRoomId) {
		MediaManager::instance()->getThunderManager()->addSubscribe(std::to_string(roomId).c_str(), std::to_string(uid).c_str());
	}
	else {
		linkSelf(uid);
	}
}

void ThunderMeetUI::unsubcribe(int64_t uid, int64_t roomId) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("uid", std::to_string(uid)).addDetail("roomid", std::to_string(roomId)));

	_iSubcribeUid = 0;
	_iSubcribeRoomId = 0;

	_oRight.hide();
	setRightView(uid, 0, 0, false);
	setLeftView(_oLeft._iUid, _oLeft._iWidth, _oLeft._iHeight, _oLeft._iHwnd);

	if (roomId != RoomInfo::GetInstance()->_iRoomId) {
		MediaManager::instance()->getThunderManager()->removeSubscribe(std::to_string(roomId).c_str(), std::to_string(uid).c_str());
	}
	else {
		breakSelf(uid);
	}
}

int ThunderMeetUI::joinRoom(int64_t uid, int64_t roomId, std::string token) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("uid", std::to_string(uid)).addDetail("roomid", std::to_string(roomId)));
	MediaManager::instance()->getThunderManager()->setMediaMode(PROFILE_DEFAULT);
	MediaManager::instance()->getThunderManager()->setRoomMode(ROOM_CONFIG_COMMUNICATION);
	return MediaManager::instance()->getThunderManager()->joinRoom(token.c_str(), token.size(),
		std::to_string(roomId).c_str(), std::to_string(uid).c_str());
}

void ThunderMeetUI::leaveRoom() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	if (_iSubcribeUid != 0) {
		MediaManager::instance()->getThunderManager()->removeSubscribe(std::to_string(_iSubcribeRoomId).c_str(), std::to_string(_iSubcribeUid).c_str());
		_iSubcribeUid = 0;
		_iSubcribeRoomId = 0;
	}

	// 退出房间一定要重置
	setLeftView(_oLeft._iUid, _oLeft._iWidth, _oLeft._iHeight, nullptr);
	setRightView(_oRight._iUid, _oRight._iWidth, _oRight._iHeight, false, nullptr);

	MediaManager::instance()->getThunderManager()->setLocalVideoMirrorMode(THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR);
	MediaManager::instance()->getThunderManager()->stopLocalAudioStream(true);
	MediaManager::instance()->getThunderManager()->stopLocalVideoStream(true);
	MediaManager::instance()->getThunderManager()->stopVideoPreview();
	MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->stopVideoDeviceCapture();
	MediaManager::instance()->getThunderManager()->leaveRoom();

	MediaManager::instance()->getThunderManager()->registerVideoCaptureObserver(nullptr);
	
	// 清理所有的美颜效果
}

void ThunderMeetUI::beginLiving() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	// 设置默认
	restartVideoDevice();
	restartMicphoneDevice();
	MediaManager::instance()->getThunderManager()->setLocalVideoMirrorMode(THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR);
	MediaManager::instance()->getThunderManager()->startVideoPreview();
	setLeftView(LocalUserInfo::GetInstance()->_iUid, 1, 0, _oLeft._iHwnd);
}

void ThunderMeetUI::linkSelf(int64_t uid) {
	if (uid == LocalUserInfo::GetInstance()->_iUid) {
		Logd(TAG, Log(__FUNCTION__).setMessage("entry")
			.addDetail("uid", std::to_string(uid)));
		//setRightView(uid, 0, 0, true, (HWND)_oRight._pCanvas->winId());
		restartVideoDevice();
		restartMicphoneDevice();
		resetVideoConfig();
		MediaManager::instance()->getThunderManager()->stopLocalAudioStream(false);
		MediaManager::instance()->getThunderManager()->stopLocalVideoStream(false);
		MediaManager::instance()->getThunderManager()->setLocalVideoMirrorMode(THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR);
		MediaManager::instance()->getThunderManager()->startVideoPreview();
	}
}

void ThunderMeetUI::breakSelf(int64_t uid) {
	if (uid == LocalUserInfo::GetInstance()->_iUid) {
		Logd(TAG, Log(__FUNCTION__).setMessage("entry")
			.addDetail("uid", std::to_string(uid)));
		// 如果是自己，就取消推流
		MediaManager::instance()->getThunderManager()->setLocalVideoMirrorMode(THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR);
		MediaManager::instance()->getThunderManager()->stopLocalAudioStream(true);
		MediaManager::instance()->getThunderManager()->stopLocalVideoStream(true);
		MediaManager::instance()->getThunderManager()->stopVideoPreview();
		MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->stopVideoDeviceCapture();
	}
}

void ThunderMeetUI::setLeftView(int64_t uid, int width, int height, HWND hwnd) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("uid", std::to_string(uid)).addDetail("width", std::to_string(width))
		.addDetail("height", std::to_string(height)));

	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("hwnd", std::to_string((long long)hwnd)));

	if (_iSubcribeUid != 0) {
		// 2个视图
		showCanvas(false);
	}
	else {
		showCanvas(true);
	}

	if (uid == 0) {
		Logd(TAG, Log(__FUNCTION__).setMessage("input uid = 0, exit"));
		return;
	}

	VideoCanvas canvas;
	sprintf_s(canvas.uid, "%I64d", uid);
	canvas.hWnd = hwnd;

	_oLeft._iWidth = width;
	_oLeft._iHeight = height;
	_oLeft._iUid = uid;

	if (uid == LocalUserInfo::GetInstance()->_iUid) {
		// 如果都是自己，都可以是 fit
		canvas.renderMode = VIDEO_RENDER_MODE_ASPECT_FIT;
		MediaManager::instance()->getThunderManager()->setLocalVideoCanvas(canvas);
	}
	else {
		canvas.renderMode = VIDEO_RENDER_MODE_ASPECT_FIT;
		if (_oRight._bLinking) {
			if (_oLeft._iWidth <= _oLeft._iHeight) {
				canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
			}
		}

		MediaManager::instance()->getThunderManager()->setRemoteVideoCanvas(canvas);
	}
}

void ThunderMeetUI::setRightView(int64_t uid, int width, int height, bool link, HWND hwnd) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("uid", std::to_string(uid)).addDetail("width", std::to_string(width))
		.addDetail("height", std::to_string(height)));

	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("hwnd", std::to_string((long long)hwnd)));

	if (hwnd != nullptr) {
		_oRight.show();
		showCanvas(false);
	}
	else {
		_oRight.hide();
		showCanvas(true);
	}

	_oRight._iWidth = width;
	_oRight._iHeight = height;
	_oRight._iUid = uid;
	_oRight._bLinking = link;

	// 右侧统一改成 fit 模式
	VideoCanvas canvas;
	sprintf_s(canvas.uid, "%I64d", uid);
	canvas.hWnd = hwnd;

	if (uid == LocalUserInfo::GetInstance()->_iUid) {
		canvas.renderMode = VIDEO_RENDER_MODE_ASPECT_FIT;
		MediaManager::instance()->getThunderManager()->setLocalVideoCanvas(canvas);
	}
	else {
		if (_oRight._iWidth >= _oRight._iHeight) {
			canvas.renderMode = VIDEO_RENDER_MODE_ASPECT_FIT;
		}
		else {
			canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
		}
		MediaManager::instance()->getThunderManager()->setRemoteVideoCanvas(canvas);
	}
}

void ThunderMeetUI::restartVideoDevice() {
	VideoDeviceList videoDevList;
	IVideoDeviceManager* manager = MediaManager::instance()->getThunderManager()->getVideoDeviceMgr();
	if (manager != NULL) {
		manager->enumVideoDevices(videoDevList);
		if (videoDevList.count != 0) {
			manager->startVideoDeviceCapture(videoDevList.device[0].index);
		}
	}
}

void ThunderMeetUI::restartMicphoneDevice() {
	AudioDeviceList audioDevList;
	IAudioDeviceManager* manager = MediaManager::instance()->getThunderManager()->getAudioDeviceMgr();
	if (manager != NULL) {
		manager->enumInputDevices(audioDevList);
		// 设置默认
		if (audioDevList.count != 0) {
			manager->setInputtingDevice(audioDevList.device[0].id);
		}
	}
}

void ThunderMeetUI::resetVideoConfig() {
	VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = _eMode;
	MediaManager::instance()->getThunderManager()->setVideoEncoderConfig(config);
}

void ThunderMeetUI::onJoinRoomSuccessJ(const QString& roomName, const QString& uid, int elapsed) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry")
		.addDetail("roomName", roomName.toStdString()).addDetail("uid", uid.toStdString()));
	if (RoomInfo::GetInstance()->_eUserRole == RoomInfo::UserRole::Anchor) {
		// 这块有问题，需要延迟开播
		resetVideoConfig();
		MediaManager::instance()->getThunderManager()->stopLocalAudioStream(false);
		MediaManager::instance()->getThunderManager()->stopLocalVideoStream(false);
	}

	// 如果不在一个房间需要订阅
	auto u = RoomInfo::GetInstance()->_oLinkUserList.begin();
	if (u != RoomInfo::GetInstance()->_oLinkUserList.end()) {
		subcribe((*u)->_iUid, (*u)->_iRoomId);
	}
}

void ThunderMeetUI::onLeaveRoomJ() {
	// do nothing
}

void ThunderMeetUI::onRemoteAudioStoppedJ(const QString& uid, bool stop) {
	// do nothing
}

void ThunderMeetUI::onRemoteVideoStoppedJ(const QString& uid, bool stop) {
	//Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString()));
	//// 如果是远程，关闭远程用户
	//if (stop) {
	//	//setRightView(uid.toInt(), 0, 0, false, nullptr);
	//	//setLeftView(_oLeft._iUid, _oLeft._iWidth, _oLeft._iHeight, (HWND)_oLeft._pCanvas->winId());
	//}
	//else {

	//}
}

void ThunderMeetUI::onConnectionStatusJ(ThunderConnectionStatus status) {
	if (status == THUNDER_CONNECTION_STATUS_CONNECTING) {
		// 显示提示框
	}
}

void ThunderMeetUI::onTokenWillExpireJ(const QString& token) {
	// 显示提示框
}

void ThunderMeetUI::onVideoCaptureStatusJ(int status) {
	if (status == THUNDER_VIDEO_CAPTURE_STATUS_RESTRICTED || status == THUNDER_VIDEO_CAPTURE_STATUS_DENIED) {
		// 显示提示框，被占用
		MessageBoxNormalUI::GetInstance()->showDialog(QApplication::translate("ThunderMeetUI", "CameraDenied", 0), MessageBoxNormalUIShowType::CAMERA_ERROR, nullptr);
	}
}

void ThunderMeetUI::onFirstLocalVideoFrameSentJ(int elapsed) {
}

void ThunderMeetUI::onRemoteVideoPlayJ(const QString& uid, int width, int height, int elapsed) {
	//int64_t iUid = uid.toInt();
	//if (RoomInfo::GetInstance()->_pRoomAnchor->_iUid == iUid) {
	//	// 渲染主播，主播一定在左边
	//	setLeftView(iUid, (width > height), (HWND)_pLeft->winId());
	//}
	//else {
	//	setRightView(iUid, (width > height), (HWND)_pRight->winId());
	//}
}

void ThunderMeetUI::onVideoSizeChangedJ(const QString& uid, int width, int height, int elapsed) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("uid", uid.toStdString())
		.addDetail("width", std::to_string(width)).addDetail("height", std::to_string(height)));
	int64_t iUid = uid.toInt();
	if (RoomInfo::GetInstance()->_pRoomAnchor->_iUid == iUid) {
		// 渲染主播，主播一定在左边
		setLeftView(iUid, width, height, _oLeft._iHwnd);
	}
	else {
		setRightView(iUid, width, height, true, _oRight._iHwnd);
		setLeftView(_oLeft._iUid, _oLeft._iWidth, _oLeft._iHeight, _oLeft._iHwnd);
	}
}

void ThunderMeetUI::showCanvas(bool one) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("one", std::to_string(one)));
	if (one) {
		_oLeft._pCanvas->setGeometry(QRect(0, 0, 832, 624));
		_oRight.hide();
		emit onShowOneCanvas();
	}
	else {
		_oLeft._pCanvas->setGeometry(QRect(0, 0, 416, 624));
		_oRight.show();
		emit onShowTwoCanvas();
	}
}

