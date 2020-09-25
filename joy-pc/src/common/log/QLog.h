#ifndef _Q_LOG_H_
#define _Q_LOG_H_

#include "../utils/Sigleton.h"

#include <qlogging.h>
#include <QString>
#include <QFile>

class QLog : public Singleton<QLog>
{
protected:
	friend class Singleton<QLog>;
	QLog();

public:
	virtual ~QLog();


	void setLogLevel(int level);

	int getLogLevel() const {
		return m_logLevel;
	}

	bool ensureLogDir(const QString &dir);
	bool createLogFile(const QString &dir, const QString &name);
	
	QFile* getFile() const {
		return m_logFile;
	}

	static void outputMessage(QtMsgType type, const QMessageLogContext &context, const QString &msg);

private:
	QFile *m_logFile;

	int m_logLevel;
};

#endif