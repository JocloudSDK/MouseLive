#ifndef _DOWNLOAD_AVATOR_H_
#define _DOWNLOAD_AVATOR_H_

#include <QString>
#include <QPixmap>
#include <memory>

#include "Download.h"

namespace Utils {

	class DownloadAvator;
	typedef std::shared_ptr<DownloadAvator> DownloadAvatorPtr;

	class DownloadAvatorNotify {
	public:
		virtual void DownloadFinish(const QString& localUrl) = 0;
	};

	class DownloadAvator : public DownloadNotify
	{
	public:
		~DownloadAvator();

		static DownloadAvatorPtr GetInstance()
		{
			if (m_pInstance.get() == nullptr)
			{
				m_pInstance.reset(new DownloadAvator());
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

		QString GetAvator(const QString& url, const QString& cellphone, DownloadAvatorNotify* notify);

	private:
		virtual void DownloadFinish(QNetworkReply* reply, const QString& url);

	private:
		DownloadAvator();

	private:
		static DownloadAvatorPtr m_pInstance;
		std::map<QString, std::pair<QString, DownloadAvatorNotify*>> oTaskMap;
	};
}

#endif