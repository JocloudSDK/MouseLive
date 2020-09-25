#pragma once

#include <QtWidgets/QWidget>
#include "ui_BeautyUI.h"
#include "../../RoomInfo.h"
#include "../../LogicModel.h"
#include "./beauty/MeifuUI.h"
#include "./beauty/ShoushiUI.h"
#include "./beauty/TiezhiUI.h"
#include "./beauty/WuguanUI.h"
#include "./beauty/LvjingUI.h"

class BeautyUI : public QWidget {
	Q_OBJECT

public:
	BeautyUI(QWidget *parent = Q_NULLPTR);
	~BeautyUI();
	
	void setEnable(bool isEnabel);

	void resetUI();
	void changeLanguage();

protected:
	void initEvent();
	void initOtherUI();

	void switchToBtn(QPushButton* to);

public slots:
	void onClickMeifuBtn(bool);
	void onClickShoushiBtn(bool);
	void onClickTiezhiBtn(bool);
	void onClickWuguanBtn(bool);
	void onClickLvjingBtn(bool);

private:
	Ui::BeautyUIClass _oUI;
	std::shared_ptr<MeifuUI> _pMeifuUI;
	std::shared_ptr<LvjingUI> _pLvjingUI;
	std::shared_ptr<ShoushiUI> _pShoushiUI;
	std::shared_ptr<TiezhiUI> _pTiezhiUI;
	std::shared_ptr<WuguanUI> _pWuguanUI;

	QPushButton* _pCurrentBtn;
};