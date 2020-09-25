#pragma once

#include <QtWidgets/QWidget>
#include "ui_ShoushiUI.h"

class ShoushiUI : public QWidget {
	Q_OBJECT

public:
	ShoushiUI(QWidget *parent = Q_NULLPTR);
	~ShoushiUI();

	void resetUI();
	void changeLanguage();

protected:
	void initEvent();
	void initUI();
	void switchToBtn(QPushButton* to, const QString& toPath);
	void initArray();

public slots :
	void onClickShoushi1Btn(bool);
	void onClickShoushi2Btn(bool);
	void onClickShoushi3Btn(bool);
	void onClickShoushi4Btn(bool);
	void onClickShoushi5Btn(bool);
	void onClickShoushi6Btn(bool);
	void onClickShoushi7Btn(bool);
	void onClickShoushi8Btn(bool);
	void onClickShoushi9Btn(bool);
	void onClickShoushi10Btn(bool);
	void onClickShoushi11Btn(bool);
	void onClicShoushiyuanhuaBtn(bool);

private:
	Ui::ShoushiUIClass _oUI;
	QPushButton* _pBtnArray[12];
};