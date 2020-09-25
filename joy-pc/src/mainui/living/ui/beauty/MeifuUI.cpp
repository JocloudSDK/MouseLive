#include "MeifuUI.h"
#include "../../../../common/utils/String.h"
#include "../../../../common/qss/QssLoad.h"
#include "../../../sdk/beauty/BeautyManager.h"
#include "../../../sdk/beauty/pathutils.h"

#define TAG_MOPI 1
#define TAG_MEIBAI 2

// 滤镜和贴图不能一起使用
MeifuUI::MeifuUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//无边框   
	setAttribute(Qt::WA_TranslucentBackground);//背景透明

	initUI();
	initEvent();
}

MeifuUI::~MeifuUI() {

}

void MeifuUI::resetUI() {
	// 默认 70
	BeautyManager::GetInstance()->enableEffect(OrangeHelper::ET_BasicBeauty, true);
	BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_BasicBeautyOpacity, 70);
	BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_BasicBeautyIntensity, 70);
	_pMopiCellUI->setCurrentValue(70);
	_pMeibaiCellUI->setCurrentValue(70);
}

void MeifuUI::changeLanguage() {
	_oUI.retranslateUi(this);

	_pMopiCellUI->setLabel(QApplication::translate("MeifuUI", "Mopi", 0));
	_pMeibaiCellUI->setLabel(QApplication::translate("MeifuUI", "Meibai", 0));
}

void MeifuUI::initEvent() {
	connect(_pMopiCellUI.get(), SIGNAL(onValueChanged(int, int)), this, SLOT(onValueChanged(int, int)));
	connect(_pMeibaiCellUI.get(), SIGNAL(onValueChanged(int, int)), this, SLOT(onValueChanged(int, int)));
}

void MeifuUI::initUI() {
	// BeautyCellUI
	// mopi 0,0,220,35, 磨皮
	_pMopiCellUI.reset(new BeautyCellUI(_oUI.meifuWidget));
	_pMopiCellUI->setObjectName(QStringLiteral("MopiCellUI"));
	_pMopiCellUI->setGeometry(QRect(0, 0, 220, 35));
	_pMopiCellUI->setTag(TAG_MOPI);
	_pMopiCellUI->setLabel(QApplication::translate("MeifuUI", "Mopi", 0));

	// meibai,0,57,220,35,美白
	_pMeibaiCellUI.reset(new BeautyCellUI(_oUI.meifuWidget));
	_pMeibaiCellUI->setObjectName(QStringLiteral("MeibaiCellUI"));
	_pMeibaiCellUI->setGeometry(QRect(0, 57, 220, 35));
	_pMeibaiCellUI->setTag(TAG_MEIBAI);
	_pMeibaiCellUI->setLabel(QApplication::translate("MeifuUI", "Meibai", 0));
}

void MeifuUI::onValueChanged(int tag, int value) {
	if (tag == TAG_MOPI) {
		BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_BasicBeautyOpacity, value);
	}
	else if (tag == TAG_MEIBAI) {
		BeautyManager::GetInstance()->setEffectParam(OrangeHelper::EP_BasicBeautyIntensity, value);
	}
}
