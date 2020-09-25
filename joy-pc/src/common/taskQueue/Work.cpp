#include "Work.h"
#include <QDateTime>
#include <QDebug>
#include <QThread>

Worker::Worker(QObject* parent) : QObject(parent) {
	connect(this, SIGNAL(startWork()), this, SLOT(onTaskAdded()));
}

void Worker::onTaskAdded() {
	QMutexLocker locker(&_oTaskMutex);
	if (_oTaskList.empty()) {
		return;
	}
	Task *t = _oTaskList.dequeue();
	if (!t) {
		return;
	}
	locker.unlock();
	if (!t) {
		return;
	}
	qDebug() << QDateTime::currentMSecsSinceEpoch() << " Worker process task" << t->id() << " in thread id:" << QThread::currentThreadId();
	t->process();

	locker.relock();
	bool hasLeft = !_oTaskList.isEmpty();
	locker.unlock();
	emit finishWork(t, hasLeft);
	qDebug() << QDateTime::currentMSecsSinceEpoch() << " Worker process task" << t->id() << ", has left:" << hasLeft << " end in thread id:" << QThread::currentThreadId();
}

quint64 Worker::addTask(Task* t) {
	qDebug() << QDateTime::currentMSecsSinceEpoch() << " Worker add Task " << t->id() << " in thread id:" << QThread::currentThreadId();
	QMutexLocker locker(&_oTaskMutex);
	_oTaskList.enqueue(t);
	locker.unlock();

	emit startWork();
	qDebug() << QDateTime::currentMSecsSinceEpoch() << " Worker add Task " << t->id() << " end in thread id:" << QThread::currentThreadId();
	return t->id();
}

void Worker::cancelTask(quint64 id) {
	QMutexLocker locker(&_oTaskMutex);
	for (qint32 i = 0, l = _oTaskList.size(); i < l; ++i) {
		if (_oTaskList.at(i)->id() == id) {
			_oTaskList.removeAt(i);
			break;
		}
	}
}
