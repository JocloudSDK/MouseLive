#pragma once

#include <QtWidgets/QWidget>
#include "ui_ClientEquipmentUI.h"
#include "../../RoomInfo.h"
#include "../../LogicModel.h"
#include "../../sdk/thunderbolt/MediaManager.h"

class LivingHttpLogic;
class AnchorCellUI;
class ClientEquipmentUI : public QWidget {
	Q_OBJECT

	enum class ListViewType {
		USER,
		ANCHOR
	};

public:
	ClientEquipmentUI(QWidget *parent = Q_NULLPTR);
	~ClientEquipmentUI();

	void setHttpLogic(std::shared_ptr<LivingHttpLogic> logic);
	void resetUI();
	void linkAnchorSuccess();  // 自己连麦主播
	void pkAnchorSuccess(int64_t uid); // 自己pk 主播
	void breakAnchor();  // 断开 PK
	void userJoin();
	void userLeave(const QString& uid);
	void setUserRole();  // 是否是管理员
	void videoStreamStart();  // 点击开播按钮需要通知下

	void otherLinkAnchor();  // 别人连麦或者 PK，自己只是观众
	void changeLanguage();

signals:
	void onLinkAnchor();
	void onPKRequest(int64_t uid, int64_t roomId);
	void onBreakLink(int64_t uid, int64_t roomId);  // 只有主播能够断开连麦
	void onSelectPublishMode(int m);

private:
	void initEvent();
	void resetCameraCombox();
	void resetMicphoneCombox();
	void resetPushModeCombox();
	void reflushUserList();
	void reset();
	void resetUserCount();
	void resetAnchorCount();

	enum LinkBtnType {
		BREAK,
		LINKING,
		PKING,
		SEND_LINK,
	};

	void switchLinkBtn(LinkBtnType t);

public slots:
	void onClickLinkBtn(bool);
	void onClickAnchorListBtn(bool);
	void onClickUserListBtn(bool);
	void onClickCameraBtn(bool);
	void onClickMicphoneBtn(bool);
	void onClickMirrorBtn(bool);
	void onClickBreakLinkBtn(bool);

	void onCameraSelect(const QString &);
	void onMicphoneSelect(const QString &);
	void onPushModeSelect(const QString &);

	void onGetAnchorListSuccess(const QString& body);
	void onGetAnchorListFailed();

	void onPKRequestJ(int64_t uid, int64_t roomId);

private:
	Ui::ClientEquipmentUIClass _oUI;
	GetRoomListResponse::RoomInfoResponse _oRoomInfo;
	VideoDeviceList _oVideoDevList;
	AudioDeviceList _oAudioDevList;
	std::shared_ptr<LivingHttpLogic> _pLivingHttpLogic;
	std::list<AnchorCellUI*> _oAnchorList;

	ListViewType _eListViewType;
	bool _bMute = false;
	bool _bVideoStreamStop = false;
	ThunderVideoMirrorMode _eThunderVideoMirrorMode;
	
	// 因为设置 combox addItems 后，会有回调上抛，但这个时候不能使用此回调
	bool _bResetCameraComboxOK;
	bool _bResetMicphoneComboxOK;
	bool _bResetPushComboxOK;
	int _iPublishModeComboBoxCurrent;
	LinkBtnType _eLinkBtnType;
};
