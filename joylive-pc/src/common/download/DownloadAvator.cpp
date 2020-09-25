#include "DownloadAvator.h"
#include "Download.h"
#include "../../mainui/Constans.h"

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

namespace Utils {
	DownloadAvatorPtr DownloadAvator::m_pInstance;
	DownloadAvator::DownloadAvator() {
	}

	DownloadAvator::~DownloadAvator() {

	}

	QString DownloadAvator::GetAvator(const QString& url, const QString& cellphone, DownloadAvatorNotify* notify) {
		QString dir = QCoreApplication::applicationDirPath() + USER_DATA_CACHE_PATH + "/" + cellphone + "/Avatar/";
		QDir tempDir;
		if (!tempDir.exists(dir))
		{
			qDebug() << QObject::tr("the dir is not exists, GetAvator");
		}

		auto filename = url.split("/").back();

		QVector<QString> suffixs;
		suffixs.push_back(".png");
		suffixs.push_back(".jpg");
		suffixs.push_back(".jpeg");

		QFile tempFile;
		for each (auto suffix  in suffixs)
		{
			auto tempImagePath = dir + filename + suffix;
			if (tempFile.exists(tempImagePath)){
				return tempImagePath;
			}
		}

		oTaskMap[url] = std::pair<QString, DownloadAvatorNotify*>(cellphone, notify);
		Download::GetInstance()->AddTask(url, this);
		return "";
	}

	void DownloadAvator::DownloadFinish(QNetworkReply* reply, const QString& url) {
		auto cellphone = oTaskMap[url].first;
		auto notify = oTaskMap[url].second;
		QString dir = QCoreApplication::applicationDirPath() + USER_DATA_CACHE_PATH + "/" + cellphone + "/Avatar/";

		QDir tempDir;
		if (!tempDir.exists(dir))
		{
			qDebug() << QObject::tr("the dir is not exists, DownloadFinish");
			if (!tempDir.mkpath(dir)){
				qDebug() << QObject::tr("create dir failed") << dir;
				return;
			}
		}

		auto type = reply->header(QNetworkRequest::ContentTypeHeader).toString();
		auto disposition = reply->rawHeader("Content-Disposition");
		qDebug() << disposition;

		auto strFilename = url.split("/").back();
		auto filename = strFilename + ".png";
		if (type.contains("jpg") || type.contains("jpeg"))
		{
			filename = strFilename + ".jpg";
		}

		auto filePath = dir + filename;

		auto resp = reply->readAll();
		QPixmap cur_pictrue;

		if (!cur_pictrue.loadFromData(resp)){
			qWarning() << "on_get_head_image_finished" << ":load head image failed!";
		}
		else{
			if (!cur_pictrue.save(filePath)){
				qWarning() << "on_get_head_image_finished" << ":save head image failed!" << filePath;
			}
			else{
				if (notify) {
					notify->DownloadFinish(filePath);
				}
			}
		}
	}
}
