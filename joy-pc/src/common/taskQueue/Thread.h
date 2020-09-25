#pragma once

#include <QThread>
#include <QDebug>

class Thread : public QThread {
	Q_OBJECT
public:
	Thread(QObject* parent = nullptr) : QThread(parent) {}
	~Thread() {
		requestInterruption();
		quit();
		wait();
		qDebug() << "~Thread()";
	}
};
