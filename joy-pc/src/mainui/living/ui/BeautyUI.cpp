#include "BeautyUI.h"
#include "../../../common/utils/String.h"
#include "../../../common/qss/QssLoad.h"
#include "../../sdk/beauty/BeautyManager.h"

BeautyUI::BeautyUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//ÎÞ±ß¿ò   
	setAttribute(Qt::WA_TranslucentBackground);//±³¾°Í¸Ã÷

	initOtherUI();
	initEvent();

	//Utils::QssLoad::Load(this, "MessageUI.qss");

	//BeautyManager::GetInstance()->enableEffect(OrangeHelper::EffectType::ET_BasicBeauty, true);
}

BeautyUI::~BeautyUI() {

}

void BeautyUI::setEnable(bool isEnabel) {
	this->setEnabled(isEnabel);
}

void BeautyUI::resetUI() {
	_pMeifuUI->show();
	_pLvjingUI->hide();
	_pShoushiUI->hide();
	_pTiezhiUI->hide();
	_pWuguanUI->hide();

	_pLvjingUI->resetUI();
	_pShoushiUI->resetUI();
	_pTiezhiUI->resetUI();
	_pWuguanUI->resetUI();
	_pMeifuUI->resetUI();

	_pCurrentBtn = _oUI.meifuBtn;
	_pCurrentBtn->setStyleSheet(QStringLiteral("color: rgb(0, 65, 255);"));
}

void BeautyUI::changeLanguage() {
	_oUI.retranslateUi(this);
	_pLvjingUI->changeLanguage();
	_pShoushiUI->changeLanguage();
	_pTiezhiUI->changeLanguage();
	_pWuguanUI->changeLanguage();
	_pMeifuUI->changeLanguage();
}

void BeautyUI::initEvent() {
	connect(_oUI.meifuBtn, SIGNAL(clicked(bool)), this, SLOT(onClickMeifuBtn(bool)));
	connect(_oUI.shoushiBtn, SIGNAL(clicked(bool)), this, SLOT(onClickShoushiBtn(bool)));
	connect(_oUI.wuguanBtn, SIGNAL(clicked(bool)), this, SLOT(onClickWuguanBtn(bool)));
	connect(_oUI.tiezhiBtn, SIGNAL(clicked(bool)), this, SLOT(onClickTiezhiBtn(bool)));
	connect(_oUI.lvjingBtn, SIGNAL(clicked(bool)), this, SLOT(onClickLvjingBtn(bool)));
}

void BeautyUI::initOtherUI() {
	_pMeifuUI.reset(new MeifuUI(this));
	_pMeifuUI->setObjectName(QStringLiteral("MeifuUI"));
	_pMeifuUI->setEnabled(true);
	_pMeifuUI->setGeometry(QRect(10, 40, 220, 260));

	_pLvjingUI.reset(new LvjingUI(this));
	_pLvjingUI->setObjectName(QStringLiteral("LvjingUI"));
	_pLvjingUI->setEnabled(true);
	_pLvjingUI->setGeometry(QRect(10, 40, 220, 400));

	_pWuguanUI.reset(new WuguanUI(this));
	_pWuguanUI->setObjectName(QStringLiteral("WuguanUI"));
	_pWuguanUI->setEnabled(true);
	_pWuguanUI->setGeometry(QRect(10, 40, 220, 584));

	_pTiezhiUI.reset(new TiezhiUI(this));
	_pTiezhiUI->setObjectName(QStringLiteral("TiezhiUI"));
	_pTiezhiUI->setEnabled(true);
	_pTiezhiUI->setGeometry(QRect(10, 40, 220, 230));

	_pShoushiUI.reset(new ShoushiUI(this));
	_pShoushiUI->setObjectName(QStringLiteral("ShoushiUI"));
	_pShoushiUI->setEnabled(true);
	_pShoushiUI->setGeometry(QRect(10, 40, 220, 230));
}

void BeautyUI::switchToBtn(QPushButton* to) {
	_pCurrentBtn->setStyleSheet(QStringLiteral("color: rgb(0, 0, 0);"));
	to->setStyleSheet(QStringLiteral("color: rgb(0, 65, 255);"));
	_pCurrentBtn = to;
}

void BeautyUI::onClickMeifuBtn(bool) {
	_pMeifuUI->show();
	_pLvjingUI->hide();
	_pShoushiUI->hide();
	_pTiezhiUI->hide();
	_pWuguanUI->hide();
	switchToBtn(_oUI.meifuBtn);
}

void BeautyUI::onClickShoushiBtn(bool) {
	_pMeifuUI->hide();
	_pLvjingUI->hide();
	_pShoushiUI->show();
	_pTiezhiUI->hide();
	_pWuguanUI->hide();
	switchToBtn(_oUI.shoushiBtn);
}

void BeautyUI::onClickTiezhiBtn(bool) {
	_pMeifuUI->hide();
	_pLvjingUI->hide();
	_pShoushiUI->hide();
	_pTiezhiUI->show();
	_pWuguanUI->hide();
	switchToBtn(_oUI.tiezhiBtn);
}

void BeautyUI::onClickWuguanBtn(bool) {
	_pMeifuUI->hide();
	_pLvjingUI->hide();
	_pShoushiUI->hide();
	_pTiezhiUI->hide();
	_pWuguanUI->show();
	switchToBtn(_oUI.wuguanBtn);
}

void BeautyUI::onClickLvjingBtn(bool) {
	_pMeifuUI->hide();
	_pLvjingUI->show();
	_pShoushiUI->hide();
	_pTiezhiUI->hide();
	_pWuguanUI->hide();
	switchToBtn(_oUI.lvjingBtn);
}
