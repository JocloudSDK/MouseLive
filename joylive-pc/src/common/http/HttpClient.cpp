#include "HttpClient.h"
#include "../log/loggerExt.h"

using namespace base;

static const char* TAG = "HttpClient";

class HttpTask : public Task {
public:
	HttpTask(void* action) : Task(), _pAction(action) {}
	virtual ~HttpTask() {}
	virtual void process() {}
	virtual void finished() {
		HttpClientTask* task = (HttpClientTask*)_pAction;
		if (task != nullptr && task->_pObserver && task->_pObserver->alive()) {
			task->_pObserver->finish(task->_strUrl, task->_strBody, task->_iErrorCode);
			delete task;
		}
	}

private:
	void* _pAction;
};

HttpClient::HttpClient(QObject* parent)
	: QObject(parent) {
	_pTaskQueue.reset(new TaskQueue);
}

HttpClient::~HttpClient() {
}

void HttpClient::onFinished(QNetworkReply *reply, const QString& url) {
	int errorCode = -1;

	// 获取http状态码
	QVariant statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
	if (statusCode.isValid()) {
		Logd(TAG, Log(__FUNCTION__).setMessage("http state code = %d", statusCode.toInt()).addDetail("url", url.toStdString()));
		errorCode = statusCode.toInt();
	}

	QNetworkReply::NetworkError err = reply->error();
	if (err != QNetworkReply::NoError) {
		errorCode = -1;
		//statusCodeV是HTTP服务器的相应码，reply->error()是Qt定义的错误码，可以参考QT的文档
		QVariant statusCodeV = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
		qWarning() << QString("request %1 found error ....code: %2 %3").
			arg("on_get_head_image_finished").arg(statusCodeV.toInt()).arg((int)reply->error());
		qWarning(qPrintable(reply->errorString()));
		Logw(TAG, Log(__FUNCTION__).setMessage("QNetworkRequest state code = %d", statusCodeV.toInt())
			.addDetail("errorCode", std::to_string(reply->error())).addDetail("errorMsg", reply->errorString().toStdString()));
	}

	auto observer = std::find(_oObserverList.begin(), _oObserverList.end(), url);
	if (observer == _oObserverList.end()) {
		Logw(TAG, Log(__FUNCTION__).setMessage("no request").addDetail("url", url.toStdString()));
		reply->deleteLater();
		return;
	}

	HttpClientTask* ct = new HttpClientTask;
	ct->_iErrorCode = errorCode;
	ct->_pObserver = (*observer)._pObserver;
	ct->_strBody = reply->readAll();
	ct->_strUrl = url;
	HttpTask* t = new HttpTask(ct);
	_pTaskQueue->addTask(t);

	if (observer->_pData) {
		QNetworkAccessManager* p = (QNetworkAccessManager*)observer->_pData;
		p->deleteLater();
	}
	_oObserverList.erase(observer);
	reply->deleteLater();
}

int HttpClient::post(const QString& url, const QString& body, std::shared_ptr<HttpClientObserver> observer) {
	QNetworkAccessManager* p = new QNetworkAccessManager;
	std::function<void(QNetworkReply*)> fnBind = std::bind(&HttpClient::onFinished, this, std::placeholders::_1, url);
	connect(p, &QNetworkAccessManager::finished, this, fnBind);

	QNetworkRequest request;
	request.setUrl(QUrl(url));
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QSslConfiguration config;
	config.setPeerVerifyMode(QSslSocket::VerifyNone);
	config.setProtocol(QSsl::TlsV1_2);
	request.setSslConfiguration(config);

	int ret = -1;
	QNetworkReply* reply = p->post(request, body.toLocal8Bit());
	if (reply) {
		_oObserverList.emplace_back(HttpClientObserverInfo(url, observer, p));
		ret = 0;
		reply->ignoreSslErrors();
	}
	return ret;
}

int HttpClient::get(const QString& url, std::shared_ptr<HttpClientObserver> observer) {
	QNetworkAccessManager* p = new QNetworkAccessManager;
	std::function<void(QNetworkReply*)> fnBind = std::bind(&HttpClient::onFinished, this, std::placeholders::_1, url);
	connect(p, &QNetworkAccessManager::finished, this, fnBind);

	QNetworkRequest request;
	request.setUrl(QUrl(url));
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QSslConfiguration config;
	config.setPeerVerifyMode(QSslSocket::VerifyNone);
	config.setProtocol(QSsl::TlsV1_2);
	request.setSslConfiguration(config);

	int ret = -1;
	QNetworkReply* reply = p->get(request);
	if (reply) {
		_oObserverList.emplace_back(HttpClientObserverInfo(url, observer, p));
		ret = 0;
		reply->ignoreSslErrors();
	}
	return ret;
}
