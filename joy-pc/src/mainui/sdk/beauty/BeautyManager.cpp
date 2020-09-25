#include "BeautyManager.h"
#include "pathutils.h"
#include "../../AppInfo.h"
#include "../../../common/log/loggerExt.h"
#include "CSLock.h"

using namespace base;

static const char* TAG = "BeautyManager";

//小端模式，RGBA中R存储在低位，A存储在高位
void bgra2rbga(unsigned char *buffer, int width, int height)
{
	unsigned int *rbga = (unsigned int *)buffer;
	for (int i = 0; i < width * height; i++) {
		rbga[i] = (rbga[i] & 0xFF000000) |         // ______AA
			((rbga[i] & 0x00FF0000) >> 16) | // RR______
			(rbga[i] & 0x0000FF00) |         // __GG____
			((rbga[i] & 0x000000FF) << 16);  // ____BB__
	}
}

void rbga2bgra(unsigned char *buffer, int width, int height)
{
	unsigned int *bgra = (unsigned int *)buffer;
	for (int i = 0; i < width * height; i++) {
		bgra[i] = (bgra[i] & 0xFF000000) |         // ______AA
			((bgra[i] & 0x00FF0000) >> 16) | // BB______
			(bgra[i] & 0x0000FF00) |         // __GG____
			((bgra[i] & 0x000000FF) << 16);  // ____RR__
	}
}

//大端模式，RGBA中R存储在高位，A存储在低位
//void bgra2rbga(unsigned char *buffer, int width, int height)
//{
//	unsigned int *rbga = (unsigned int *)buffer;
//	for (int i = 0; i < width * height; i++) {
//		rbga[i] = (rbga[i] & 0x000000FF) |         // ______AA
//			((rbga[i] & 0x0000FF00) << 16) | // RR______
//			(rbga[i] & 0x00FF0000) |         // __GG____
//			((rbga[i] & 0xFF000000) >> 16);  // ____BB__
//	}
//}
//
//void rbga2bgra(unsigned char *buffer, int width, int height)
//{
//	unsigned int *bgra = (unsigned int *)buffer;
//	for (int i = 0; i < width * height; i++) {
//		bgra[i] = (bgra[i] & 0x000000FF) |         // ______AA
//			((bgra[i] & 0x0000FF00) << 16) | // BB______
//			(bgra[i] & 0x00FF0000) |         // __GG____
//			((bgra[i] & 0xFF000000) >> 16);  // ____RR__
//	}
//}

/*
https://git.yy.com/ai/graph_and_image_processing/OFCamera.git  master
SHA - 1: ebe183881c1a8bc257f795abe01a580866ffbe8e
* update ofcamera pc version 1.4.2
*/

static void OF_LogCallbackFun(const char* fmtMsg) {
	Logd(TAG, Log(__FUNCTION__).addDetail("OF => ", fmtMsg));
}

BeautyManager::BeautyManager() {

}

BeautyManager::~BeautyManager() {
	closeOFThread();
}

bool BeautyManager::setup() {
	// 启动线程
	_pOrangeFilterRender.reset(new OrangeFilterRender);
	OF_SetLogLevel(OF_LogLevel_Info);
	OF_SetLogCallback(OF_LogCallbackFun);
	if (_pOrangeFilterRender->checkSerialNumber(CurrentApplicationDirA().c_str(), STR_OF_CAMERA_NUMBER.toStdString())) {
		if (openOFThread()) {
			_bCheckOrangeFilter = true;
			Logd(TAG, Log(__FUNCTION__).setMessage("setup success"));
			return true;
		}
		Logd(TAG, Log(__FUNCTION__).setMessage("openOFThread failed"));
	}
	_pOrangeFilterRender->unInit();
	_pOrangeFilterRender.reset();
	Logd(TAG, Log(__FUNCTION__).setMessage("setup failed"));
	return false;
}

