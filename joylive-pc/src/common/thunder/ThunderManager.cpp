#include "ThunderManager.h"
#include "../log/loggerExt.h"

using namespace base;
static const char* TAG = "ThunderManager";

ThunderManager::ThunderManager()
: _pThunderEngine(NULL)
, _bIsInit(false)
{
	_pThunderEngine = createEngine();
}

ThunderManager::~ThunderManager()
{
	_bIsInit = false;
}

int ThunderManager::init(const char* appId, int sceneId, IThunderEventHandler* pHandler)
{
	if (_pThunderEngine != NULL)
	{
		Logd(TAG, Log("init").addDetail("AppId", appId).addDetail("SceneId", std::to_string(sceneId)));
		std::string tempAppid(appId);
		if (_bIsInit)
		{
			if (_strAppid != tempAppid)
			{
				_pThunderEngine->destroyEngine();
				_bIsInit = true;
				_strAppid  = tempAppid;
				return _pThunderEngine->initialize(appId, sceneId, pHandler);
			}
		}
		else
		{
			_strAppid = tempAppid;
			_bIsInit = true;
			return _pThunderEngine->initialize(appId, sceneId, pHandler);
		}	
	}
	return -1;
}

int ThunderManager::deInit()
{
	Logd(TAG, Log("deInit"));
	if (_pThunderEngine != NULL)
	{
		if (_bIsInit)
		{
			_pThunderEngine->destroyEngine();
			_bIsInit = false;
		}
		return 0;
	}
	return -1;
}

IVideoDeviceManager* ThunderManager::getVideoDeviceMgr()
{
	if (_pThunderEngine != NULL)
	{
		return _pThunderEngine->getVideoDeviceMgr();
	}
	return NULL;
}

IAudioDeviceManager* ThunderManager::getAudioDeviceMgr()
{
	if (_pThunderEngine != NULL)
	{
		return _pThunderEngine->getAudioDeviceMgr();
	}
	return NULL;
}


#define FUNCTION_PARAM_0(function_name) \
	if (_pThunderEngine != NULL) \
	{ \
		return _pThunderEngine->function_name(); \
	} \
	return -1;

#define FUNCTION_PARAM_1(function_name, param1) \
	if (_pThunderEngine != NULL) \
	{ \
		return _pThunderEngine->function_name(param1); \
	} \
	return -1;

#define FUNCTION_PARAM_2(function_name, param1, param2) \
	if (_pThunderEngine != NULL) \
	{ \
		return _pThunderEngine->function_name(param1, param2); \
	} \
	return -1;

#define FUNCTION_PARAM_3(function_name, param1, param2, param3) \
	if (_pThunderEngine != NULL) \
	{ \
		return _pThunderEngine->function_name(param1, param2, param3); \
	} \
	return -1;

#define FUNCTION_PARAM_4(function_name, param1, param2, param3, param4) \
	if (_pThunderEngine != NULL) \
	{ \
		return _pThunderEngine->function_name(param1, param2, param3, param4); \
	} \
	return -1;

int ThunderManager::setMediaMode(THUNDER_PROFILE mode) {
	Logd(TAG, Log("setMediaMode").addDetail("mode", std::to_string(mode)));
	FUNCTION_PARAM_1(setMediaMode, mode)
}

int ThunderManager::joinRoom(const char* token, int tokenLen, const char* roomName, const char* uid) {
	Logd(TAG, Log("joinRoom").addDetail("Token", token).addDetail("TokenLen", std::to_string(tokenLen)).addDetail("RoomName", roomName).addDetail("Uid", uid));
	FUNCTION_PARAM_4(joinRoom, token, tokenLen, roomName, uid)
}

int ThunderManager::leaveRoom() {
	Logd(TAG, Log("leaveRoom"));
	FUNCTION_PARAM_0(leaveRoom)
}

int ThunderManager::updateToken(const char * token, int tokenLen) {
	Logd(TAG, Log("updateToken").addDetail("Token", token).addDetail("TokenLen", std::to_string(tokenLen)));
	FUNCTION_PARAM_2(updateToken, token, tokenLen)
}

int ThunderManager::setArea(AREA_TYPE area) {
	Logd(TAG, Log("setArea").addDetail("Area", std::to_string(area)));
	FUNCTION_PARAM_1(setArea, area)
}

int ThunderManager::enableAudioEngine() {
	Logd(TAG, Log("enableAudioEngine"));
	FUNCTION_PARAM_0(enableAudioEngine)
}

int ThunderManager::disableAudioEngine() {
	Logd(TAG, Log("disableAudioEngine"));
	FUNCTION_PARAM_0(disableAudioEngine)
}

int ThunderManager::setAudioVolumeIndication(int interval, int smooth) {
	Logd(TAG, Log("setAudioVolumeIndication").addDetail("interval", std::to_string(interval)).addDetail("smooth", std::to_string(smooth)));
	FUNCTION_PARAM_2(setAudioVolumeIndication, interval, smooth)
}

