#pragma once

#include <QtWidgets/QWidget>
#include "ui_AnchorCellUI.h"
#include "../../RoomInfo.h"
#include "../../LogicModel.h"

class AnchorCellUI : public QWidget {
	Q_OBJECT

public:
	AnchorCellUI(QWidget *parent = Q_NULLPTR);
	~AnchorCellUI();

	void setData(const AnchorResponseData& data, int64_t _iPKUid);

	int64_t getUid() const { return _oData.AId; }

	void beginPK();
	void beginingPK();
	void endPK();
	void changeLanguage();

signals:
	void onPKRequest(int64_t uid, int64_t roomId);

public slots:
	void onClickPKBtn(bool);

private:
	void initDefault();

private:
	Ui::AnchorCellUIClass _oUI;
	AnchorResponseData _oData;
	bool _bIsLink = false;
};