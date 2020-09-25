#pragma once

#include <QtWidgets/QWidget>
#include "ui_TiezhiUI.h"

class TiezhiUI : public QWidget {
	Q_OBJECT

public:
	TiezhiUI(QWidget *parent = Q_NULLPTR);
	~TiezhiUI();

	void resetUI();
	void changeLanguage();

protected:
	void initEvent();
	void initUI();
	void switchToBtn(QPushButton* to, const QString& toPath);

public slots :
	void onClickTiezhi1Btn(bool);
	void onClickTiezhi2Btn(bool);
	void onClickTiezhi3Btn(bool);
	void onClickTiezhi4Btn(bool);
	void onClickTiezhi5Btn(bool);
	void onClickTiezhi6Btn(bool);
	void onClickTiezhi7Btn(bool);
	void onClicTiezhiyuanhuaBtn(bool);

private:
	Ui::TiezhiUIClass _oUI;

	QPushButton* _pCurrentBtn;
	QString _strCurrentBtnPath;
};