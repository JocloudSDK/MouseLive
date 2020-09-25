#pragma once

#include <QTimer>

class JTimer : public QTimer {
	Q_OBJECT
public:
	JTimer();
	virtual ~JTimer();

	void start();
	void stop();

	bool isRunning() const { return _bRunning; }

private:
	bool _bRunning = false;
};
