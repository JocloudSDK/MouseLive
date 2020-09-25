#pragma once

#include "OrangeFilterRender.h"
#include <memory>
#include <thread>
#include "../../../common/utils/Singleton.h"
#include <windows.h>
#include "../../../3rd/Thunderbolt/include/IThunderEngine.h"
#include "GLRuntimeEnvironment.h"
#include "UEvent.h"
#include <mutex>

#define MAX_THUNDER_VIDEO_BUFFER_PLANE 8

class BeautyManager : public Singleton<BeautyManager> {
protected:
	struct VideoOFFrame {
		uint8_t* _pBuffer; // BGRA/RGBA
		uint8_t* _pOutBuffer;
		int _iWidth; // Width of video frame
		int _iHeight; // Width and height of video frame
		int _iRotation; // Rotation angle ，没有用到，保留
		OrangeFilterRenderFormat _eFormat;
	};

	enum ActionCmd {
		None,
		Effect,
		Sticker,
		Gesture,
		ClearAllGesture,
		ClearCurrentSticker,
	};

	struct Action {
		ActionCmd _iCmd = ActionCmd::None;
		OrangeHelper::EffectType _eEffectType;
		std::string _strCurrentPath = "";
		bool _bEnabled = false;
	};

protected:
	friend class Singleton<BeautyManager>;

public:
	BeautyManager();
	~BeautyManager();

	bool setup();

	void updateFrame(Thunder::VideoFrame& videoFrame);

	void enableEffect(OrangeHelper::EffectType effectType, bool enabled);
	void enableSticker(const std::string& path, bool enabled);
	void releaseCurrentSticker();
	void enableGesture(const std::string& path, bool enabled);
	void clearAllGesture();
	int getEffectParam(OrangeHelper::EffectParamType paramType);
	int getEffectParamDetail(OrangeHelper::EffectParamType paramType, OrangeHelper::EffectParam& paramVal);
	bool setEffectParam(OrangeHelper::EffectParamType paramType, int value);
	void clearAll();

protected:
	bool initOFEnv();
	void deinitOFEnv();
	bool insertFrame();
	bool processFrame();
	bool openOFThread();
	void closeOFThread();
	unsigned int processThread();

private:
	std::shared_ptr<OrangeFilterRender> _pOrangeFilterRender;
	int _iWidth = 0;
	int _iHeight = 0;

	GLRuntimeEnvironment _oRuntimeEnvironment;
	std::thread* _pOFThread = nullptr;

	bool _bProcessExit = false;
	bool _bReceiveFrame = false;
	bool _bWorking = false;
	UEvent _oProcessEvent;

	VideoOFFrame _oVideoOFFrame;
	std::mutex _oActionListMutex;
	std::list<std::shared_ptr<Action>> _oActionList;
	bool _bEnableBGRA = false;
	bool _bCheckOrangeFilter = false;
};
