#include "stdafx.h"
#include "Postoffice.h"
#include "Postman.h"

//#ifdef _DEBUG
//#define new DEBUG_NEW
//#undef THIS_FILE
//static char THIS_FILE[] = __FILE__;
//#endif

CPostoffice::CPostoffice()
{
    m_pNoticeFun = NULL;
    m_pNoticeObj = NULL;
    m_hNoticeWnd = NULL;
    m_dwNoticeMes = 0;
}

CPostoffice::~CPostoffice()
{
    m_pNoticeFun = NULL;
    m_pNoticeObj = NULL;
    m_hNoticeWnd = NULL;
    m_dwNoticeMes = 0;

	if (!this->IsRuning()) {
		this->StopThread(100);
	}
}

void CPostoffice::Request(LPCTSTR strRequest, UINT nType, BYTE byHttpVerb, HWND hwNotify)
{
	POST_CMD* pCmd = new POST_CMD;
	pCmd->byHttpVerb = byHttpVerb;
	pCmd->nCmdType = nType;
	pCmd->bResult = FALSE;
	pCmd->hWnd = hwNotify;
	pCmd->strRequest = strRequest;

	Request(pCmd);
}

void CPostoffice::DealRequest(POST_CMD* pCmd)
{
	if (pCmd == NULL)
	{
		return;
	}
		
	pCmd->dwTime = GetTickCount(); 
    CPostman man(pCmd->strRequest.c_str(), pCmd->byHttpVerb, 5000);	
    pCmd->bResult = man.Recive(pCmd->strRespond);
	pCmd->dwTime = GetTickCount() - pCmd->dwTime; 
    
    if (m_pNoticeFun != NULL)
    {
        m_pNoticeFun(m_pNoticeObj, pCmd);
    }
	else if (pCmd->hWnd != NULL)
	{
		::SendMessage(pCmd->hWnd, m_dwNoticeMes, (WPARAM)pCmd, NULL);
	}
    else if (m_hNoticeWnd != NULL)
    {
        ::SendMessage(m_hNoticeWnd, m_dwNoticeMes, (WPARAM)pCmd, NULL);
    }

	delete pCmd;
}

void CPostoffice::Request(POST_CMD* pCmd)
{
	{
		CThreadLockHandle lock(&mLock);
		mRequstQueue.push(pCmd);
	}

	if (!this->IsRuning()) {
		this->StartThead();
	}
}

void CPostoffice::SetNotice(HWND hWnd, DWORD dwMes)
{
    m_hNoticeWnd = hWnd;
    m_dwNoticeMes = dwMes;
}

void CPostoffice::SetNotice(FunNotice pFun, void* pObj)
{
    m_pNoticeFun = pFun;
    m_pNoticeObj = pObj;
}

bool CPostoffice::RepetitionRun()
{
	POST_CMD* pCmd = NULL;
	if (mRequstQueue.empty()) {
		return false;
	}

	{
		CThreadLockHandle lock(&mLock);
		pCmd = mRequstQueue.front();
		mRequstQueue.pop();
	}

	if (NULL != pCmd) 
	{
		DealRequest(pCmd);
	}
	
	return true;
}
