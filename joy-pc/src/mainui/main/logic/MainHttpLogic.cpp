#include "MainHttpLogic.h"
#include "../../Constans.h"
#include "../../../common/log/loggerExt.h"

using namespace base;

static const char* TAG = "MainHttpLogic";

class MainHttpLogicObserver : public HttpClientObserver {
public:
	MainHttpLogicObserver(MainHttpLogic* l) : _pMainHttpLogic(l) {}
	~MainHttpLogicObserver() {}

	virtual bool alive() override {
		QMutexLocker locaker(&_oAliveMutex);
		return _bAlive;
	}

	void setAlive(bool isAlive) {
		QMutexLocker locaker(&_oAliveMutex);
		_bAlive = isAlive;
	}

	virtual void finish(const QString& url, const QString& body, int error) override {
		_pMainHttpLogic->onFinish(url, body, error);
	}

private:
	QMutex _oAliveMutex;
	bool _bAlive = true;
	MainHttpLogic* _pMainHttpLogic;
};


MainHttpLogic::MainHttpLogic(QObject* parent) : QObject(parent) {
	_pMainHttpLogicObserver.reset(new MainHttpLogicObserver(this));
}

MainHttpLogic::~MainHttpLogic() {
	_pMainHttpLogicObserver->setAlive(false);
}

int MainHttpLogic::login(const QString& body) {
	Logd(TAG, Log(__FUNCTION__).addDetail("body", body.toStdString()));
	return HttpClient::GetInstance()->post(STR_HTTP_LOGIN, body, _pMainHttpLogicObserver);
}

int MainHttpLogic::getRoomList(const QString& body) {
	Logd(TAG, Log(__FUNCTION__).addDetail("body", body.toStdString()));
	return HttpClient::GetInstance()->post(STR_HTTP_GET_ROOM_LIST, body, _pMainHttpLogicObserver);
}

int MainHttpLogic::getRoomInfo(const QString& body) {
	Logd(TAG, Log(__FUNCTION__).addDetail("body", body.toStdString()));
	return HttpClient::GetInstance()->post(STR_HTTP_GET_ROOM_INFO, body, _pMainHttpLogicObserver);
}

void MainHttpLogic::onFinish(const QString& url, const QString& body, int error) {
	Logd(TAG, Log(__FUNCTION__).setMessage("error:%d", error).addDetail("url", url.toStdString())
		.addDetail("body", body.toStdString()));
	if (url == STR_HTTP_GET_ROOM_LIST) {
		if (error != 200) {
			emit onGetRoomListFailed();
		}
		else {
			emit onGetRoomListSuccess(body);
		}
	}
	else if (url == STR_HTTP_LOGIN) {
		if (error != 200) {
			emit onLoginFailed();
		}
		else {
			emit onLoginSuccess(body);
		}
	}
	else if (url == STR_HTTP_GET_ROOM_INFO) {
		if (error != 200) {
			emit onGetRoomInfoFailed();
		}
		else {
			emit onGetRoomInfoSuccess(body);
		}
	}
	else {
		Logw(TAG, Log(__FUNCTION__).setMessage("return error url"));
	}
}
