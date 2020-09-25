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
	void linkAnchorSuccess();  // �Լ���������
	void pkAnchorSuccess(int64_t uid); // �Լ�pk ����
	void breakAnchor();  // �Ͽ� PK
	void userJoin();
	void userLeave(const QString& uid);
	void setUserRole();  // �Ƿ��ǹ���Ա
	void videoStreamStart();  // ���������ť��Ҫ֪ͨ��

	void otherLinkAnchor();  // ����������� PK���Լ�ֻ�ǹ���
	void changeLanguage();

signals:
	void onLinkAnchor();
	void onPKRequest(int64_t uid, int64_t roomId);
	void onBreakLink(int64_t uid, int64_t roomId);  // ֻ�������ܹ��Ͽ�����
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
	
	// ��Ϊ���� combox addItems �󣬻��лص����ף������ʱ����ʹ�ô˻ص�
	bool _bResetCameraComboxOK;
	bool _bResetMicphoneComboxOK;
	bool _bResetPushComboxOK;
	int _iPublishModeComboBoxCurrent;
	LinkBtnType _eLinkBtnType;
};