void BeautyManager::updateFrame(Thunder::VideoFrame& videoFrame) {
	// 如果需要美颜，在走这里
	if (!_bCheckOrangeFilter) {
		return;
	}

	if (_iWidth != videoFrame.width || _iHeight != videoFrame.height) {
		_iWidth = videoFrame.width;
		_iHeight = videoFrame.height;
	}

	switch (videoFrame.type) {
	case Thunder::FRAME_TYPE_YUV420:
	{
		// 需要 420 转 RGBA -- libyuv
		//_pOrangeFilterRender->applyFrame(_pBuffer.get(), _pBuffer.get(), _iWidth, _iHeight);
		// 需要 RGBA 转 420 -- libyuv
		break;
	}
	case Thunder::FRAME_TYPE_BGRA:
	{
		_oVideoOFFrame._pBuffer = (uint8_t*)videoFrame.dataPtr[0];
		_oVideoOFFrame._pOutBuffer = (uint8_t*)videoFrame.dataPtr[0];
		_oVideoOFFrame._iHeight = _iHeight;
		_oVideoOFFrame._iWidth = _iWidth;
		_oVideoOFFrame._iRotation = videoFrame.rotation;
		if (_bEnableBGRA) {
			_oVideoOFFrame._eFormat = OrangeFilterRenderFormat::BGRA;
			insertFrame();
		}
		else {
			_oVideoOFFrame._eFormat = OrangeFilterRenderFormat::RGBA;
			bgra2rbga((uint8_t*)videoFrame.dataPtr[0], _iWidth, _iHeight);
			insertFrame();
			rbga2bgra((uint8_t*)videoFrame.dataPtr[0], _iWidth, _iHeight);
		}
		
		break;
	}
	default:
		break;
	}
}

void BeautyManager::enableEffect(OrangeHelper::EffectType effectType, bool enabled) {
	std::shared_ptr<Action> action;
	action.reset(new Action);
	action->_eEffectType = effectType;
	action->_iCmd = ActionCmd::Effect;
	action->_bEnabled = enabled;
	{
		std::unique_lock<std::mutex> loc(_oActionListMutex);
		_oActionList.emplace_back(action);
	}
}

void BeautyManager::enableSticker(const std::string& path, bool enabled) {
	std::shared_ptr<Action> action;
	action.reset(new Action);
	action->_iCmd = ActionCmd::Sticker;
	action->_strCurrentPath = path;
	action->_bEnabled = enabled;
	{
		std::unique_lock<std::mutex> loc(_oActionListMutex);
		_oActionList.emplace_back(action);
	}
}

void BeautyManager::releaseCurrentSticker() {
	std::shared_ptr<Action> action;
	action.reset(new Action);
	action->_iCmd = ActionCmd::ClearCurrentSticker;
	{
		std::unique_lock<std::mutex> loc(_oActionListMutex);
		_oActionList.emplace_back(action);
	}
}

void BeautyManager::enableGesture(const std::string& path, bool enabled) {
	std::shared_ptr<Action> action;
	action.reset(new Action);
	action->_iCmd = ActionCmd::Gesture;
	action->_strCurrentPath = path;
	action->_bEnabled = enabled;
	{
		std::unique_lock<std::mutex> loc(_oActionListMutex);
		_oActionList.emplace_back(action);
	}
}

void BeautyManager::clearAllGesture() {
	std::shared_ptr<Action> action;
	action.reset(new Action);
	action->_iCmd = ActionCmd::ClearAllGesture;
	{
		std::unique_lock<std::mutex> loc(_oActionListMutex);
		_oActionList.emplace_back(action);
	}
}

int BeautyManager::getEffectParam(OrangeHelper::EffectParamType paramType) {
	if (!_pOrangeFilterRender) {
		Logd(TAG, Log(__FUNCTION__).setMessage("_pOrangeFilterRender is null"));
		return -1;
	}
	return _pOrangeFilterRender->getEffectParam(paramType);
}

int BeautyManager::getEffectParamDetail(OrangeHelper::EffectParamType paramType, OrangeHelper::EffectParam& paramVal) {
	if (!_pOrangeFilterRender) {
		Logd(TAG, Log(__FUNCTION__).setMessage("_pOrangeFilterRender is null"));
		return -1;
	}
	return _pOrangeFilterRender->getEffectParamDetail(paramType, paramVal);
}

bool BeautyManager::setEffectParam(OrangeHelper::EffectParamType paramType, int value) {
	if (!_pOrangeFilterRender) {
		Logd(TAG, Log(__FUNCTION__).setMessage("_pOrangeFilterRender is null"));
		return false;
	}
	return _pOrangeFilterRender->setEffectParam(paramType, value);
}

void BeautyManager::clearAll() {
	// 暂时无用
	if (_pOrangeFilterRender) {
		_pOrangeFilterRender->clearAll();
	}
}

// ======== opengl 渲染线程
unsigned int BeautyManager::processThread() {
	bool r = initOFEnv();
	_oProcessEvent.SetEvent();
	if (r) {
		_bWorking = true;
		while (!_bProcessExit) {
			if (_bReceiveFrame) {
				_bReceiveFrame = false;
				processFrame();
				_oProcessEvent.SetEvent();
			}
			Sleep(10);   // 这里最好也修改掉
		}
		_bWorking = false;
		deinitOFEnv();
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("exit, initOFEnv error"));
	}

	return 0;
}

