#include "UserCellUI.h"

UserCellUI::UserCellUI(QWidget *parent)
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//�ޱ߿�   
	setAttribute(Qt::WA_TranslucentBackground);//����͸��
	setAttribute(Qt::WA_QuitOnClose, true);

	_oUI.userGraphicsView->setPixmap(QPixmap(":/mainui/cover_default"));

	//connect(_oUI.pushButton, SIGNAL(clicked(bool)), this, SLOT(onClickItem(bool)));
}

UserCellUI::~UserCellUI() {

}

void UserCellUI::onClickItem(bool) {

}

// ��Ҫ��ȡ���û���Ϣ
void UserCellUI::setData(const UserInfo& data) {
	_oData = data;
	//_oUI.nickLabel->setText(_oData._strNickName);
	_oUI.nickLabel->setText(QString::number(_oData._iUid));
}
