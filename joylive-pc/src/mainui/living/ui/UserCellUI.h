#pragma once

#include <QtWidgets/QWidget>
#include "ui_UserCellUI.h"
#include "../../RoomInfo.h"
#include "../../LogicModel.h"

class UserCellUI : public QWidget {
	Q_OBJECT

public:
	UserCellUI(QWidget *parent = Q_NULLPTR);
	~UserCellUI();

	void setData(const UserInfo& data);

public slots:
	void onClickItem(bool);

private:
	Ui::UserCellUIClass _oUI;
	UserInfo _oData;
};