#include "QLog.h"

#include <QDate>
#include <QIODevice>
#include <QTextStream>

#include <windows.h>
#include <QDir>
QLog::QLog() {
	m_logFile = nullptr;
}

QLog::~QLog() {
	if (m_logFile) {
		m_logFile->close();
		delete m_logFile;
	}
	m_logFile = nullptr;
}

void QLog::setLogLevel(int level)
{
	m_logLevel = level;
}

bool QLog::ensureLogDir(const QString &dirPath)
{
	QDir dir;
	if (dir.exists(dirPath)) {
		return true;
	}
	return dir.mkpath(dirPath); //ÓÃmkdir²»ÐÐ
}

bool QLog::createLogFile(const QString &dir, const QString &name) {
	if (m_logFile)
		return true;

	if (!ensureLogDir(dir))
	{
		return false;
	}
	// get current time
	QDateTime current_date_time = QDateTime::currentDateTime();
	QString current_date = current_date_time.toString("yyyy-MM-dd");

	QTime current_time = QTime::currentTime();
	int hour = current_time.hour();
	int minute = current_time.minute();
	int second = current_time.second();

	QString path = dir + QString("/%1-%2-%3%4%5.log").arg(name).arg(current_date).arg(hour).arg(minute).arg(second);

	m_logFile = new QFile(path);
	if (!m_logFile)
		return false;

	if (!m_logFile->open(QIODevice::WriteOnly | QIODevice::Append)) {
		m_logFile->close();
		delete m_logFile;
		m_logFile = nullptr;
	}
	return true;
}

void QLog::outputMessage(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
	if (type < QLog::GetInstance()->getLogLevel()){
		return;
	}

	static QMutex mutex;
	mutex.lock();

	QString text;
	switch (type)
	{
	case QtDebugMsg:
		text = QString("Debug:");
		break;

	case QtWarningMsg:
		text = QString("Warning:");
		break;

	case QtCriticalMsg:
		text = QString("Critical:");
		break;

	case QtFatalMsg:
		text = QString("Fatal:");
		break;
	case QtInfoMsg:
		text = QString("Info:");
		break;
	}

	QString context_info = QString("File:(%1) Line:(%2)").arg(QString(context.file)).arg(context.line);
	QString current_date_time = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss ddd");
	QString current_date = QString("(%1)").arg(current_date_time);
	QString message = QString("%1 %2 %3 %4").arg(current_date).arg(text).arg(context_info).arg(msg);

	QFile *file = QLog::GetInstance()->getFile();
	if (file) {
		QTextStream text_stream(file);
		text_stream << message << "\r\n";
		file->flush();
	}

#ifndef NDEBUG
	message += "\n";
	wchar_t* s = (wchar_t *)(message.utf16());
	OutputDebugString((LPCWSTR)s);
#endif

	mutex.unlock();
}