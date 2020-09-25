#ifndef __MSJEXHND_H__
#define __MSJEXHND_H__

#include <windows.h>
#include <string>

class MSJExceptionHandler
{
public:
	MSJExceptionHandler(const std::string& appName);
	~MSJExceptionHandler();
};

//  global instance of class

#endif
