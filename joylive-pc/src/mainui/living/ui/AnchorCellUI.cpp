/*!
 * \file AnchorCellUI.cpp
 *
 * \author Zhangjianping
 * \date 2020/07/31
 * \contact 114695092@qq.com
 *
 * 
 */
#include "AnchorCellUI.h"
#include "../../../common/utils/String.h"
#include "../../../common/qss/QssLoad.h"

AnchorCellUI::AnchorCellUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//ÎÞ±ß¿ò   
	setAttribute(Qt::WA_TranslucentBackground);//±³¾°Í¸Ã÷
	setAttribute(Qt::WA_QuitOnClose, true);

	initDefault();

	Utils::QssLoad::Load(this, "MessageUI.qss");

	connect(_oUI.pkBtn, SIGNAL(clicked(bool)), this, SLOT(onClickPKBtn(bool)));

	_oUI.pkBtn->setText(QApplication::translate("AnchorCellUI", "PK", 0));
	_oUI.pkLabel->setText(QApplication::translate("AnchorCellUI", "PKing", 0));
}

AnchorCellUI::~AnchorCellUI() {

}

void AnchorCellUI::setData(const AnchorResponseData& data, int64_t _iPKUid) {
	_oData = data;
	_oUI.nickLabel->setText(stdString2QString(_oData.AName));

	if (_iPKUid != 0) {
		if (_oData.AId == _iPKUid) {
			beginPK();
		}
		else {
			beginingPK();
		}
	}
	else {
		endPK();
	}
}

void AnchorCellUI::beginPK() {
	_oUI.pkBtn->setEnabled(false);
	_bIsLink = true;
}

void AnchorCellUI::beginingPK() {
	if (_bIsLink) {
		_oUI.pkLabel->show();
		_oUI.pkBtn->hide();
	}
	else {
		_oUI.pkBtn->hide();
		_oUI.pkLabel->hide();
	}
}

void AnchorCellUI::endPK() {
	_oUI.pkBtn->setEnabled(true);
	_oUI.pkBtn->show();
	_oUI.pkLabel->hide();
	_bIsLink = false;
}

void AnchorCellUI::changeLanguage() {
	_oUI.pkBtn->setText(QApplication::translate("AnchorCellUI", "PK", 0));
	_oUI.pkLabel->setText(QApplication::translate("AnchorCellUI", "PKing", 0));
}

void AnchorCellUI::onClickPKBtn(bool) {
	emit onPKRequest(_oData.AId, _oData.ARoom);
}

void AnchorCellUI::initDefault() {
	_oUI.anchorGraphicsView->setPixmap(QPixmap(":/mainui/cover_default"));
}

