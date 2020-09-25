#pragma once
#include "Task.h"
#include "Thread.h"
#include "Work.h"
#include <QMutex>
#include <QTimer>
#include <memory>

class TaskQueue : public QObject {
	Q_OBJECT
public:
	explicit TaskQueue(QObject* parent = nullptr);
	~TaskQueue();

	quint64 addTask(Task* t);
	void cancelTask(quint64 id);

public slots:
	void onTaskFinished(Task* t, bool hasLeft);
	void onThreadInIdle();

private:
	QMutex _oThreadIdleMutex;
	QTimer _oThreadIdleTimer;
	std::shared_ptr<Thread> _pThread;
	std::shared_ptr<Worker> _pWorker;
};
