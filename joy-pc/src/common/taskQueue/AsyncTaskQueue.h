#pragma once
#include "Task.h"
#include "Work.h"
#include "Thread.h"

#include <QMutex>
#include <QTimer>
#include <QHash>
#include <QQueue>
#include <QList>

class AsyncTaskQueue : public QObject {
	Q_OBJECT
public:
	explicit AsyncTaskQueue(QObject *parent = nullptr);
	~AsyncTaskQueue();

	void setPoolSize(quint32 size);

	void addTask(AsyncTask *t);
	void finishTask(quint64 id);
	// 正在运行、stop 掉，没运行，移除出 map
	void cancelTask(quint64 id);

private:
	QMutex _taskLock;
	QHash<quint64, AsyncTask *> _allTasks;
	QList<quint64> _runningTasks;
	QQueue<quint64> _pendindTasks;

	int _poolSize;
};
