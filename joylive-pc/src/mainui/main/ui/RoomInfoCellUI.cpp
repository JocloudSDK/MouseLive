#include "RoomInfoCellUI.h"
#include "../../../common/utils/String.h"

RoomInfoCellUI::RoomInfoCellUI(QWidget *parent) 
	: QWidget(parent) {
	_oUI.setupUi(this);

	setWindowFlags(Qt::FramelessWindowHint);//ÎÞ±ß¿ò   
	setAttribute(Qt::WA_TranslucentBackground);//±³¾°Í¸Ã÷
	setAttribute(Qt::WA_QuitOnClose, true);

	//_oUI.pushButton->setAttribute(Qt::WA_TranslucentBackground);

	//connect(_oUI.pushButton, SIGNAL(clicked(bool)), this, SLOT(onClickItem(bool)));
}

RoomInfoCellUI::~RoomInfoCellUI() {
}

void RoomInfoCellUI::setRoomInfo(const GetRoomListResponse::RoomInfoResponse& resp) {
	_oRoomInfo = resp;
	_oUI.roomNameLabel->setText(stdString2QString(resp.RName));
	_oUI.roomNumbersLabel->setText(QString("%1").arg(resp.RCount));
	_oUI.anchorNickLabel->setText(stdString2QString(resp.ROwner.NickName));
}

void RoomInfoCellUI::onClickItem(bool) {
	emit onSelectRoom(_oRoomInfo);
}

void RoomInfoCellUI::mousePressEvent(QMouseEvent *event)
{
	if (event->button() == Qt::LeftButton) {
		if (_oUI.topRootWidget->geometry().contains(this->mapFromGlobal(QCursor::pos()))) {
			bClicked = true;
			return;
		}
	}
}

void RoomInfoCellUI::mouseReleaseEvent(QMouseEvent *event)
{
	if (event->button() == Qt::LeftButton)
	{
		if (_oUI.topRootWidget->geometry().contains(this->mapFromGlobal(QCursor::pos()))) {
			if (bClicked)
			{
				bClicked = false;
				emit onSelectRoom(_oRoomInfo);
			}
			return;
		}
	}
}
