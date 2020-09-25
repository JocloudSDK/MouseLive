#pragma once

#include <QObject>
#include <QWidget>
#include <memory>
#include "../../sdk/thunderbolt/MediaManager.h"

class ThunderVideoCapture;
class ThunderMeetUI : public QObject {
	Q_OBJECT
public:
	ThunderMeetUI();
	~ThunderMeetUI();

	void resetUI();

	// breakLink 和 unsubcribe 需要统一

	void setLeftAndRightView(QWidget* left, QWidget* right);
	void subcribe(int64_t uid, int64_t roomId);
	void unsubcribe(int64_t uid, int64_t roomId);
	int joinRoom(int64_t uid, int64_t roomId, std::string token);
	void leaveRoom();
	void beginLiving();
	void setCurrentPublishMode(VideoPublishMode m) { _eMode = m; }

signals:
	void onShowOneCanvas();  // 显示1画面，只有自己是房主才回调
	void onShowTwoCanvas(); // 显示2画面，只有自己是房主才回调

private:
	void setLeftView(int64_t uid, int width, int height, HWND hwnd= nullptr); // isWGH 是否宽大于高
	void setRightView(int64_t uid, int width, int height, bool link, HWND hwnd = nullptr); // isWGH 是否宽大于高
	void breakSelf(int64_t uid);
	void linkSelf(int64_t uid);
	void initEvent();
	void restartVideoDevice();
	void restartMicphoneDevice();
	void resetVideoConfig();
	void showCanvas(bool one);

public slots :
	void onJoinRoomSuccessJ(const QString& roomName, const QString& uid, int elapsed);
	void onLeaveRoomJ();
	void onRemoteAudioStoppedJ(const QString& uid, bool stop);
	void onRemoteVideoStoppedJ(const QString& uid, bool stop);
	void onConnectionStatusJ(ThunderConnectionStatus status);
	void onTokenWillExpireJ(const QString& token);
	void onVideoCaptureStatusJ(int status);
	void onFirstLocalVideoFrameSentJ(int elapsed);
	void onRemoteVideoPlayJ(const QString& uid, int width, int height, int elapsed);
	void onVideoSizeChangedJ(const QString& uid, int width, int height, int rotation);

protected:
	class Canvas {
	public:
		QWidget* _pCanvas = nullptr;
		int64_t _iUid = 0;
		int _iWidth = 0;
		int _iHeight = 0;
		bool _bLinking = false;
		HWND _iHwnd = 0;

		void hide() {
			if (_pCanvas) {
				_pCanvas->hide();
			}
		}
		
		void show() {
			if (_pCanvas) {
				_pCanvas->show();
			}
		}
	};

private:
	Canvas _oLeft;
	Canvas _oRight;

	int64_t _iSubcribeUid = 0;
	int64_t _iSubcribeRoomId = 0;

	VideoPublishMode _eMode = VIDEO_PUBLISH_MODE_NORMAL_DEFINITION;

	std::shared_ptr<ThunderVideoCapture> _pThunderVideoCapture;
};
