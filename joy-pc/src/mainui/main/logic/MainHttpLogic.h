#pragma once

#include "../../../common/http/HttpClient.h"
#include <QObject>
#include <QMutex>

class MainHttpLogicObserver;
class MainHttpLogic : public QObject {
	friend class MainHttpLogicObserver;
	Q_OBJECT
public:
	explicit MainHttpLogic(QObject* parent = nullptr);
	~MainHttpLogic();

	int login(const QString& body);
	int getRoomList(const QString& body);
	int getRoomInfo(const QString& body);

protected:
	void onFinish(const QString& url, const QString& body, int error);

signals:
	void onLoginSuccess(const QString& body);
	void onLoginFailed();
	void onGetRoomListSuccess(const QString& body);
	void onGetRoomListFailed();
	void onGetRoomInfoSuccess(const QString& body);
	void onGetRoomInfoFailed();

private:
	std::shared_ptr<MainHttpLogicObserver> _pMainHttpLogicObserver;
};
