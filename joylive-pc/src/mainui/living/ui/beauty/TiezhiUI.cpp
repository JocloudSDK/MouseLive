#include "TiezhiUI.h"
#include "../../../../common/utils/String.h"
#include "../../../../common/qss/QssLoad.h"
#include "../../../sdk/beauty/BeautyManager.h"
#include "../../../sdk/beauty/pathutils.h"

static QString g_strBtnPath[8] = {
	"beauty_original",
	"sticker_aral",
	"sticker_black_cat_ears",
	"sticker_bud_glasses",
	"sticker_devil_gauze_mask",
	"sticker_seeking_attention",
	"sticker_sunglasses",
	"sticker_YYbear",
};

TiezhiUI::TiezhiUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//无边框   
	setAttribute(Qt::WA_TranslucentBackground);//背景透明

	initUI();
	initEvent();
}

TiezhiUI::~TiezhiUI() {

}

void TiezhiUI::resetUI() {
	// 显示原画
	BeautyManager::GetInstance()->releaseCurrentSticker();
	_pCurrentBtn = _oUI.tieYuanhuaBtn;
	_strCurrentBtnPath = g_strBtnPath[0];
	_pCurrentBtn->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);border:1px groove;border-color: #0041FF;border-radius: 2px;}QPushButton:pressed{border: 1px dotted black;}").arg(_strCurrentBtnPath));
}

void TiezhiUI::changeLanguage() {
	_oUI.retranslateUi(this);
}

void TiezhiUI::switchToBtn(QPushButton* to, const QString& toPath) {
	// 清理前一个
	_pCurrentBtn->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);}QPushButton:pressed{border: 1px dotted black;}").arg(_strCurrentBtnPath));
	
	// 设置下一个
	_pCurrentBtn = to;
	_strCurrentBtnPath = toPath;
	_pCurrentBtn->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);border:1px groove;border-color: #0041FF;border-radius: 2px;}QPushButton:pressed{border: 1px dotted black;}").arg(_strCurrentBtnPath));
}

void TiezhiUI::initEvent() {
	connect(_oUI.tie1Btn, SIGNAL(clicked(bool)), this, SLOT(onClickTiezhi1Btn(bool)));
	connect(_oUI.tie2Btn, SIGNAL(clicked(bool)), this, SLOT(onClickTiezhi2Btn(bool)));
	connect(_oUI.tie3Btn, SIGNAL(clicked(bool)), this, SLOT(onClickTiezhi3Btn(bool)));
	connect(_oUI.tie4Btn, SIGNAL(clicked(bool)), this, SLOT(onClickTiezhi4Btn(bool)));
	connect(_oUI.tie5Btn, SIGNAL(clicked(bool)), this, SLOT(onClickTiezhi5Btn(bool)));
	connect(_oUI.tie6Btn, SIGNAL(clicked(bool)), this, SLOT(onClickTiezhi6Btn(bool)));
	connect(_oUI.tie7Btn, SIGNAL(clicked(bool)), this, SLOT(onClickTiezhi7Btn(bool)));
	connect(_oUI.tieYuanhuaBtn, SIGNAL(clicked(bool)), this, SLOT(onClicTiezhiyuanhuaBtn(bool)));
}

void TiezhiUI::initUI() {
	
}

void TiezhiUI::onClickTiezhi1Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\sticker_aral.zip";
	BeautyManager::GetInstance()->enableSticker(str, true);
	switchToBtn(_oUI.tie1Btn, g_strBtnPath[1]);
}

void TiezhiUI::onClickTiezhi2Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\sticker_black_cat_ears.zip";
	BeautyManager::GetInstance()->enableSticker(str, true);
	switchToBtn(_oUI.tie2Btn, g_strBtnPath[2]);
}

void TiezhiUI::onClickTiezhi3Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\sticker_bud_glasses.zip";
	BeautyManager::GetInstance()->enableSticker(str, true);
	switchToBtn(_oUI.tie3Btn, g_strBtnPath[3]);
}

void TiezhiUI::onClickTiezhi4Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\sticker_devil_gauze_mask.zip";
	BeautyManager::GetInstance()->enableSticker(str, true);
	switchToBtn(_oUI.tie4Btn, g_strBtnPath[4]);
}

void TiezhiUI::onClickTiezhi5Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\sticker_seeking_attention.zip";
	BeautyManager::GetInstance()->enableSticker(str, true);
	switchToBtn(_oUI.tie5Btn, g_strBtnPath[5]);
}

void TiezhiUI::onClickTiezhi6Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\sticker_sunglasses.zip";
	BeautyManager::GetInstance()->enableSticker(str, true);
	switchToBtn(_oUI.tie6Btn, g_strBtnPath[6]);
}

void TiezhiUI::onClickTiezhi7Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\sticker_YYbear.zip";
	BeautyManager::GetInstance()->enableSticker(str, true);
	switchToBtn(_oUI.tie7Btn, g_strBtnPath[7]);
}

void TiezhiUI::onClicTiezhiyuanhuaBtn(bool) {
	BeautyManager::GetInstance()->releaseCurrentSticker();
	switchToBtn(_oUI.tieYuanhuaBtn, g_strBtnPath[0]);
}
