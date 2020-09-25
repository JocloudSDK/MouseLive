#pragma once

#include <windows.h>
#include <string>

// http timeout setting, 10s
const DWORD HTTP_CONNECT_TIMEOUT = 10000;        
const DWORD MAX_INTERNET_READ_BUFFER = 1024*10;


enum HTTP_VERB
{
	VERB_GET,
	VERB_POST
};

//////////////////////////////////////////////////////////////////////////
/// POST request struct
struct POST_CMD
{
    UINT    nCmdType;		   /// request type
	BYTE	byHttpVerb;		   /// 0:Get 1:Post
    BOOL    bResult;		       /// request result
    HWND    hWnd;			   /// notifiation WND
    std::wstring strRequest;  /// request body
	std::string strRespond;    /// response body
	DWORD   dwTime;			/// request time
};

#define WM_HTTP_CMD         (WM_USER + 1001)

