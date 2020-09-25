#pragma once

#include <windows.h>

class CSLock {
public:
	CSLock(CRITICAL_SECTION& cs)
		: cs_(cs) {
		EnterCriticalSection(&cs_);
	}

	~CSLock() {
		LeaveCriticalSection(&cs_);
	}

protected:
	CRITICAL_SECTION& cs_;
};