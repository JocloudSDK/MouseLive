#include "WuguanUI.h"
#include "../../../../common/utils/String.h"
#include "../../../../common/qss/QssLoad.h"
#include "../../../../common/utils/String.h"
#include "../../../sdk/beauty/BeautyManager.h"

WuguanUI::WuguanUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//无边框   
	setAttribute(Qt::WA_TranslucentBackground);//背景透明

	initUI();
	initEvent();
}

WuguanUI::~WuguanUI() {
}

void WuguanUI::resetUI() {
	switchJichuzhengxing(true);
	switchGaojizhengxing(false);

	resetJichuzhengxing();
	resetGaojizhengxing();

	resetResetUI();
}

void WuguanUI::changeLanguage() {
	_oUI.retranslateUi(this);

	int i = OrangeHelper::EP_SeniorTypeThinFaceIntensity;
	for (auto c = _oGaojiCellUIVector.begin(); c != _oGaojiCellUIVector.end(); c++) {
		QString str = getString(i);
		i++;
		(*c)->setLabel(str);
	}

	_oUI.jichuzhengxingNumberLabel->setText(QString::number(_iJichuzhengxingCurrentValue));

	resetResetUI();
}

void WuguanUI::initEvent() {
	connect(_oUI.jichuzhengxingCheckBox, SIGNAL(stateChanged(int)), this, SLOT(onJichuStateChanged(int)));
	connect(_oUI.gaojizhengxingCheckBox, SIGNAL(stateChanged(int)), this, SLOT(onGaojiStateChanged(int)));

	connect(_oUI.jichuzhengxingSlider, SIGNAL(valueChanged(int)), this, SLOT(onJichuzhengxingValueChange(int)));
	connect(_oUI.jichuzhengxingSlider, SIGNAL(sliderReleased()), this, SLOT(onJichuzhengxingSliderReleased()));

	connect(_oUI.jichuzhengxingResetBtn, SIGNAL(clicked(bool)), this, SLOT(onClickJichuzhengxingResetBtn(bool)));
	connect(_oUI.gaojizhengxingResetBtn, SIGNAL(clicked(bool)), this, SLOT(onClickGaojizhengxingResetBtn(bool)));
}

void WuguanUI::initUI() {
	int y = 0;
	for (int i = OrangeHelper::EP_SeniorTypeThinFaceIntensity;
		i <= OrangeHelper::EP_SeniorTypeChinLiftingIntensity; i++) {
		QString str = getString(i);
		std::shared_ptr<BeautyCellUI> cell;
		cell.reset(new BeautyCellUI(_oUI.gaojizhengxingWidget));
		cell->setLabel(str);
		if (i >= OrangeHelper::EP_SeniorTypeForeheadLiftingIntensity) {
			cell->setRang(-50, 50, 0);
		}
		cell->setObjectName(QStringLiteral("GaojiCell") + QString::number(i - OrangeHelper::EP_SeniorTypeThinFaceIntensity));
		cell->setGeometry(QRect(0, y, 220, 35));
		cell->setTag(i);
		connect(cell.get(), SIGNAL(onValueChanged(int, int)), this, SLOT(onValueChanged(int, int)));
		_oGaojiCellUIVector.emplace_back(cell);
		y += 37;
	}
}

