#include "ShoushiUI.h"
#include "../../../../common/utils/String.h"
#include "../../../../common/qss/QssLoad.h"
#include "../../../sdk/beauty/BeautyManager.h"
#include "../../../sdk/beauty/pathutils.h"

static QString g_strBtnPath[12] = {
	"beauty_original",
	"gesture_666",
	"gesture_baoquan",
	"gesture_heshi",
	"gesture_ok",
	"gesture_onehandheart",
	"gesture_palm",
	"gesture_thumbsup",
	"gesture_tuojv",
	"gesture_twohandheart",
	"gesture_yeah",
	"gesture_zhizhu",
};

ShoushiUI::ShoushiUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//ÎÞ±ß¿ò   
	setAttribute(Qt::WA_TranslucentBackground);//±³¾°Í¸Ã÷

	initArray();

	initUI();
	initEvent();
}

ShoushiUI::~ShoushiUI() {
}

void ShoushiUI::initArray() {
	_pBtnArray[0] = _oUI.shouYuanhuaBtn;
	_pBtnArray[1] = _oUI.shou1Btn;
	_pBtnArray[2] = _oUI.shou2Btn;
	_pBtnArray[3] = _oUI.shou3Btn;
	_pBtnArray[4] = _oUI.shou4Btn;
	_pBtnArray[5] = _oUI.shou5Btn;
	_pBtnArray[6] = _oUI.shou6Btn;
	_pBtnArray[7] = _oUI.shou7Btn;
	_pBtnArray[8] = _oUI.shou8Btn;
	_pBtnArray[9] = _oUI.shou9Btn;
	_pBtnArray[10] = _oUI.shou10Btn;
	_pBtnArray[11] = _oUI.shou11Btn;
}

void ShoushiUI::resetUI() {
	_pBtnArray[0] = _oUI.shouYuanhuaBtn;
	_pBtnArray[0]->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);border:1px groove;border-color: #0041FF;border-radius: 2px;}QPushButton:pressed{border: 1px dotted black;}").arg(g_strBtnPath[0]));

	BeautyManager::GetInstance()->clearAllGesture();
}

void ShoushiUI::changeLanguage() {
	_oUI.retranslateUi(this);
}

void ShoushiUI::switchToBtn(QPushButton* to, const QString& toPath) {
	_pBtnArray[0]->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);}QPushButton:pressed{border: 1px dotted black;}").arg(g_strBtnPath[0]));
	to->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);border:1px groove;border-color: #0041FF;border-radius: 2px;}QPushButton:pressed{border: 1px dotted black;}").arg(toPath));
}

void ShoushiUI::initEvent() {
	connect(_oUI.shou1Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi1Btn(bool)));
	connect(_oUI.shou2Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi2Btn(bool)));
	connect(_oUI.shou3Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi3Btn(bool)));
	connect(_oUI.shou4Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi4Btn(bool)));
	connect(_oUI.shou5Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi5Btn(bool)));
	connect(_oUI.shou6Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi6Btn(bool)));
	connect(_oUI.shou7Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi7Btn(bool)));
	connect(_oUI.shou8Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi8Btn(bool)));
	connect(_oUI.shou9Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi9Btn(bool)));
	connect(_oUI.shou10Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi10Btn(bool)));
	connect(_oUI.shou11Btn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushi11Btn(bool)));
	connect(_oUI.shouYuanhuaBtn, SIGNAL(clicked(bool)), this, SLOT(onClicShoushiyuanhuaBtn(bool)));
}

void ShoushiUI::initUI() {

}

void ShoushiUI::onClickShoushi1Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_666.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou1Btn, g_strBtnPath[1]);
}

void ShoushiUI::onClickShoushi2Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_baoquan.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou2Btn, g_strBtnPath[2]);
}

void ShoushiUI::onClickShoushi3Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_heshi.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou3Btn, g_strBtnPath[3]);
}

void ShoushiUI::onClickShoushi4Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_ok.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou4Btn, g_strBtnPath[4]);
}

void ShoushiUI::onClickShoushi5Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_onehandheart.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou5Btn, g_strBtnPath[5]);
}

void ShoushiUI::onClickShoushi6Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_palm.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou6Btn, g_strBtnPath[6]);
}

void ShoushiUI::onClickShoushi7Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_thumbsup.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou7Btn, g_strBtnPath[7]);
}

void ShoushiUI::onClickShoushi8Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_tuojv.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou8Btn, g_strBtnPath[8]);
}

void ShoushiUI::onClickShoushi9Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_twohandheart.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou9Btn, g_strBtnPath[9]);
}

void ShoushiUI::onClickShoushi10Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_yeah.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou10Btn, g_strBtnPath[10]);
}

void ShoushiUI::onClickShoushi11Btn(bool) {
	std::string str = CurrentApplicationDirA().c_str();
	str += "effects\\gesture_zhizhu.zip";
	BeautyManager::GetInstance()->enableGesture(str, true);
	switchToBtn(_oUI.shou11Btn, g_strBtnPath[11]);
}

void ShoushiUI::onClicShoushiyuanhuaBtn(bool) {
	BeautyManager::GetInstance()->clearAllGesture();

	for (int i = 1; i < 12; i++) {
		_pBtnArray[i]->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);}QPushButton:pressed{border: 1px dotted black;}").arg(g_strBtnPath[i]));
	}
	_pBtnArray[0]->setStyleSheet(QString("QPushButton{background-image: url(:/beauty/%1);border:1px groove;border-color: #0041FF;}QPushButton:pressed{border: 1px dotted black;}").arg(g_strBtnPath[0]));
}
