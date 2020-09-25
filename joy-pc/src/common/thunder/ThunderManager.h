#pragma once

#include <windows.h>
#include "../3rd/Thunderbolt/include/IThunderEngine.h"
#include <iostream>
using namespace Thunder;

class ThunderManager {
public:
	ThunderManager();
	~ThunderManager();

	int init(const char* appId, int sceneId, IThunderEventHandler* pHandler);
	int deInit();
	int setMediaMode(THUNDER_PROFILE mode);
	int setRoomMode(ROOM_CONFIG_TYPE mode);
	int joinRoom(const char* token, int tokenLen, const char* roomName, const char* uid);
	int leaveRoom();
	int updateToken(const char* token, int tokenLen);
	int enableAudioEngine();
	int setArea(AREA_TYPE area);
	int disableAudioEngine();
	int enableVideoEngine();
	int disableVideoEngine();
	int setLocalVideoCanvas(const VideoCanvas& canvas);
	int setRemoteVideoCanvas(const VideoCanvas& canvas);
	int startVideoPreview();
	int stopVideoPreview();
	int setLocalCanvasScaleMode(VideoRenderMode mode);
	int setRemoteCanvasScaleMode(VideoRenderMode mode);
	int setAudioVolumeIndication(int interval, int smooth);
	int enableLoopbackRecording(bool enabled);
	int stopLocalVideoStream(bool stop);
	int stopLocalAudioStream(bool stop);
	int stopRemoteVideoStream(const char* uid, bool stop);
	int stopRemoteAudioStream(const char* uid, bool stop);
	int setAudioConfig(AUDIO_PROFILE_TYPE profile, COMMUT_MODE commutMode, SCENARIO_MODE scenarioMode);
	int setVideoEncoderConfig(const VideoEncoderConfiguration& config);
	int setLiveTranscodingTask(const char* taskId, const LiveTranscoding& transcodingCfg);
	int removeLiveTranscodingTask(const char* taskId);
	int addPublishTranscodingStreamUrl(const char* taskId, const char* url);
	int removePublishTranscodingStreamUrl(const char* taskId, const char* url);
	int addSubscribe(const char* roomId, const char* uid);
	int removeSubscribe(const char* roomId, const char* uid);
	int setLogFilePath(const char* filePath);
	int setLogLevel(LOG_FILTER filter);
	int startScreenCaptureForScreen(int screenId, const RECT * pRect);
	int setLocalVideoMirrorMode(ThunderVideoMirrorMode mode);
	int registerVideoCaptureObserver(IVideoCaptureObserver* observer);
	IVideoDeviceManager* getVideoDeviceMgr();
	IAudioDeviceManager* getAudioDeviceMgr();

private:
	IThunderEngine* _pThunderEngine;
	bool	_bIsInit;
	std::string _strAppid;
};
