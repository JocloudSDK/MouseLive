#pragma once
#include <windows.h>
//////////////////////////////////////////////////////////////////////////

/// Lock interface
interface IThreadLock
{
	virtual void Lock() = 0; 
	virtual void UnLock() = 0;
};

/// Thread interface
interface IThread
{
	/// whether the thread is running
	virtual bool IsRuning() = 0;
	
	/// strart thread
	virtual bool StartThead() = 0;

	/// stop thread
	virtual bool StopThread(DWORD dwWaitSeconds) = 0;
	
	/// terminate thread
	virtual bool TerminateThread(DWORD dwExitCode) = 0;
};

//////////////////////////////////////////////////////////////////////////
class CThreadLock : public IThreadLock
{
public:
	inline CThreadLock() { ::InitializeCriticalSection(&m_csLock); }
	inline ~CThreadLock() { ::DeleteCriticalSection(&m_csLock); }

	virtual inline void Lock() { ::EnterCriticalSection(&m_csLock); }
	virtual inline void UnLock() { ::LeaveCriticalSection(&m_csLock); }

private:
	CRITICAL_SECTION	m_csLock;
};

//////////////////////////////////////////////////////////////////////////
class CThreadLockHandle
{
public:
	CThreadLockHandle(IThreadLock* pIThreadLock,bool bAutoLock= true);
	virtual ~CThreadLockHandle();

public:
	void Lock();
	void UnLock();
	int inline GetLockCount() { return m_nLockCount; }

private:
	int				    m_nLockCount;
	IThreadLock*	m_pIThreadLock;
};

//////////////////////////////////////////////////////////////////////////
class CServiceThread : public IThread
{
protected:
	CServiceThread();
	virtual ~CServiceThread();

public:
	virtual bool	IsRuning();

	virtual bool	StartThead();

	virtual bool	StopThread(DWORD dwWaitSeconds =  INFINITE);

	virtual bool	TerminateThread(DWORD dwExitCode);

public:
	UINT	GetThreadID()	 { return m_uThreadID; }

	HANDLE	GetThreadHandle()	 { return m_hThreadHandle; }

	bool	PostThreadMessage(UINT uMessage,WPARAM wParam,LPARAM lParam);

private:
	virtual bool	OnThreadStratEvent()	{ return true; }

	virtual bool	OnThreadStopEvent()	 { return true; }

private:
	/// run function.  subclass implementation.
	/// [return] if false -- the thread exit; true -- run next
	virtual bool	RepetitionRun() = 0;

	/// thread function
	static unsigned __stdcall ThreadFunction(LPVOID pThreadData);

private:
	volatile bool	m_bRun;
	UINT			    m_uThreadID;	
	HANDLE			m_hThreadHandle;
};



//////////////////////////////////////////////////////////////////////////