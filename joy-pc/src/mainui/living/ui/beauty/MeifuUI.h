#pragma once

#include <QtWidgets/QWidget>
#include "ui_MeifuUI.h"
#include "BeautyCellUI.h"
#include <memory>

class MeifuUI : public QWidget {
	Q_OBJECT

public:
	MeifuUI(QWidget *parent = Q_NULLPTR);
	~MeifuUI();

	void resetUI();
	void changeLanguage();

protected:
	void initEvent();
	void initUI();

public slots :
	void onValueChanged(int tag, int value);

private:
	Ui::MeifuUIClass _oUI;
	std::shared_ptr<BeautyCellUI> _pMopiCellUI;
	std::shared_ptr<BeautyCellUI> _pMeibaiCellUI;
};