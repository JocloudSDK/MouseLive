#include <Process.h>
#include <time.h>
#include "Thread.h"

//////////////////////////////////////////////////////////////////////////
struct tagThreadParameter
{
	bool							bSuccess;	
	HANDLE					hEventFinish;
	CServiceThread*    m_pServiceThread;
};


//////////////////////////////////////////////////////////////////////////
CThreadLockHandle::CThreadLockHandle(IThreadLock * pIThreadLock, bool bAutoLock)
{
	m_nLockCount = 0;
	m_pIThreadLock = pIThreadLock;
	if(bAutoLock)
		Lock();
	return;
}

CThreadLockHandle::~CThreadLockHandle()
{
	while(m_nLockCount>0)
		UnLock();
}

void CThreadLockHandle::Lock()
{
	m_nLockCount++;
	m_pIThreadLock->Lock();
}

void CThreadLockHandle::UnLock()
{
	m_nLockCount--;
	m_pIThreadLock->UnLock();
}

//////////////////////////////////////////////////////////////////////////
CServiceThread::CServiceThread(void)
{
	m_bRun=false;
	m_uThreadID=0;
	m_hThreadHandle=NULL;
}

CServiceThread::~CServiceThread(void)
{
	StopThread(INFINITE);
}

bool CServiceThread::IsRuning()
{
	if (m_hThreadHandle!=NULL)
	{
		DWORD dwRetCode=WaitForSingleObject(m_hThreadHandle,0);
		if (dwRetCode==WAIT_TIMEOUT) return true;
	}
	return false;
}

bool CServiceThread::StartThead()
{
	if (IsRuning()) return false;

	if (m_hThreadHandle!=NULL) 
	{
		CloseHandle(m_hThreadHandle);
		m_hThreadHandle=NULL;
		m_uThreadID=0;
	}

	tagThreadParameter ThreadParameter;
	ThreadParameter.bSuccess = false;
	ThreadParameter.m_pServiceThread = this;
	ThreadParameter.hEventFinish = CreateEvent(NULL,FALSE,FALSE,NULL);
	if (ThreadParameter.hEventFinish == NULL) return false;

	m_bRun=true;
	m_hThreadHandle=(HANDLE)::_beginthreadex(NULL,0,ThreadFunction,&ThreadParameter,0,&m_uThreadID);

	WaitForSingleObject(ThreadParameter.hEventFinish,INFINITE);

	CloseHandle(ThreadParameter.hEventFinish);

	if (ThreadParameter.bSuccess==false) 
	{
		StopThread();
		return false;
	}

	return true;
}

bool CServiceThread::StopThread(DWORD dwWaitSeconds)
{
	if (IsRuning()==true)
	{
		m_bRun=false;
		DWORD dwRetCode=WaitForSingleObject(m_hThreadHandle,dwWaitSeconds);
		if (dwRetCode==WAIT_TIMEOUT) return false;
	}

	if (m_hThreadHandle!=NULL)
	{
		CloseHandle(m_hThreadHandle);
		m_hThreadHandle=NULL;
		m_uThreadID=0;
	}

	return true;
}

bool CServiceThread::TerminateThread(DWORD dwExitCode)
{
	if (IsRuning()==true)
	{
		::TerminateThread(m_hThreadHandle,dwExitCode);
	}

	if (m_hThreadHandle!=NULL)
	{
		CloseHandle(m_hThreadHandle);
		m_hThreadHandle=NULL;
		m_uThreadID=0;
	}

	return true;
}

bool CServiceThread::PostThreadMessage(UINT uMessage, WPARAM wParam, LPARAM lParam)
{
	if (m_uThreadID==0) return false;

	BOOL bSuccess=::PostThreadMessage(m_uThreadID,uMessage,wParam,lParam);
	return bSuccess?true:false;
}

unsigned __stdcall CServiceThread::ThreadFunction(LPVOID pThreadData)
{
	tagThreadParameter * pThreadParameter=(tagThreadParameter *)pThreadData;
	CServiceThread * pThread=pThreadParameter->m_pServiceThread;

	srand((DWORD)time(NULL));

	try
	{
		pThreadParameter->bSuccess= pThread->OnThreadStratEvent();
	}
	catch(...)
	{ 
		pThreadParameter->bSuccess= false; 
	}

	bool bSuccess=pThreadParameter->bSuccess;
	SetEvent(pThreadParameter->hEventFinish);

	if(bSuccess == true)
	{
		while(pThread->m_bRun)
		{
			try
			{
				if(pThread->RepetitionRun() == false)
					break;
			}
			catch(...)
			{
			}
		}
	}

	try 
	{ 
		pThread->OnThreadStopEvent(); 
	} 
	catch(...) 
	{
	}

	_endthreadex(0);

	return 0;
}
//////////////////////////////////////////////////////////////////////////
