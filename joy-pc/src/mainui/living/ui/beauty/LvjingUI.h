#pragma once

#include <QtWidgets/QWidget>
#include "ui_LvjingUI.h"
#include "BeautyCellUI.h"
#include <memory>
#include "../../../sdk/beauty/BeautyManager.h"

class LvjingUI : public QWidget {
	Q_OBJECT

public:
	LvjingUI(QWidget *parent = Q_NULLPTR);
	~LvjingUI();

	void resetUI();
	void changeLanguage();

protected:
	void initEvent();
	void initUI();
	void switchToBtn(QPushButton* to, const QString& toPath, int toType);

	public slots :
	void onClickLvjing1Btn(bool);
	void onClickLvjing2Btn(bool);
	void onClickLvjing3Btn(bool);
	void onClickLvjing4Btn(bool);
	void onClickLvjing5Btn(bool);
	void onClickLvjing6Btn(bool);
	void onClickLvjing7Btn(bool);
	void onClicLvjingyuanhuaBtn(bool);

	void onValueChanged(int tag, int value);

private:
	Ui::LvjingUIClass _oUI;

	std::shared_ptr<BeautyCellUI> _pLvjingSlider;

	OrangeHelper::EffectParamType _eCurrentLvjingParamType;
	OrangeHelper::EffectType _eCurrentLvjingType;
	int _eCurrentSliderValue = 0;
	QPushButton* _pCurrentBtn;
	QString _strCurrentBtnPath;
};