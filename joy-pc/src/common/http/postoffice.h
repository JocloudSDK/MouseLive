#pragma once
#include "Postman.h"
#include "./common/thread/thread.h"
#include <queue>

typedef void (CALLBACK *FunNotice)(void* pObject, POST_CMD* pCmd);

class CPostoffice : public CServiceThread
{
public:
    CPostoffice();
    ~CPostoffice();

	//byHttpVerb 0:get 1 : post
	void Request(LPCTSTR strRequest, UINT nType, BYTE byHttpVerb, HWND hwNotify);

    void SetNotice(HWND hWnd, DWORD dwMes);

    void SetNotice(FunNotice pFun, void* pObj);

private:
	virtual bool RepetitionRun();

	void Request(POST_CMD* pCmd);

    void DealRequest( POST_CMD* pCmd);

private:
    FunNotice        m_pNoticeFun;                /// callback
    void*            m_pNoticeObj;                    /// callback usedata
    HWND             m_hNoticeWnd;               /// callback WND
    DWORD            m_dwNoticeMes;           /// callback notice

	std::queue<POST_CMD*> mRequstQueue;
	CThreadLock mLock;
};