#pragma once

#include <QtWidgets/QMainWindow>
#include "ui_MainUI.h"
#include "../../../common/translate/Translate.h"
#include "../../LogicModel.h"
#include <QMouseEvent>

#include "RoomInfoCellUI.h"
#include "../../Constans.h"
#include "../../living/ui/LivingDialogUI.h"
#include "../../baseui/MessageBoxNormalUI.h"
#include "../../sdk/chatroom/ChatRoomManager.h"

#include <QCloseEvent>

class MainHttpLogic;
class MainUI : public QMainWindow, public MessageBoxNormalUIObserver
{
    Q_OBJECT

	enum class BtnClickType {
		CLOSE,
		SELECT_ROOM,
	};

	enum class MsgBoxType {

	};

public:
	MainUI(QWidget *parent = Q_NULLPTR);
	virtual ~MainUI();

private:
	// init
	void initLanguage();
	void initLanguageBtn();
	void initEvent();
	void initWindow();
	void initHttp();
	void initLivingUI();
	void initChatRoom();

	void beginLiving();

	void resetAppNumber();
	int getBuildNumber();
	void initLog();
	void uinitLog();
	void createLogDir(const std::string& path);
	void reflush();

	void reflushRoomList(const GetRoomListResponse& resp);

	void retranslateUI();

	void sendLoginRequest();
	void sendGetRoomListRequest();

protected:
	void mousePressEvent(QMouseEvent *event);
	void mouseMoveEvent(QMouseEvent *event);
	void mouseReleaseEvent(QMouseEvent *event);

	void closeEvent(QCloseEvent *event);
	void closeApp();

	virtual void onClickMsgOKBtn(MessageBoxNormalUIShowType t);
	virtual void onClickMsgCancelBtn(MessageBoxNormalUIShowType t);

private slots:
	void onClickMinBtn();
	void onClickCloseBtn();
	void onClickLiveBtn(bool);
	void onClickLiveRoomListBtn(bool);
	void onClickLanguageBtn(bool);

	void onLoginSuccess(const QString& body);
	void onLoginFailed();
	void onGetRoomListSuccess(const QString& body);
	void onGetRoomListFailed();
	void onGetRoomInfoSuccess(const QString& body);
	void onGetRoomInfoFailed();

	void onSelectRoom(const GetRoomListResponse::RoomInfoResponse& roomInfo);
	void onLivingUILeaveRoom();

	void onLoginChatRoomSuccess();
	void onLoginChatRoomFailed();

private:
    Ui::MainUIClass _oUI;
	std::shared_ptr<MainHttpLogic> _pMainHttpLogic;
	std::shared_ptr<LivingDialogUI> _pLivingDialogUI;

	RoomType _eRoomType = RoomType::LIVE;
	BtnClickType _eBtnClickType;

	bool _bDragFlag = false; // check the mouse down
	QPoint _oDragPosition;

	int64_t _iSelectRoomId = 0;
	bool _bClose = false;
};
