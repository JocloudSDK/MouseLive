#pragma once

#include <QtWidgets/QWidget>
#include "ui_WuguanUI.h"
#include <memory>
#include "BeautyCellUI.h"

//10, 40, 220, 584
class WuguanUI : public QWidget {
	Q_OBJECT

public:
	WuguanUI(QWidget *parent = Q_NULLPTR);
	~WuguanUI();

	void resetUI();
	void changeLanguage();

protected:
	void initEvent();
	void initUI();
	QString getString(int t);

	void resetJichuzhengxing();
	void resetGaojizhengxing();
	void resetResetUI();

	void switchJichuzhengxing(bool enable);
	void switchGaojizhengxing(bool enable);

public slots :
	void onJichuzhengxingValueChange(int value);
	void onJichuzhengxingSliderReleased();

	void onValueChanged(int tag, int value);

	void onJichuStateChanged(int s);
	void onGaojiStateChanged(int s);

	void onClickJichuzhengxingResetBtn(bool);
	void onClickGaojizhengxingResetBtn(bool);

private:
	Ui::WuguanUIClass _oUI;
	std::vector<std::shared_ptr<BeautyCellUI>> _oGaojiCellUIVector;
	int _iJichuzhengxingCurrentValue = 0 ;
};