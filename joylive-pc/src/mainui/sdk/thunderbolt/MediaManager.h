#pragma once

#include "../../../common/thunder/ThunderManager.h"
#include <sstream>
#include <QObject>

using namespace std;

/// Added hot swap of equipment
struct DeviceDetected {
	char* deviceId;
	MEDIA_DEVICE_TYPE deviceType;
	MEDIA_DEVICE_STATE_TYPE deviceState;
};

/// thunder event implement
class  MediaManager 
	: public QObject, public IThunderEventHandler
{
	Q_OBJECT
public:
	virtual ~ MediaManager();
	static void create();
	static void release();
	static MediaManager* instance();

	int init(const char* appId, int sceneId);
	int deInit();
	virtual void onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed);
	virtual void onLeaveRoom();
	virtual void onPlayVolumeIndication(const AudioVolumeInfo* speakers, int speakerCount, int totalVolume) {};
	virtual void onInputVolume(unsigned volume) {}
	virtual void onOutputVolume(unsigned volume) {}
	virtual void onRemoteAudioStopped(const char* uid, bool stop);
	virtual void onRemoteVideoStopped(const char* uid, bool stop);
	virtual void onVideoSizeChanged(const char* uid, int width, int height, int rotation);
	virtual void onRemoteVideoPlay(const char* uid, int width, int height, int elapsed);
	virtual void onBizAuthResult(bool bPublish, AUTH_RESULT result) {}
	virtual void onSdkAuthResult(AUTH_RESULT result) {}
	virtual void onTokenWillExpire(const char* token);
	virtual void onTokenRequest() {}
	virtual void onUserBanned(bool status) {}
	virtual void onUserJoined(const char* uid, int elapsed) {}
	virtual void onUserOffline(const char* uid, USER_OFFLINE_REASON_TYPE reason) {}
	virtual void onNetworkQuality(const char* uid, NetworkQuality txQuality, NetworkQuality rxQuality) {}
	virtual void onFirstLocalVideoFrameSent(int elapsed);
	virtual void onFirstLocalAudioFrameSent(int elapsed) {}
	virtual void onConnectionStatus(ThunderConnectionStatus status);
	virtual void onConnectionLost() {}
	virtual void onNetworkTypeChanged(ThunderNetworkType type) {}
	virtual void onPublishStreamToCDNStatus(const char* url, ThunderPublishCDNErrorCode errorCode) {}
	virtual void onRoomStats(RoomStats stats) {}
	virtual void onAudioCaptureStatus(ThunderAudioDeviceStatus type) {}
	virtual void OnAudioDeviceStateChange(const char* deviceId, int deviceType, int deviceState);
	virtual void onRecvUserAppMsgData(const char* uid, const char* msgData) {}
	virtual void onSendAppMsgDataFailedStatus(int status) {}
	virtual void onVideoCaptureStatus(int status);
	virtual void onLocalVideoStats(const LocalVideoStats stats) {}
	virtual void onLocalAudioStats(const LocalAudioStats stats) {}
	virtual void onRemoteVideoStatsOfUid(const char* uid, const RemoteVideoStats stats) {}
	virtual void onRemoteAudioStatsOfUid(const char* uid, const RemoteAudioStats stats) {}

	ThunderManager* getThunderManager();

signals:
	void onJoinRoomSuccessJ(const QString& roomName, const QString& uid, int elapsed);
	void onLeaveRoomJ();
	void onRemoteAudioStoppedJ(const QString& uid, bool stop);
	void onRemoteVideoStoppedJ(const QString& uid, bool stop);
	void onConnectionStatusJ(ThunderConnectionStatus status);
	void onTokenWillExpireJ(const QString& token);
	void onVideoCaptureStatusJ(int status);
	void onFirstLocalVideoFrameSentJ(int elapsed);  // µÚÒ»Ö¡·¢ËÍ
	void onRemoteVideoPlayJ(const QString& uid, int width, int height, int elapsed);
	void onVideoSizeChangedJ(const QString& uid, int width, int height, int rotation);

private:
	MediaManager();

private:
	ThunderManager*	_pThunderManager;
	static MediaManager* _pInstance;
};

 