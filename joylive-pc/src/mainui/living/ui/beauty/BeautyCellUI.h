#pragma once

#include <QtWidgets/QWidget>
#include "ui_BeautyCellUI.h"
#include <QString>

class BeautyCellUI : public QWidget {
	Q_OBJECT

public:
	BeautyCellUI(QWidget *parent = Q_NULLPTR);
	~BeautyCellUI();

	void setTag(int tag) { _iTag = tag; }
	int getTag() { return _iTag; }

	void setLabel(const QString& text) { _oUI.label->setText(text); }

	// д╛хо 0,100,0
	void setRang(int minValue, int maxValue, int currentValue);
	void setCurrentValue(int value);

	void setEnable(bool b);

protected:
	void initEvent();

signals:
	void onValueChanged(int tag, int value);

public slots :
	void onValueChange(int value);
	void onSliderReleased();

private:
	Ui::BeautyCellUIClass _oUI;
	int _iTag = 0;
	int _iCurrentValue = 0;
};