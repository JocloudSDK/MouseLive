#include "stdafx.h"
#include "Postman.h"
#include <atlstr.h>
#pragma comment(lib, "Wininet.lib")

CPostman::CPostman(LPCTSTR szUrl /* = NULL */, BYTE byHttpVerb/* = HTTP_GET*/, DWORD adwTimeOut/*=0*/)
{
    m_bAbort = FALSE;
    m_hSession = NULL;
    m_hConnect = NULL;
    m_hRequest = NULL;
	m_byHttpVerb = byHttpVerb;

	if (adwTimeOut == 0)
		m_dwTimeOut = HTTP_CONNECT_TIMEOUT;
	else
		m_dwTimeOut = adwTimeOut;

    if (szUrl != NULL)
    {
        Request(szUrl, m_byHttpVerb);
    }
}

CPostman::~CPostman()
{
    Destory();
}

void CPostman::Destory()
{
	if (NULL != m_hRequest) {
		InternetCloseHandle(m_hRequest);
		m_hRequest = NULL;
	}
	if (NULL != m_hConnect) {
		InternetCloseHandle(m_hConnect);
		m_hConnect = NULL;
	}
	if (NULL != m_hSession) {
		InternetCloseHandle(m_hSession);
		m_hSession = NULL;
	}
}


BOOL CPostman::Request(LPCTSTR szUrl, BYTE byHttpVerb)
{
	m_strUrl = szUrl;

    BOOL bResult = FALSE;
    while (TRUE)
    {
        std::wstring strHost;
		std::wstring strUrl;
		std::wstring strData;
		std::string strAData;
        WORD wPort;
		bool isHttps;
        BOOL bRes2 = ParseUrl(szUrl, strHost, wPort, strUrl, strData, byHttpVerb == VERB_POST, isHttps);
		if (!bRes2) {
			break;
		}

        // create Internet
        m_hSession = InternetOpen(NULL, INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, 0);
		if (m_hSession == NULL) {
			break;
		}

        // setting send timeout
		DWORD dwTimeout = m_dwTimeOut;
        bRes2 = InternetSetOption(m_hSession, INTERNET_OPTION_CONTROL_SEND_TIMEOUT, &dwTimeout, sizeof(DWORD));
		if (!bRes2) {
			break;
		}

		// setting connect timeout
		dwTimeout = m_dwTimeOut;
		bRes2 = InternetSetOption(m_hSession, INTERNET_OPTION_CONNECT_TIMEOUT, &dwTimeout, sizeof(DWORD));
		if (!bRes2) {
			break;
		}

        // connect to server
		m_hConnect = InternetConnect(m_hSession, strHost.c_str(), wPort, NULL, NULL, INTERNET_SERVICE_HTTP, 0, 1);
		if (m_hConnect == NULL) {
			break;
		}

        // open request
		m_hRequest = HttpOpenRequest(m_hConnect, byHttpVerb == VERB_GET?L"GET":L"POST", strUrl.c_str(), NULL, NULL, NULL, INTERNET_FLAG_RELOAD|(isHttps?INTERNET_FLAG_SECURE:0), 1);
		if (m_hRequest == NULL) {
			break;
		}

        // send request
		if(byHttpVerb == VERB_GET)
		{
			bRes2 = HttpSendRequest(m_hRequest, NULL, 0, NULL, 0);
		}
		else if(byHttpVerb == VERB_POST)
		{
			//char headerContentType[] = "Content-Type: application/x-www-form-urlencoded";
			char headerContentType[] = "Content-Type: application/json;charset=utf-8";
			HttpAddRequestHeadersA(m_hRequest, headerContentType, -1, HTTP_ADDREQ_FLAG_ADD|HTTP_ADDREQ_FLAG_REPLACE);
			strAData = CW2A(strData.c_str());
			bRes2 = HttpSendRequest(m_hRequest, NULL, 0, (LPVOID)strAData.c_str(), strAData.length());
		}
        
		if (!bRes2) {
			break;
		}

        bResult = TRUE;
        break;
    }

    if (!bResult)
    {
        Destory();
    }
    return bResult;
}

