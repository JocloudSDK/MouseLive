#include "QssLoad.h"

#include <QFile>
#include <QDebug>
#include <QCoreApplication>
#include <QDir>
#include <QApplication>
#include <QStyle>

#ifdef _DEBUG
const QString QSS_PATH = "./resource/skin";
#else
const QString QSS_PATH = "./skin";
#endif

namespace Utils{
	namespace QssLoad
	{
		void LoadS() {
#if 0
			QString applicationDirPathStr = QCoreApplication::applicationDirPath();
			QString qssDirPathStr = applicationDirPathStr + QSS_PATH;
#endif

			QString qssDirPathStr = QSS_PATH;

			QDir dir(qssDirPathStr);
			QStringList qssFileNames = dir.entryList();

			QString qss;

			foreach(QString name, qssFileNames) {
				qDebug() << QString("=> load QSS file: %1").arg(name);

				QString path = qssDirPathStr + "/" + name;
				QFile file(path);
				if (!file.open(QIODevice::ReadOnly)) {
					qDebug() << QString("load QSS file failed: %1").arg(path);
					continue;
				}

				qss.append(file.readAll()).append("\n");
				file.close();
			}

			if (!qss.isEmpty()) {
				// qDebug() << qss;
				qApp->setStyleSheet(qss);
				qApp->style()->unpolish(qApp);
				qApp->style()->polish(qApp);
			}
		}

		void Load(QWidget* widget, const QString& qssName) {
#if 0
			QString applicationDirPathStr = QCoreApplication::applicationDirPath();
			QString qssPathStr = applicationDirPathStr + QSS_PATH + "/" + qssName;
#endif

			QString qssPathStr = QSS_PATH + "/" + qssName;

			QFile file(qssPathStr);
			if (!file.open(QIODevice::ReadOnly)) {
				qDebug() << QString("load QSS file failed: %1").arg(qssPathStr);
				return;
			}

			QString qss = file.readAll();
			widget->setStyleSheet(qss);
			widget->style()->unpolish(widget);
			widget->style()->polish(widget);
			file.close();
		}
	}
}