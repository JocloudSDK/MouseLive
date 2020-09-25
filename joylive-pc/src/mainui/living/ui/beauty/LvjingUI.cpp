#include "LvjingUI.h"
#include "../../../../common/utils/String.h"
#include "../../../../common/qss/QssLoad.h"
#include "../../../sdk/beauty/pathutils.h"
#include <QRect>

#define TAG_MOPI 1
#define TAG_MEIBAI 2

static QString g_strBtnPath[6] = {
	"beauty_original",
	"lj_qingxi_clear",
	"lj_qingxin_fresh",
	"lj_jiari_holiday",
	"lj_fennen_tender",
	"lj_nuanhe_warm",
};

// 滤镜和贴图不能一起使用
LvjingUI::LvjingUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//无边框   
	setAttribute(Qt::WA_TranslucentBackground);//背景透明

	initUI();
	initEvent();
}

LvjingUI::~LvjingUI() {

}

void LvjingUI::switchToBtn(QPushButton* to, const QString& toPath, int toType) {
	// 清理前一个
	_pCurrentBtn->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);}QPushButton:pressed{border: 1px dotted black;}").arg(_strCurrentBtnPath));

	// 设置下一个
	_pCurrentBtn = to;
	_strCurrentBtnPath = toPath;
	_pCurrentBtn->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);border:1px groove;border-color: #0041FF;border-radius: 2px;}QPushButton:pressed{border: 1px dotted black;}").arg(_strCurrentBtnPath));

	if (_eCurrentLvjingType != 0) {
		BeautyManager::GetInstance()->enableEffect(_eCurrentLvjingType, false);
	}

	if (toType != 0) {
		BeautyManager::GetInstance()->enableEffect((OrangeHelper::EffectType)toType, true);
		_pLvjingSlider->setEnable(true);
	}
	else {
		_pLvjingSlider->setEnable(false);
	}

	_eCurrentLvjingType = (OrangeHelper::EffectType)toType;
	int value = BeautyManager::GetInstance()->getEffectParam(_eCurrentLvjingParamType);
	_pLvjingSlider->setCurrentValue(value);
}

void LvjingUI::resetUI() {
	_pCurrentBtn = _oUI.lvjingYuanhuaBtn;
	_strCurrentBtnPath = g_strBtnPath[0];
	_eCurrentLvjingType = (OrangeHelper::EffectType)0;
	_pCurrentBtn->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);border:1px groove;border-color: #0041FF;border-radius: 2px;}QPushButton:pressed{border: 1px dotted black;}").arg(_strCurrentBtnPath));
	_pLvjingSlider->setEnable(false);

	BeautyManager::GetInstance()->enableEffect(OrangeHelper::ET_FilterHoliday, false);
	BeautyManager::GetInstance()->enableEffect(OrangeHelper::ET_FilterClear, false);
	BeautyManager::GetInstance()->enableEffect(OrangeHelper::ET_FilterWarm, false);
	BeautyManager::GetInstance()->enableEffect(OrangeHelper::ET_FilterFresh, false);
	BeautyManager::GetInstance()->enableEffect(OrangeHelper::ET_FilterTender, false);
}

void LvjingUI::changeLanguage() {
	_oUI.retranslateUi(this);
	QString str = QApplication::translate("LvjingUI", "Qiandu", 0);
	_pLvjingSlider->setLabel(str);
}

void LvjingUI::initEvent() {
	connect(_oUI.lvjing1Btn, SIGNAL(clicked(bool)), this, SLOT(onClickLvjing1Btn(bool)));
	connect(_oUI.lvjing2Btn, SIGNAL(clicked(bool)), this, SLOT(onClickLvjing2Btn(bool)));
	connect(_oUI.lvjing3Btn, SIGNAL(clicked(bool)), this, SLOT(onClickLvjing3Btn(bool)));
	connect(_oUI.lvjing4Btn, SIGNAL(clicked(bool)), this, SLOT(onClickLvjing4Btn(bool)));
	connect(_oUI.lvjing5Btn, SIGNAL(clicked(bool)), this, SLOT(onClickLvjing5Btn(bool)));
	connect(_oUI.lvjing6Btn, SIGNAL(clicked(bool)), this, SLOT(onClickLvjing6Btn(bool)));
	connect(_oUI.lvjing7Btn, SIGNAL(clicked(bool)), this, SLOT(onClickLvjing7Btn(bool)));
	connect(_oUI.lvjingYuanhuaBtn, SIGNAL(clicked(bool)), this, SLOT(onClicLvjingyuanhuaBtn(bool)));
}