int ThunderManager::enableLoopbackRecording(bool enabled) {
	Logd(TAG, Log("enableLoopbackRecording").addDetail("enabled", std::to_string(enabled)));
	FUNCTION_PARAM_1(enableLoopbackRecording, enabled)
}

int ThunderManager::enableVideoEngine() {
	Logd(TAG, Log("enableVideoEngine"));
	FUNCTION_PARAM_0(enableVideoEngine)
}

int ThunderManager::disableVideoEngine() {
	Logd(TAG, Log("disableVideoEngine"));
	FUNCTION_PARAM_0(disableVideoEngine)
}

int ThunderManager::setLocalVideoCanvas(const VideoCanvas& canvas) {
	Logd(TAG, Log("setLocalVideoCanvas").addDetail("HWnd", std::to_string(canvas.hWnd != nullptr?1:0)).addDetail("renderMode", std::to_string(canvas.renderMode)).addDetail("Uid", canvas.uid));
	FUNCTION_PARAM_1(setLocalVideoCanvas, canvas)
}

int ThunderManager::setRemoteVideoCanvas(const VideoCanvas& canvas) { 
	Logd(TAG, Log("setRemoteVideoCanvas").addDetail("HWnd", std::to_string(canvas.hWnd != nullptr ? 1 : 0)).addDetail("renderMode", std::to_string(canvas.renderMode)).addDetail("Uid", canvas.uid));
	FUNCTION_PARAM_1(setRemoteVideoCanvas, canvas)
}

int ThunderManager::startVideoPreview() {
	Logd(TAG, Log("startVideoPreview"));
	FUNCTION_PARAM_0(startVideoPreview)
}

int ThunderManager::stopVideoPreview() {
	Logd(TAG, Log("stopVideoPreview"));
	FUNCTION_PARAM_0(stopVideoPreview)
}

int ThunderManager::setLocalCanvasScaleMode(VideoRenderMode mode) {
	Logd(TAG, Log("setLocalCanvasScaleMode").addDetail("mode", std::to_string(mode)));
	FUNCTION_PARAM_1(setLocalCanvasScaleMode, mode)
}

int ThunderManager::setRemoteCanvasScaleMode(VideoRenderMode mode) {
	Logd(TAG, Log("setRemoteCanvasScaleMode").addDetail("mode", std::to_string(mode)));
	FUNCTION_PARAM_1(setRemoteCanvasScaleMode, mode)
}

int ThunderManager::stopLocalVideoStream(bool stop) {
	Logd(TAG, Log("stopLocalVideoStream").addDetail("stop", std::to_string(stop)));
	FUNCTION_PARAM_1(stopLocalVideoStream, stop)
}

int ThunderManager::stopLocalAudioStream(bool stop) {
	Logd(TAG, Log("stopLocalAudioStream").addDetail("stop", std::to_string(stop)));
	FUNCTION_PARAM_1(stopLocalAudioStream, stop)
}

int ThunderManager::stopRemoteVideoStream(const char* uid, bool stop) {
	Logd(TAG, Log("stopRemoteVideoStream").addDetail("Uid", uid).addDetail("stop", std::to_string(stop)));
	FUNCTION_PARAM_2(stopRemoteVideoStream, uid, stop)
}

int ThunderManager::stopRemoteAudioStream(const char* uid, bool stop) {
	Logd(TAG, Log("stopRemoteAudioStream").addDetail("Uid", uid).addDetail("stop", std::to_string(stop)));
	FUNCTION_PARAM_2(stopRemoteAudioStream, uid, stop)
}


int ThunderManager::setRoomMode(ROOM_CONFIG_TYPE roomProfile) {
	Logd(TAG, Log("setRoomConfig").addDetail("roomProfile", std::to_string(roomProfile)));
	FUNCTION_PARAM_1(setRoomMode, roomProfile)
}

int ThunderManager::setAudioConfig(AUDIO_PROFILE_TYPE profile, COMMUT_MODE commutMode, SCENARIO_MODE scenarioMode) {
	Logd(TAG, Log("setAudioConfig").addDetail("profile", std::to_string(profile)).addDetail("commutMode", std::to_string(commutMode)).addDetail("scenarioMode", std::to_string(scenarioMode)));
	FUNCTION_PARAM_3(setAudioConfig, profile, commutMode, scenarioMode)
}

int ThunderManager::setVideoEncoderConfig(const VideoEncoderConfiguration& config) {
	Logd(TAG, Log("setVideoEncoderConfig").addDetail("playType", std::to_string(config.playType)).addDetail("publishMode", std::to_string(config.publishMode)));
	FUNCTION_PARAM_1(setVideoEncoderConfig, config)
}

