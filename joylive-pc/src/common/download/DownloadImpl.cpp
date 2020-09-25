#include "DownloadImpl.h"
#include "Download.h"

#include <QCoreApplication>
#include <QDir>
#include <QVector>
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

#include <functional>
#include <map>

DownloadImpl::DownloadImpl(QObject *parent)
	:QObject(parent) {
	pNetworkAccessManager = new QNetworkAccessManager();
}

DownloadImpl::~DownloadImpl() {
	if (pNetworkAccessManager)
		delete pNetworkAccessManager;
	pNetworkAccessManager = nullptr;
}

void DownloadImpl::AddTask(const QString& url, DownloadNotify* notify) {
	oTaskMap[url] = notify;
	download(url);
}

void DownloadImpl::download(const QString& url) {
	QNetworkRequest request;

	std::function<void(QNetworkReply*)> fnBind = std::bind(&DownloadImpl::finish, this, std::placeholders::_1, url);
	connect(pNetworkAccessManager, &QNetworkAccessManager::finished, this, fnBind);

	request.setUrl(QUrl(url));

	QSslConfiguration config;
	config.setPeerVerifyMode(QSslSocket::VerifyNone);
	config.setProtocol(QSsl::TlsV1_2);
	request.setSslConfiguration(config);

	QNetworkReply* reply = pNetworkAccessManager->get(request);
	reply->ignoreSslErrors();
}

void DownloadImpl::finish(QNetworkReply *reply, const QString& url) {
	// 获取http状态码
	QVariant statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
	if (statusCode.isValid()){
		qDebug() << "status code=" << statusCode.toInt();
	}
	else {
		qDebug() << "download failed, url: " + url;
		return;
	}

	QNetworkReply::NetworkError err = reply->error();
	if (err != QNetworkReply::NoError) {
		qWarning() << QString("request %1 handle errors here").arg("on_get_head_image_finished");
		//statusCodeV是HTTP服务器的相应码，reply->error()是Qt定义的错误码，可以参考QT的文档
		QVariant statusCodeV = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
		qWarning() << QString("request %1 found error ....code: %2 %3").
			arg("on_get_head_image_finished").arg(statusCodeV.toInt()).arg((int)reply->error());
		qWarning(qPrintable(reply->errorString()));
	}
	else {
		auto notify = oTaskMap[url];
		if (notify) {
			notify->DownloadFinish(reply, url);
		}
		oTaskMap.erase(url);
	}

	reply->deleteLater();
}
