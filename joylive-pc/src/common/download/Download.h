#ifndef _DOWNLOAD_H_
#define _DOWNLOAD_H_

#include <QString>
#include <QPixmap>
#include <memory>
#include <QNetworkReply>
#include "DownloadImpl.h"

class Download;
typedef std::shared_ptr<Download> DownloadPtr;

class DownloadNotify {
public:
	virtual void DownloadFinish(QNetworkReply* reply, const QString& url) = 0;
};

class Download
{
public:
	~Download();
	Download();
	static DownloadPtr GetInstance()
	{
		if (m_pInstance.get() == nullptr)
		{
			m_pInstance.reset(new Download());
		}
		return m_pInstance;
	}

	static void Release()
	{
		if (m_pInstance.get() != nullptr)
		{
			m_pInstance = nullptr;
		}
	}

	void AddTask(const QString& url, DownloadNotify* notify);

private:
	

private:
	static DownloadPtr m_pInstance;
	DownloadImpl* pImpl;
};


#endif