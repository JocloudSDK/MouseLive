#pragma once

#include <QObject>
#include <QDebug>

class Task {
public:
	Task(){
		static quint64 sequence = 0;
		_iId = ++sequence;
	}
	virtual ~Task() {}

	inline quint64 id() { return _iId; }

	virtual void process() = 0;
	virtual void finished() = 0;

private:
	quint64 _iId;
};

#if 0
class AsyncTask : public QObject {
	Q_OBJECT
public:
	explicit AsyncTask(QObject* parent) : QObject(parent) {
		static quint64 sequence = 0;
		_iId = ++sequence;
	}

	virtual void startAsyncTask() = 0;
	inline quint64 id() { return _iId; }

signals:
	void finished(quint64 id);

private:
	quint64 _iId;
};
#endif
