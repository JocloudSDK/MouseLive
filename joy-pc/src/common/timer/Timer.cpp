#include "Timer.h"

JTimer::JTimer() {
}

JTimer::~JTimer() {
}

void JTimer::start() {
	__super::start();
	_bRunning = true;
}

void JTimer::stop() {
	__super::stop();
	_bRunning = false;
}