QString WuguanUI::getString(int t) {
	OrangeHelper::EffectParamType e = (OrangeHelper::EffectParamType)t;
	switch (e) {
	case OrangeHelper::EP_SeniorTypeThinFaceIntensity:
		return QApplication::translate("WuguanUI", "ThinFaceIntensity", 0); // 窄脸 0 - 100
	case OrangeHelper::EP_SeniorTypeSmallFaceIntensity:
		return QApplication::translate("WuguanUI", "SmallFaceIntensity", 0); // 小脸 0 - 100
	case OrangeHelper::EP_SeniorTypeSquashedFaceIntensity:
		return QApplication::translate("WuguanUI", "SquashedFaceIntensity", 0); // 瘦颧骨 0 - 100
	case OrangeHelper::EP_SeniorTypeForeheadLiftingIntensity:
		return QApplication::translate("WuguanUI", "ForeheadLiftingIntensity", 0); // 额高 -50 - 50
	case OrangeHelper::EP_SeniorTypeWideForeheadIntensity:
		return QApplication::translate("WuguanUI", "WideForeheadIntensity", 0); // 额宽
	case OrangeHelper::EP_SeniorTypeBigSmallEyeIntensity:
		return QApplication::translate("WuguanUI", "BigSmallEyeIntensity", 0); // 大眼
	case OrangeHelper::EP_SeniorTypeEyesOffsetIntensity:
		return QApplication::translate("WuguanUI", "EyesOffsetIntensity", 0); // 眼距
	case OrangeHelper::EP_SeniorTypeEyesRotationIntensity:
		return QApplication::translate("WuguanUI", "EyesRotationIntensity", 0); // 眼角
	case OrangeHelper::EP_SeniorTypeThinNoseIntensity:
		return QApplication::translate("WuguanUI", "ThinNoseIntensity", 0); // 瘦鼻
	case OrangeHelper::EP_SeniorTypeLongNoseIntensity:
		return QApplication::translate("WuguanUI", "LongNoseIntensity", 0); // 长鼻
	case OrangeHelper::EP_SeniorTypeThinNoseBridgeIntensity:
		return QApplication::translate("WuguanUI", "ThinNoseBridgeIntensity", 0); // 窄鼻梁
	case OrangeHelper::EP_SeniorTypeThinmouthIntensity:
		return QApplication::translate("WuguanUI", "ThinmouthIntensity", 0); // 瘦嘴
	case OrangeHelper::EP_SeniorTypeMovemouthIntensity:
		return QApplication::translate("WuguanUI", "MovemouthIntensity", 0); // 嘴位
	case OrangeHelper::EP_SeniorTypeChinLiftingIntensity:
		return QApplication::translate("WuguanUI", "ChinLiftingIntensity", 0); // 下巴
	default:
		break;
	}
	return QApplication::translate("WuguanUI", "ThinFaceIntensity", 0); // 窄脸
}

void WuguanUI::resetJichuzhengxing() {
	// 默认是40
	BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_BasicTypeIntensity, 40);
	_oUI.jichuzhengxingNumberLabel->setText(QString::number(40));
	_oUI.jichuzhengxingSlider->setValue(40);
}

void WuguanUI::resetGaojizhengxing() {
	for (auto c = _oGaojiCellUIVector.begin(); c != _oGaojiCellUIVector.end(); c++) {
		(*c)->setCurrentValue(0);
		BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EffectParamType((*c)->getTag()), 0);
	}

	_oGaojiCellUIVector[OrangeHelper::EP_SeniorTypeSmallFaceIntensity - OrangeHelper::EP_SeniorTypeThinFaceIntensity]->setCurrentValue(40); // 小脸
	_oGaojiCellUIVector[OrangeHelper::EP_SeniorTypeBigSmallEyeIntensity - OrangeHelper::EP_SeniorTypeThinFaceIntensity]->setCurrentValue(20); // 大眼
	_oGaojiCellUIVector[OrangeHelper::EP_SeniorTypeThinNoseIntensity - OrangeHelper::EP_SeniorTypeThinFaceIntensity]->setCurrentValue(-3); // 瘦鼻
	BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_SeniorTypeSmallFaceIntensity, 40);
	BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_SeniorTypeBigSmallEyeIntensity, 20);
	BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_SeniorTypeThinNoseIntensity, -3);
}

