//==========================================
// Matt Pietrek
// Microsoft Systems Journal, April 1997
// FILE: MSJEXHND.CPP
//==========================================  
#include <windows.h>
#include <DbgHelp.h>
#include "CCrashStack.h"
#include <dbghelp.h>
#include <shellapi.h>
#include <shlobj.h>
#pragma comment(lib, "dbghelp.lib")  

#include "msjexhnd.h"
#include <stdio.h>
#include <tchar.h>
#include <io.h>

#include <dbghelp.h>
#pragma comment(lib, "dbghelp.lib")

#include "../utils/String.h"
#include "../log/loggerExt.h"

using namespace base;

//============================== Global Variables =============================

//
// Declare the static variables of the MSJExceptionHandler class
//
LPTOP_LEVEL_EXCEPTION_FILTER g_PreviousFilter;
static std::string g_AppName;
//============================== Class Methods =============================

static const char* TAG = "msjexhnd";

long __stdcall MyUnhandledFilter(struct _EXCEPTION_POINTERS *lpExceptionInfo, const char* strFileName) {
	long ret = EXCEPTION_EXECUTE_HANDLER;

	HANDLE hFile = ::CreateFileA(strFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile != INVALID_HANDLE_VALUE) {
		MINIDUMP_EXCEPTION_INFORMATION ExInfo;
		ExInfo.ThreadId = ::GetCurrentThreadId();
		ExInfo.ExceptionPointers = lpExceptionInfo;
		ExInfo.ClientPointers = false;

		// write the dump
		BOOL bOK = MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), hFile, MiniDumpNormal, &ExInfo, NULL, NULL);
		::CloseHandle(hFile);
	}
	return ret;
}

static std::string getModuleDir() {
	HMODULE module = GetModuleHandle(0);
	TCHAR szCurrentDir[MAX_PATH] = { 0 };
	GetModuleFileName(module, szCurrentDir, sizeof(szCurrentDir));
	LPTSTR lpInsertPos = _tcsrchr(szCurrentDir, _T('\\'));
	int pos = lpInsertPos - (LPTSTR)(szCurrentDir);
	std::string path = ws2s(szCurrentDir);
	return path.substr(0, pos);
}

long __stdcall CrashLogCallback(_EXCEPTION_POINTERS* excp) {
  CCrashStack crashStack(excp);
  std::string strCrashInfo = crashStack.GetExceptionInfo();

  std::string file_path = getModuleDir();

  auto createLogDir = [&](std::string& path) {
		  // 1. Determine whether the log directory has been created, if not, do not create it
		  // 2. Create a directory
		  if (_access(path.c_str(), 0) == -1) {
			  if (::CreateDirectoryA(path.c_str(), NULL)) {
				  Logd(TAG, Log("createLogDir").setMessage("Dir path[%s] create OK!!!!", path.c_str()));
			  }
			  else {
				  Logd(TAG, Log("createLogDir").setMessage("Dir path[%s] create Failed!!!!", path.c_str()));
			  }
		  }
		  else {
			  Logd(TAG, Log("createLogDir").setMessage("Dir path[%s] is exist!!!!", path.c_str()));
		  }
  };
  file_path += "\\dmp";
  createLogDir(file_path);

  char szFileName[1024];
  SYSTEMTIME st;
  ::GetLocalTime(&st);
  sprintf_s(szFileName, "%s\\%s_%04d%02d%02d-%02d%02d%02d-%ld-%ld.dmp", file_path.c_str(), g_AppName.c_str(), st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, GetCurrentProcessId(), GetCurrentThreadId());

  MyUnhandledFilter(excp, szFileName);

  sprintf_s(szFileName, "%s\\%s_%04d%02d%02d-%02d%02d%02d-%ld-%ld.log", file_path.c_str(), g_AppName.c_str(), st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, GetCurrentProcessId(), GetCurrentThreadId());
  FILE* fp = fopen(szFileName, "ab+");
  if (fp) {
	  fwrite(strCrashInfo.c_str(), strCrashInfo.length(), 1, fp);
	  fclose(fp);
  }

  return   EXCEPTION_EXECUTE_HANDLER;
}

//=============
// Constructor 
//=============
MSJExceptionHandler::MSJExceptionHandler(const std::string& appName) {
	g_AppName = appName;
	g_PreviousFilter = SetUnhandledExceptionFilter(&CrashLogCallback);
}

//============
// Destructor 
//============
MSJExceptionHandler::~MSJExceptionHandler() {
    SetUnhandledExceptionFilter( g_PreviousFilter );
}

