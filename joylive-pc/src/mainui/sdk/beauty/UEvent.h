#ifndef Event_h__
#define Event_h__
#include <windows.h>
#pragma once

class UEvent
{
public:
	UEvent();
	~UEvent();

	bool SetEvent();
	bool ResetEvent();
	void Wait(DWORD timeOut = INFINITE);

	HANDLE m_hObject;
};
#endif // Event_h__