int ThunderManager::setLiveTranscodingTask(const char* taskId, const LiveTranscoding& transcodingCfg) {
	Logd(TAG, Log("setLiveTranscodingTask").addDetail("taskId", taskId).addDetail("transcodingMode", std::to_string(transcodingCfg.transcodingMode)));
	for (int i = 0; i < transcodingCfg.userCount; i++) {
		std::string user = "setLiveTranscodingTask";
		user += "[";
		user += std::to_string(i);
		user += "]";
		Logd(TAG, Log(user)
			.addDetail("bStandard", std::to_string(transcodingCfg.userList[i].bStandard))
			.addDetail("layoutX", std::to_string(transcodingCfg.userList[i].layoutX))
			.addDetail("layoutY", std::to_string(transcodingCfg.userList[i].layoutY))
			.addDetail("layoutW", std::to_string(transcodingCfg.userList[i].layoutW))
			.addDetail("layoutH", std::to_string(transcodingCfg.userList[i].layoutH))
			.addDetail("zOrder", std::to_string(transcodingCfg.userList[i].zOrder))
			.addDetail("bCrop", std::to_string(transcodingCfg.userList[i].bCrop))
			.addDetail("cropX", std::to_string(transcodingCfg.userList[i].cropX))
			.addDetail("cropY", std::to_string(transcodingCfg.userList[i].cropY))
			.addDetail("cropW", std::to_string(transcodingCfg.userList[i].cropW))
			.addDetail("cropH", std::to_string(transcodingCfg.userList[i].cropH))
			.addDetail("alpha", std::to_string(transcodingCfg.userList[i].alpha))
			.addDetail("alpha", std::to_string(transcodingCfg.userList[i].alpha))
			.addDetail("audioChannel", std::to_string(transcodingCfg.userList[i].audioChannel))
			.addDetail("uid", transcodingCfg.userList[i].uid)
			.addDetail("roomId", transcodingCfg.userList[i].roomId)
		);
	}
	FUNCTION_PARAM_2(setLiveTranscodingTask, taskId, transcodingCfg)
}

int ThunderManager::removeLiveTranscodingTask(const char* taskId) {
	Logd(TAG, Log("removeLiveTranscodingTask").addDetail("taskId", taskId));
	FUNCTION_PARAM_1(removeLiveTranscodingTask, taskId)
}

int ThunderManager::addPublishTranscodingStreamUrl(const char* taskId, const char* url) {
	Logd(TAG, Log("addPublishTranscodingStreamUrl").addDetail("taskId", taskId).addDetail("Url", url));
	FUNCTION_PARAM_2(addPublishTranscodingStreamUrl, taskId, url)
}

int ThunderManager::removePublishTranscodingStreamUrl(const char* taskId, const char* url) {
	Logd(TAG, Log("removePublishTranscodingStreamUrl").addDetail("taskId", taskId).addDetail("Url", url));
	FUNCTION_PARAM_2(removePublishTranscodingStreamUrl, taskId, url)
}

int ThunderManager::addSubscribe(const char* roomId, const char* uid) {
	Logd(TAG, Log("addSubscribe").addDetail("RoomId", roomId).addDetail("Uid", uid));
	FUNCTION_PARAM_2(addSubscribe, roomId, uid)
}

int ThunderManager::removeSubscribe(const char* roomId, const char* uid) {
	Logd(TAG, Log("removeSubscribe").addDetail("RoomId", roomId).addDetail("Uid", uid));
	FUNCTION_PARAM_2(removeSubscribe, roomId, uid)
}

int ThunderManager::setLogFilePath(const char* filePath) {
	Logd(TAG, Log("setLogFilePath").addDetail("filePath", filePath));
	FUNCTION_PARAM_1(setLogFilePath, filePath)
}

int ThunderManager::setLogLevel(LOG_FILTER filter) {
	Logd(TAG, Log("setLogLevel").addDetail("filter", std::to_string(filter)));
	FUNCTION_PARAM_1(setLogLevel, filter)
}

int ThunderManager::startScreenCaptureForScreen(int screenId, const RECT * pRect) {
	Logd(TAG, Log("startScreenCaptureForScreen").addDetail("screenId", std::to_string(screenId)));
	if (pRect != nullptr)
		Logd(TAG, Log("startScreenCaptureForScreen").setMessage("left = %d, top = %d, right = %d, bottom = %d", pRect->left, pRect->top, pRect->right, pRect->bottom));
	FUNCTION_PARAM_2(startScreenCaptureForScreen, screenId, pRect)
}

int ThunderManager::setLocalVideoMirrorMode(ThunderVideoMirrorMode mode) {
	Logd(TAG, Log("setLocalVideoMirrorMode").addDetail("mode", std::to_string(mode)));
	FUNCTION_PARAM_1(setLocalVideoMirrorMode, mode)
}

int ThunderManager::registerVideoCaptureObserver(IVideoCaptureObserver* observer) {
	Logd(TAG, Log("registerVideoCaptureObserver").setMessage("==="));
	FUNCTION_PARAM_1(registerVideoCaptureObserver, observer)
}
