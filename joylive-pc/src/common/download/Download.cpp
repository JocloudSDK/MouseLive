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


DownloadPtr Download::m_pInstance;

Download::Download() {
	pImpl = new DownloadImpl();
}

Download::~Download() {
	if (pImpl)
		delete pImpl;
	pImpl = nullptr;
}

void Download::AddTask(const QString& url, DownloadNotify* notify) {
	pImpl->AddTask(url, notify);
}
