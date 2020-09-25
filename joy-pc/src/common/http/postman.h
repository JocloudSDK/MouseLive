#pragma once
#include <Windows.h>
#include <WinInet.h>
#include "PostDefine.h"


class CPostman
{
public:
    CPostman(LPCTSTR szUrl = NULL, BYTE byHttpVerb = VERB_GET, DWORD adwTimeOut=0);
    ~CPostman();

    static BOOL ParseUrl(std::wstring strUrl, std::wstring& strHost, WORD& wPort, std::wstring& strFile, std::wstring& strData, bool bParseData, bool& isHttps);

	BOOL Request(LPCTSTR szUrl, BYTE byHttpVerb);
	
    BOOL Recive(std::string& data);

	BOOL ReciveBanary(char* buf, int& buflen);

    void Abort();
private:
	
    void Destory();
private:
    BOOL      m_bAbort;             /// abort flag
    HINTERNET m_hSession;    /// http session
    HINTERNET m_hConnect;    /// http connection
    HINTERNET m_hRequest;    /// http request
	DWORD     m_dwTimeOut;   /// timeout
	BYTE      m_byHttpVerb;       /// http type - POST or GET

	std::wstring m_strUrl;
};