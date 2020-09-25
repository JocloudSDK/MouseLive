#include "UserCellUI.h"

UserCellUI::UserCellUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//无边框   
	setAttribute(Qt::WA_TranslucentBackground);//背景透明
	setAttribute(Qt::WA_QuitOnClose, true);

	_oUI.userGraphicsView->setPixmap(QPixmap(":/mainui/cover_default"));

	//connect(_oUI.pushButton, SIGNAL(clicked(bool)), this, SLOT(onClickItem(bool)));
}

UserCellUI::~UserCellUI() {

}

void UserCellUI::onClickItem(bool) {

}

// 需要获取下用户信息
void UserCellUI::setData(const UserInfo& data) {
	_oData = data;
	//_oUI.nickLabel->setText(_oData._strNickName);
	_oUI.nickLabel->setText(QString::number(_oData._iUid));
}
