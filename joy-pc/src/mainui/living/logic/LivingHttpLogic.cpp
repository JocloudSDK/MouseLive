#include "LivingHttpLogic.h"
#include "../../Constans.h"
#include "../../../common/log/loggerExt.h"

using namespace base;

static const char* TAG = "MainHttpLogic";

class LivingHttpLogicObserver : public HttpClientObserver {
public:
	LivingHttpLogicObserver(LivingHttpLogic* l) : _pLivingHttpLogic(l) {}
	~LivingHttpLogicObserver() {}

	virtual bool alive() override {
		QMutexLocker locaker(&_oAliveMutex);
		return _bAlive;
	}

	void setAlive(bool isAlive) {
		QMutexLocker locaker(&_oAliveMutex);
		_bAlive = isAlive;
	}

	virtual void finish(const QString& url, const QString& body, int error) override {
		_pLivingHttpLogic->onFinish(url, body, error);
	}

private:
	QMutex _oAliveMutex;
	bool _bAlive = true;
	LivingHttpLogic* _pLivingHttpLogic;
};


LivingHttpLogic::LivingHttpLogic(QObject* parent) : QObject(parent) {
	_pLivingHttpLogicObserver.reset(new LivingHttpLogicObserver(this));
}

LivingHttpLogic::~LivingHttpLogic() {
	_pLivingHttpLogicObserver->setAlive(false);
}

int LivingHttpLogic::getAnchorList(const QString& body) {
	Logd(TAG, Log(__FUNCTION__).addDetail("body", body.toStdString()));
	return HttpClient::GetInstance()->post(STR_HTTP_GET_ANCHOR_LIST, body, _pLivingHttpLogicObserver);
}

int LivingHttpLogic::setChatId(const QString& body) {
	Logd(TAG, Log(__FUNCTION__).addDetail("body", body.toStdString()));
	return HttpClient::GetInstance()->post(STR_HTTP_SET_CHARID, body, _pLivingHttpLogicObserver);
}

int LivingHttpLogic::createRoom(const QString& body) {
	Logd(TAG, Log(__FUNCTION__).addDetail("body", body.toStdString()));
	return HttpClient::GetInstance()->post(STR_HTTP_CREATE_ROOM, body, _pLivingHttpLogicObserver);
}

void LivingHttpLogic::onFinish(const QString& url, const QString& body, int error) {
	Logd(TAG, Log(__FUNCTION__).setMessage("error:%d", error).addDetail("url", url.toStdString())
		.addDetail("body", body.toStdString()));
	if (url == STR_HTTP_GET_ANCHOR_LIST) {
		if (error != 200) {
			emit onGetAnchorListFailed();
		}
		else {
			emit onGetAnchorListSuccess(body);
		}
	}
	else if (url == STR_HTTP_SET_CHARID) {
		if (error != 200) {
			emit onSetChatIdFailed();
		}
		else {
			emit onSetChatIdSuccess(body);
		}
	}
	else if (url == STR_HTTP_CREATE_ROOM) {
		if (error != 200) {
			emit onCreateRoomFailed();
		}
		else {
			emit onCreateRoomSuccess(body);
		}
	}
	else {
		Logw(TAG, Log(__FUNCTION__).setMessage("return error url"));
	}
}
