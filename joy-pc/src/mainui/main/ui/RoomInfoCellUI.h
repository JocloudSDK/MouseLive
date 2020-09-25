#pragma once

#include <QtWidgets/QWidget>
#include <QMouseEvent>
#include "ui_RoomInfoCellUI.h"
#include "../../RoomInfo.h"
#include "../../LogicModel.h"

class RoomInfoCellUI : public QWidget {
	Q_OBJECT

public:
	RoomInfoCellUI(QWidget *parent = Q_NULLPTR);
	~RoomInfoCellUI();

	void setRoomInfo(const GetRoomListResponse::RoomInfoResponse& resp);

protected:
	void mousePressEvent(QMouseEvent *event);
	void mouseReleaseEvent(QMouseEvent *event);

signals:
	void onSelectRoom(const GetRoomListResponse::RoomInfoResponse& roomInfo);

public slots:
	void onClickItem(bool);

private:
	Ui::RoomInfoCellClass _oUI;
	GetRoomListResponse::RoomInfoResponse _oRoomInfo;

	bool bClicked = false;
};