void LvjingUI::initUI() {
	// BeautyCellUI
	QString str = QApplication::translate("LvjingUI", "Qiandu", 0);
	_pLvjingSlider.reset(new BeautyCellUI(this));
	_pLvjingSlider->setLabel(str);
	_pLvjingSlider->setObjectName("LvjingSlider");
	_pLvjingSlider->setGeometry(QRect(0, 10, 220, 35));
	connect(_pLvjingSlider.get(), SIGNAL(onValueChanged(int, int)), this, SLOT(onValueChanged(int, int)));
	_pLvjingSlider->setRang(0, 100, 0);
	_eCurrentLvjingParamType = OrangeHelper::EffectParamType(0);

	// 6,7 隐藏
	_oUI.lvjing6Btn->hide();
	_oUI.lvjing7Btn->hide();
}

void LvjingUI::onClickLvjing1Btn(bool) {
	//std::string str = CurrentApplicationDirA().c_str();
	//str += "effects\\filter_clear.zip";
	//BeautyManager::GetInstance()->enableSticker(str, true);

	_eCurrentLvjingParamType = OrangeHelper::EP_FilterClearIntensity;
	switchToBtn(_oUI.lvjing1Btn, g_strBtnPath[1], OrangeHelper::ET_FilterClear);
}

void LvjingUI::onClickLvjing2Btn(bool) {
	//std::string str = CurrentApplicationDirA().c_str();
	//str += "effects\\filter_fresh.zip";
	//BeautyManager::GetInstance()->enableSticker(str, true);

	_eCurrentLvjingParamType = OrangeHelper::EP_FilterFreshIntensity;
	switchToBtn(_oUI.lvjing2Btn, g_strBtnPath[2], OrangeHelper::ET_FilterFresh);
}

void LvjingUI::onClickLvjing3Btn(bool) {
	//std::string str = CurrentApplicationDirA().c_str();
	//str += "effects\\filter_holiday.zip";
	//BeautyManager::GetInstance()->enableSticker(str, true);

	_eCurrentLvjingParamType = OrangeHelper::EP_FilterHolidayIntensity;
	switchToBtn(_oUI.lvjing3Btn, g_strBtnPath[3], OrangeHelper::ET_FilterHoliday);
}

void LvjingUI::onClickLvjing4Btn(bool) {
	//std::string str = CurrentApplicationDirA().c_str();
	//str += "effects\\filter_tender.zip";
	//BeautyManager::GetInstance()->enableSticker(str, true);

	_eCurrentLvjingParamType = OrangeHelper::EP_FilterTenderIntensity;
	switchToBtn(_oUI.lvjing4Btn, g_strBtnPath[4], OrangeHelper::ET_FilterTender);
}

void LvjingUI::onClickLvjing5Btn(bool) {
	//std::string str = CurrentApplicationDirA().c_str();
	//str += "effects\\filter_warm.zip";
	//BeautyManager::GetInstance()->enableSticker(str, true);

	_eCurrentLvjingParamType = OrangeHelper::EP_FilterWarmIntensity;
	switchToBtn(_oUI.lvjing5Btn, g_strBtnPath[5], OrangeHelper::ET_FilterWarm);
}

void LvjingUI::onClickLvjing6Btn(bool) {

}

void LvjingUI::onClickLvjing7Btn(bool) {

}

void LvjingUI::onClicLvjingyuanhuaBtn(bool) {
	_eCurrentLvjingParamType = OrangeHelper::EffectParamType(0);
	switchToBtn(_oUI.lvjingYuanhuaBtn, g_strBtnPath[0], 0);
	_pLvjingSlider->setCurrentValue(0);
}

void LvjingUI::onValueChanged(int tag, int value) {
	if (_eCurrentLvjingParamType == 0) {
		return;
	}

	BeautyManager::GetInstance()->setEffectParam(_eCurrentLvjingParamType, value);
}