BOOL CPostman::Recive(std::string& data)
{
    char recvBuffer[MAX_INTERNET_READ_BUFFER];
    DWORD dwRecvBytes = 0;
    while (TRUE)
    {
		if (m_hRequest == NULL || m_bAbort) {
			break;
		}
       
        InternetReadFile(m_hRequest, recvBuffer, MAX_INTERNET_READ_BUFFER - 1, &dwRecvBytes);
		if (dwRecvBytes == 0) {
			break;
		}

        recvBuffer[dwRecvBytes] = '\0';
		data.append(recvBuffer, dwRecvBytes);
    }

    return !data.empty();
}

BOOL CPostman::ReciveBanary(char* buf, int& buflen)
{
	BOOL internetReadFile;
	char buffer[MAX_INTERNET_READ_BUFFER];
	memset(buffer, 0, sizeof(buffer));
	DWORD byteRead = 0;
	DWORD byteDown = 0;
	while (1)
	{
		internetReadFile = InternetReadFile(m_hRequest, buffer, sizeof(buffer), &byteRead);
		if (byteRead == 0)
		{
			break;
		}
		if (NULL != buf)
		{
			BOOL	lbThisDataError = (DWORD)buflen<byteRead?TRUE:FALSE;	// data check
			BOOL	lbTotalDataError = (DWORD)buflen<(byteDown+byteRead)?TRUE:FALSE;	// all data check
			if( lbThisDataError || lbTotalDataError )
				return FALSE;
			try
			{
				if (buflen == byteDown)
					break;
				memcpy_s(buf+byteDown, buflen - byteDown, buffer, byteRead);
			}
			catch (...)
			{
				InternetCloseHandle(m_hRequest);
				InternetCloseHandle(m_hConnect);
				return FALSE;
			}
		}
		byteDown += byteRead;
	}
	buflen = byteDown;
	InternetCloseHandle(m_hConnect);
	InternetCloseHandle(m_hRequest);
	return TRUE;
}

void CPostman::Abort()
{
    m_bAbort = TRUE;
}

BOOL CPostman::ParseUrl(std::wstring strUrl, std::wstring& strHost, WORD& wPort, std::wstring& strFile, std::wstring& strData, bool bParseData, bool& isHttps)
{
    if (strUrl.empty())
    {
        return FALSE;
    }

    TCHAR* HTTP_HEAD = L"http://";
	TCHAR* HTTPS_HEAD = L"https://";
	isHttps = false;
	std::wstring::size_type pos = (int)strUrl.find(HTTP_HEAD);
    if (pos != std::wstring::npos)
    {
        strUrl.erase(pos, wcslen(HTTP_HEAD));
    }
	else {
		std::wstring::size_type pos = (int)strUrl.find(HTTPS_HEAD);
		if (pos != std::wstring::npos)
		{
			strUrl.erase(pos, wcslen(HTTPS_HEAD));
			isHttps = true;
		}
	}

    pos = (int)strUrl.find(L"/");
    strHost = strUrl.substr(0, pos);
    strFile = strUrl.substr(pos + 1);
	if(bParseData)
	{
		pos = strFile.find(L"?");
		if (pos != std::wstring::npos)
		{
			strData = strFile;
			strFile = strFile.substr(0, pos);
			strData = strData.substr(pos + 1);
		}

	}
	
    pos = (int)strHost.find(L":");
    if (pos != std::wstring::npos)
    {
		std::wstring strPort = strHost.substr(pos + 1);
        wPort = _wtoi(strPort.c_str());
        strHost.erase(pos);
    }
    else
    {
		if (isHttps) {
			wPort = INTERNET_DEFAULT_HTTPS_PORT;
		}
		else {
			wPort = INTERNET_DEFAULT_HTTP_PORT;
		}
    }

    if (strHost.empty() || strFile.empty())
    {
        return FALSE;
    }
    return TRUE;
}
