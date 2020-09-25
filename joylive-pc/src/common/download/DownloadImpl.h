#pragma once

#include <QString>
#include <QPixmap>
#include <memory>
#include <QNetworkReply>

class DownloadNotify;
class DownloadImpl : public QObject
{
	Q_OBJECT
public:
	DownloadImpl(QObject *parent = nullptr);
	~DownloadImpl();

	void AddTask(const QString& url, DownloadNotify* notify);

	void download(const QString& url);

	void finish(QNetworkReply *reply, const QString& url);

private:
	QNetworkAccessManager* pNetworkAccessManager;
	std::map<QString, DownloadNotify*> oTaskMap;
};
