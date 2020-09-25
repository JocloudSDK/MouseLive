#include "MediaManager.h"
#include "../../../common/log/loggerExt.h"

using namespace base;

static const char* TAG = "MediaManager";

MediaManager* MediaManager::_pInstance = NULL;

void MediaManager::create() {
	if (_pInstance == NULL) {
		_pInstance = new MediaManager();
	}
}

void MediaManager::release() {
	if (_pInstance != NULL) {
		delete _pInstance;
		_pInstance = NULL;
	}
}

MediaManager* MediaManager::instance() {
	return _pInstance;
}

MediaManager::MediaManager() {
	_pThunderManager = new ThunderManager();
}

MediaManager::~MediaManager() {
	if (_pThunderManager) {
		_pThunderManager->deInit();
		delete _pThunderManager;
		_pThunderManager = NULL;
	}
}

int MediaManager::init(const char* appId, int sceneId) {
	return _pThunderManager->init(appId, sceneId, this);
}

int MediaManager::deInit() {
	return _pThunderManager->deInit();
}

ThunderManager* MediaManager::getThunderManager() {
	return _pThunderManager;
}

void MediaManager::onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed) {
	emit onJoinRoomSuccessJ(roomName, uid, elapsed);
}

void MediaManager::onLeaveRoom() {
	emit onLeaveRoomJ();
}

void MediaManager::onRemoteAudioStopped(const char * uid, bool stop) {
	emit onRemoteAudioStoppedJ(uid, stop);
}

void MediaManager::onRemoteVideoStopped(const char* uid, bool stop) {
	emit onRemoteVideoStoppedJ(uid, stop);
}

void MediaManager::onVideoSizeChanged(const char* uid, int width, int height, int rotation) {
	Logd(TAG, Log(__FUNCTION__).addDetail("uid", uid).addDetail("width", std::to_string(width))
		.addDetail("height", std::to_string(height)).addDetail("rotation", std::to_string(rotation)));
	emit onVideoSizeChangedJ(uid, width, height, rotation);
}

void MediaManager::onRemoteVideoPlay(const char* uid, int width, int height, int elapsed) {
	emit onRemoteVideoPlayJ(uid, width, height, elapsed);
}

void MediaManager::onTokenWillExpire(const char* token) {
	emit onTokenWillExpireJ(token);
}

void MediaManager::onFirstLocalVideoFrameSent(int elapsed) {
	emit onFirstLocalVideoFrameSentJ(elapsed);
}

void MediaManager::onConnectionStatus(ThunderConnectionStatus status) {
	emit onConnectionStatusJ(status);
}

void MediaManager::onVideoCaptureStatus(int status) {
	emit onVideoCaptureStatusJ(status);
}

void MediaManager::OnAudioDeviceStateChange(const char* deviceId, int deviceType, int deviceState) {
	return;
	//Logd(TAG, Log(__FUNCTION__).addDetail("deviceId", deviceId).addDetail("deviceState", std::to_string(deviceState))
	//	.addDetail("deviceType", std::to_string(deviceType)));

	//DeviceDetected* device = new DeviceDetected();
	//device->deviceId = new char[strlen(deviceId) + 1];
	//memset(device->deviceId, 0, strlen(deviceId) + 1);
	//memcpy(device->deviceId, deviceId, strlen(deviceId));
	//device->deviceState = (MEDIA_DEVICE_STATE_TYPE)deviceState;
	//device->deviceType = (MEDIA_DEVICE_TYPE)deviceType;
	//::PostMessage(m_hMessageDlg, WM_DEVICE_DETECTED, (WPARAM)device, 0);
}
