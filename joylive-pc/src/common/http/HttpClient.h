#pragma once

#include <QObject>
#include <QNetworkReply>
#include <list>
#include <memory>
#include "../taskQueue/TaskQueue.h"
#include "../utils/Singleton.h"

class HttpClientObserver {
public:
	virtual bool alive() = 0;
	virtual void finish(const QString& url, const QString& body, int error) = 0;
};

// HttpClientTask 和 HttpClientObserverInfo 需要统一

struct HttpClientTask {
	std::shared_ptr<HttpClientObserver> _pObserver;
	QString _strBody;
	QString _strUrl;
	int _iErrorCode;
};

struct HttpClientObserverInfo {
public:
	HttpClientObserverInfo(const QString& url, std::shared_ptr<HttpClientObserver> observer, void* data) {
		_strUrl = url;
		_pObserver = observer;
		_pData = data;
	}

	bool operator==(const QString& url) const {
		return this->_strUrl == url;
	}

	std::shared_ptr<HttpClientObserver> _pObserver;
	QString _strUrl;
	void* _pData;
};

class HttpClient : public QObject, public Singleton<HttpClient> {
	Q_OBJECT

protected:
	friend class Singleton<HttpClient>;
	HttpClient(QObject* parent = nullptr);
	~HttpClient();

protected:
	void onFinished(QNetworkReply *reply, const QString& url);

public:
	int post(const QString& url, const QString& body, std::shared_ptr<HttpClientObserver> observer);
	int get(const QString& url, std::shared_ptr<HttpClientObserver> observer);

private:
	std::list<HttpClientObserverInfo> _oObserverList;
	std::shared_ptr<TaskQueue> _pTaskQueue;
};
