#include "BeautyCellUI.h"
#include "../../../../common/utils/String.h"
#include "../../../../common/qss/QssLoad.h"
#include "../../../sdk/beauty/BeautyManager.h"

BeautyCellUI::BeautyCellUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//ÎÞ±ß¿ò   
	setAttribute(Qt::WA_TranslucentBackground);//±³¾°Í¸Ã÷

	initEvent();
}

BeautyCellUI::~BeautyCellUI() {
}

void BeautyCellUI::setRang(int minValue, int maxValue, int currentValue) {
	setCurrentValue(currentValue);
	_oUI.numberSlider->setMinimum(minValue);
	_oUI.numberSlider->setMaximum(maxValue);
	_oUI.numberSlider->setValue(_iCurrentValue);
}

void BeautyCellUI::setCurrentValue(int value) {
	_iCurrentValue = value;
	_oUI.numberSlider->setValue(_iCurrentValue);
	_oUI.numberLabel->setText(QString::number(_iCurrentValue));
}

void BeautyCellUI::setEnable(bool b) {
	_oUI.numberSlider->setEnabled(b);
}

void BeautyCellUI::initEvent() {
	connect(_oUI.numberSlider, SIGNAL(valueChanged(int)), this, SLOT(onValueChange(int)));
	connect(_oUI.numberSlider, SIGNAL(sliderReleased()), this, SLOT(onSliderReleased()));
}

void BeautyCellUI::onValueChange(int value) {
	setCurrentValue(value);
	emit onValueChanged(_iTag, _iCurrentValue);
}

void BeautyCellUI::onSliderReleased() {
	//emit onValueChanged(_iTag, _iCurrentValue);
}