void WuguanUI::resetResetUI() {
	int jichuzhengxingCheckBoxWidth = getStringWidth(_oUI.jichuzhengxingCheckBox->text(), *_oUI.jichuzhengxingCheckBox);
	jichuzhengxingCheckBoxWidth += 25;
	QRect jichuCheckBoxRect = _oUI.jichuzhengxingCheckBox->geometry();
	jichuCheckBoxRect.setWidth(jichuzhengxingCheckBoxWidth);
	_oUI.jichuzhengxingCheckBox->setGeometry(jichuCheckBoxRect);

	QRect jichuzhengxingResetRect = _oUI.jichuzhengxingResetBtn->geometry();
	int width = jichuzhengxingResetRect.width();
	jichuzhengxingResetRect.setX(jichuzhengxingCheckBoxWidth + 10);
	jichuzhengxingResetRect.setWidth(width);
	_oUI.jichuzhengxingResetBtn->setGeometry(jichuzhengxingResetRect);

	int gaojizhengxingCheckBoxWidth = getStringWidth(_oUI.gaojizhengxingCheckBox->text(), *_oUI.gaojizhengxingCheckBox);
	gaojizhengxingCheckBoxWidth += 25;
	QRect gaojiCheckBoxRect = _oUI.gaojizhengxingCheckBox->geometry();
	gaojiCheckBoxRect.setWidth(gaojizhengxingCheckBoxWidth);
	_oUI.gaojizhengxingCheckBox->setGeometry(gaojiCheckBoxRect);

	QRect gaojizhengxingResetRect = _oUI.gaojizhengxingResetBtn->geometry();
	width = gaojizhengxingResetRect.width();
	gaojizhengxingResetRect.setX(gaojizhengxingCheckBoxWidth + 10);
	gaojizhengxingResetRect.setWidth(width);
	_oUI.gaojizhengxingResetBtn->setGeometry(gaojizhengxingResetRect);
}

void WuguanUI::switchJichuzhengxing(bool enable) {
	BeautyManager::GetInstance()->enableEffect(OrangeHelper::ET_BasicBeautyType, enable);
	_oUI.jichuzhengxingSlider->setEnabled(enable);
	if (!enable) {
		_oUI.jichuzhengxingCheckBox->setCheckState(Qt::CheckState::Unchecked);
	}
	else {
		_oUI.jichuzhengxingCheckBox->setCheckState(Qt::CheckState::Checked);
	}
}

void WuguanUI::switchGaojizhengxing(bool enable) {
	BeautyManager::GetInstance()->enableEffect(OrangeHelper::ET_SeniorBeautyType, enable);
	_oUI.gaojizhengxingWidget->setEnabled(enable);
	if (!enable) {
		_oUI.gaojizhengxingCheckBox->setCheckState(Qt::CheckState::Unchecked);
	}
}

void WuguanUI::onJichuzhengxingValueChange(int value) {
	_iJichuzhengxingCurrentValue = value;
	_oUI.jichuzhengxingNumberLabel->setText(QString::number(_iJichuzhengxingCurrentValue));
	BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_BasicTypeIntensity, _iJichuzhengxingCurrentValue);
}

void WuguanUI::onJichuzhengxingSliderReleased() {
	// 操作整形
	//BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_BasicTypeIntensity, _iJichuzhengxingCurrentValue);
}

void WuguanUI::onValueChanged(int tag, int value) {
	BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EffectParamType(tag), value);
}

void WuguanUI::onJichuStateChanged(int s) {
	// 如果基础整形选择，就要去掉高级整形
	if (s == Qt::CheckState::Unchecked) {
		switchJichuzhengxing(false);
	}
	else {
		switchGaojizhengxing(false);
		switchJichuzhengxing(true);
	}
}

void WuguanUI::onGaojiStateChanged(int s) {
	// 如果高级整形选择，就要去掉基础整形
	if (s == Qt::CheckState::Unchecked) {
		switchGaojizhengxing(false);
	}
	else {
		switchJichuzhengxing(false);
		switchGaojizhengxing(true);
	}
}

void WuguanUI::onClickJichuzhengxingResetBtn(bool) {
	resetJichuzhengxing();
}

void WuguanUI::onClickGaojizhengxingResetBtn(bool) {
	resetGaojizhengxing();
}
