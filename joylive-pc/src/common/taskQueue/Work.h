#pragma once

#include <QObject>
#include <QMutex>
#include <QQueue>
#include "Task.h"

class Worker : public QObject {
	Q_OBJECT
public:
	explicit Worker(QObject* parent = nullptr);

public: // api
	quint64 addTask(Task* t);
	void cancelTask(quint64 id);

signals:
	void startWork();
	void finishWork(Task* t, bool hasLeft);

public slots:
	void onTaskAdded();

private:
	QMutex _oTaskMutex;
	QQueue<Task*> _oTaskList;
};
