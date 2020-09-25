#ifndef CCRASHSTACK_H
#define CCRASHSTACK_H

#include <windows.h>
#include <string>

class CCrashStack
{
private:
  PEXCEPTION_POINTERS m_pException;

private:
  std::string GetModuleByRetAddr(PBYTE Ret_Addr, PBYTE& Module_Addr);
  std::string GetCallStack(PEXCEPTION_POINTERS pException);
  std::string GetVersionStr();
  bool GetHardwareInaformation(std::string& graphics_card, std::string& sound_deivce);

public:
  CCrashStack(PEXCEPTION_POINTERS pException);

  std::string GetExceptionInfo();
};

#endif // CCRASHSTACK_H

