#include "TaskQueue.h"
#include <QDateTime>

TaskQueue::TaskQueue(QObject* parent) : QObject(parent)
, _pThread(nullptr)
, _pWorker(nullptr)
{
	_oThreadIdleTimer.setInterval(3000);
	_oThreadIdleTimer.setSingleShot(true);

	connect(&_oThreadIdleTimer, SIGNAL(timeout()), this, SLOT(onThreadInIdle()));
}

TaskQueue::~TaskQueue() {
	qDebug() << QDateTime::currentMSecsSinceEpoch() << " ~TaskQueue()";
}

quint64 TaskQueue::addTask(Task* t) {
	if (!t) {
		return 0;
	}
	QMutexLocker locaker(&_oThreadIdleMutex);
	if (!_pThread) {
		_pThread.reset(new Thread(this));
		_pWorker.reset(new Worker());
		_pWorker->moveToThread(_pThread.get());
		qDebug() << QDateTime::currentMSecsSinceEpoch() << " main thread id:" << QThread::currentThreadId();
		qDebug() << QDateTime::currentMSecsSinceEpoch() << " _worker thread id:" << _pWorker->thread();
		qDebug() << QDateTime::currentMSecsSinceEpoch() << "  ============= ";

		connect(_pWorker.get(), SIGNAL(finishWork(Task *, bool)), this, SLOT(onTaskFinished(Task *, bool)));

		// 启动线程的 event loop
		_pThread->start();
	}

	// 给 worker 加一个任务
	_pWorker->addTask(t);
	_oThreadIdleTimer.stop();

	return t->id();
}

void TaskQueue::cancelTask(quint64 id) {
	_pWorker->cancelTask(id);
}

void TaskQueue::onTaskFinished(Task* t, bool hasLeft) {
	if (!t) {
		return;
	}
	qDebug() << QDateTime::currentMSecsSinceEpoch() << " TaskQueue finish task" << t->id() << " in thread id:" << QThread::currentThreadId();
	t->finished();
	delete t;
	if (!hasLeft) {
		_oThreadIdleTimer.start();
	}
}

void TaskQueue::onThreadInIdle() {
	qDebug() << "TaskQueue::onThreadInIdle()";
	QMutexLocker locaker(&_oThreadIdleMutex);
	if (_pThread) {
		_pThread->requestInterruption();
		_pThread->quit();
		_pThread->wait();
		_pThread->deleteLater();
		_pWorker->deleteLater();
		_pThread.reset();
		_pWorker.reset();
	}
}