bool BeautyManager::insertFrame() {
	_bReceiveFrame = true;
	if (_bWorking) {
		_oProcessEvent.ResetEvent();
		_oProcessEvent.Wait();
	}
	return true;
}

bool BeautyManager::processFrame() {
	bool bRet = false;

	std::list<std::shared_ptr<Action>> actionList;
	{
		std::unique_lock<std::mutex> loc(_oActionListMutex);
		for (auto a = _oActionList.begin(); a != _oActionList.end(); a++) {
			actionList.emplace_back((*a));
		}
		_oActionList.clear();
	}

	for (auto a = actionList.begin(); a != actionList.end(); a++) {
		bool ret = false;
		switch ((*a)->_iCmd) {
		case ActionCmd::None:
			break;
		case ActionCmd::Effect:
			ret = _pOrangeFilterRender->enableEffect((*a)->_eEffectType, (*a)->_bEnabled);
			break;
		case ActionCmd::Sticker:
			ret = _pOrangeFilterRender->enableSticker((*a)->_strCurrentPath, (*a)->_bEnabled);
			break;
		case ActionCmd::ClearCurrentSticker:
			ret = _pOrangeFilterRender->releaseCurrentSticker();
			break;
		case ActionCmd::Gesture:
			ret = _pOrangeFilterRender->enableGesture((*a)->_strCurrentPath, (*a)->_bEnabled);
			break;
		case ActionCmd::ClearAllGesture:
			_pOrangeFilterRender->clearAllGesture();
			break;
		default:
			break;
		}
		Logd(TAG, Log(__FUNCTION__).addDetail("_iCmd", std::to_string((*a)->_iCmd))
			.addDetail("_eEffectType", std::to_string((*a)->_eEffectType))
			.addDetail("_bEnabled", std::to_string((*a)->_bEnabled))
			.addDetail("_strCurrentPath", (*a)->_strCurrentPath.c_str())
			.addDetail("ret", std::to_string(ret)));
	}

	if (_pOrangeFilterRender->applyFrame(_oVideoOFFrame._pBuffer, _oVideoOFFrame._pOutBuffer,
		_oVideoOFFrame._iWidth, _oVideoOFFrame._iHeight, _oVideoOFFrame._eFormat)) {
	}
	return true;
}

bool BeautyManager::openOFThread() {
	if (_pOFThread == nullptr) {
		_pOFThread = new std::thread(&BeautyManager::processThread, this);
		_oProcessEvent.ResetEvent();
		_oProcessEvent.Wait();
	}
	return _pOFThread != NULL;
}

void BeautyManager::closeOFThread() {
	_bProcessExit = true;
	DWORD ret = 0;

	if (_pOFThread && _pOFThread->joinable()) {
		_pOFThread->join();
		delete _pOFThread;
		_pOFThread = nullptr;
	}
}

bool BeautyManager::initOFEnv() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));

	// 初始 opengl 环境
	if (!_oRuntimeEnvironment.OFWindowInit() == OF_Result_Success) {
		Logd(TAG, Log(__FUNCTION__).setMessage("OFWindowInit failed"));
		return false;
	}

#if 0
	static const char* g_CheckFeature[4] = {
		"GL_EXT_vertex_array_bgra",
		"GL_EXT_bgra",
		"GL_BGR_EXT",
		"GL_BGRA_EXT",
	};

	if (_oRuntimeEnvironment.CheckOpenglSupport("GL_EXT_bgra")) {
		Logd(TAG, Log(__FUNCTION__).setMessage("have GL_EXT_bgra"));
		_bEnableBGRA = true;
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("no GL_EXT_bgra"));
	}
	if (_oRuntimeEnvironment.CheckOpenglSupport("GL_BGR_EXT")) {
		Logd(TAG, Log(__FUNCTION__).setMessage("have GL_BGR_EXT"));
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("no GL_BGR_EXT"));
	}
	if (_oRuntimeEnvironment.CheckOpenglSupport("GL_BGRA_EXT")) {
		Logd(TAG, Log(__FUNCTION__).setMessage("have GL_BGRA_EXT"));
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("no GL_BGRA_EXT"));
	}
#endif

	// 初始美颜
	_pOrangeFilterRender->init();
	Logd(TAG, Log(__FUNCTION__).setMessage("success"));
	return true;
}

void BeautyManager::deinitOFEnv() {
	_pOrangeFilterRender->unInit();
	_pOrangeFilterRender.reset();

	// 删除美颜特效
	_oRuntimeEnvironment.OFWindowUninit();
}