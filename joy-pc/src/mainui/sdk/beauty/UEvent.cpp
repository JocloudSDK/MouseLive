#include "UEvent.h"

UEvent::UEvent(void)
{
	m_hObject = CreateEvent(NULL,TRUE,FALSE,NULL) ;
}

UEvent::~UEvent(void)
{
	CloseHandle(m_hObject);
}

bool UEvent::SetEvent()
{
	return ::SetEvent(m_hObject) == TRUE;
}

bool UEvent::ResetEvent()
{
	return ::ResetEvent(m_hObject) == TRUE;
}

void UEvent::Wait( DWORD timeOut )
{
	WaitForSingleObject(m_hObject, timeOut);
}
