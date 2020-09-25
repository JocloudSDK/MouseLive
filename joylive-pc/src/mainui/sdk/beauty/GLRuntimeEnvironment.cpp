#include "GLRuntimeEnvironment.h"
#include <iostream>
#include <assert.h>
#include "../../../common/log/loggerExt.h"
using namespace base;
static const char* TAG = "GLRuntimeEnvironment";

LRESULT WINAPI ESWindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    LRESULT  lRet = 1;
    return lRet;
}

void convertCharArrayToLPCWSTR(const char* charArray, wchar_t* outChars, int outCharsLen)
{
    MultiByteToWideChar(CP_ACP, 0, charArray, -1, outChars, outCharsLen);
}

bool WinCreate(HWND& _hWindow)
{
    WNDCLASSW wndclass = { 0 };
    DWORD    wStyle = 0;
    RECT     windowRect;
    HINSTANCE hInstance = GetModuleHandle(NULL);

    wndclass.style = CS_OWNDC;
    wndclass.lpfnWndProc = (WNDPROC)ESWindowProc;
    wndclass.hInstance = hInstance;
    wndclass.hbrBackground = (HBRUSH)COLOR_BACKGROUND;

    std::string className = "orangefilter";
    wchar_t w_className[128];
    convertCharArrayToLPCWSTR(className.c_str(), w_className, 128);
    wndclass.lpszClassName = w_className;

    if (!RegisterClassW(&wndclass))
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("RegisterClassW error"));
        return FALSE;
    }

    wStyle = WS_OVERLAPPEDWINDOW | WS_CLIPSIBLINGS | WS_CLIPCHILDREN;

    // Adjust the window rectangle so that the client area has
    // the correct number of pixels
    windowRect.left = 0;
    windowRect.top = 0;
    windowRect.right = CW_USEDEFAULT;
    windowRect.bottom = CW_USEDEFAULT;

    AdjustWindowRect(&windowRect, wStyle, FALSE);

    _hWindow = CreateWindowW(
        w_className,
        L"AREffect",
        wStyle,
        0,
        0,
        windowRect.right - windowRect.left,
        windowRect.bottom - windowRect.top,
        NULL,
        NULL,
        hInstance,
        NULL);

    if (_hWindow == NULL)
    {
		Logd(TAG, Log(__FUNCTION__).setMessage("_hWindow == null"));
        return false;
    }
    return true;
}

OF_Texture GLRuntimeEnvironment::CreateTexture(OFUInt8* data, OFUInt32 texformat, OFUInt32 width, OFUInt32 height, OFUInt32 piexlformat)
{
    OF_Texture texRGB;
    texRGB.target = GL_TEXTURE_2D;
    texRGB.format = texformat;
    texRGB.width = width;
    texRGB.height = height;

    glGenTextures(1, &texRGB.textureID);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("1, glGetError() = %u", err));
	}

    glBindTexture(GL_TEXTURE_2D, texRGB.textureID);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("2, glGetError() = %u", err));
	}
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("3, glGetError() = %u", err));
	}
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("4, glGetError() = %u", err));
	}
    glTexImage2D(GL_TEXTURE_2D, 0, texRGB.format, texRGB.width, texRGB.height, 0, piexlformat, GL_UNSIGNED_BYTE, data);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("5, glGetError() = %u", err));
	}
    return texRGB;
}

OF_Result GLRuntimeEnvironment::CopyTextureToMemory(OFUInt8* outData, const OF_Texture outTexRGB, OFUInt32 format)
{
    if (outData != NULL)
    {
        GLint oldFBO;
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
		GLenum err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("1, glGetError() = %u", err));
		}
        glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("2, glGetError() = %u", err));
		}
        if (outTexRGB.format == GL_DEPTH_COMPONENT)
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, outTexRGB.target, outTexRGB.textureID, 0);
        else
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, outTexRGB.target, outTexRGB.textureID, 0);
        
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("3, glGetError() = %u", err));
		}

		glReadPixels(0, 0, outTexRGB.width, outTexRGB.height, format, GL_UNSIGNED_BYTE, outData);
        err = glGetError();
        if (err != GL_NO_ERROR)
        {
			Logd(TAG, Log(__FUNCTION__).setMessage("4, glGetError() = %u", err));
            return OF_Result_Failed;
        }
        return OF_Result_Success;
    }
    return OF_Result_Failed;
}


OF_Result GLRuntimeEnvironment::TextureRelease(OF_Texture &texRGB)
{
    if (texRGB.textureID != 0)
    {
        glDeleteTextures(1, &texRGB.textureID);
        texRGB.textureID = 0;
    }
    return OF_Result_Success;
}


OF_Result GLRuntimeEnvironment::TextureUpdate(OFUInt8* srcData, OF_Texture &texRGB, OFUInt32 width, OFUInt32 height, OFUInt32 piexlformat)
{
    if (srcData != NULL)
    {
        glPixelStorei(GL_PACK_ALIGNMENT, 4);
		GLenum err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("1, glGetError() = %u", err));
		}
        glBindTexture(texRGB.target, texRGB.textureID);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("2, glGetError() = %u", err));
		}
		glTexSubImage2D(texRGB.target, 0, 0, 0, texRGB.width, texRGB.height, GL_BGRA, GL_UNSIGNED_BYTE, srcData);
        err = glGetError();
        if (err != GL_NO_ERROR)
        {
			Logd(TAG, Log(__FUNCTION__).setMessage("3, glGetError() = %u", err));
            return OF_Result_Failed;
        }

        return OF_Result_Success;
    }
    return OF_Result_Failed;
}

static void split(std::string& s, std::string& delim, std::vector<std::string>* ret) {
	size_t last = 0;
	size_t index = s.find_first_of(delim, last);
	while (index != std::string::npos) {
		ret->push_back(s.substr(last, index - last));
		last = index + 1;
		index = s.find_first_of(delim, last);
	}
	if (index - last > 0) {
		ret->push_back(s.substr(last, index - last));
	}
}

OF_Result GLRuntimeEnvironment::OFWindowInit()
{
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
    if (_hRC == OF_NULL)
    {
        HWND hWindow = OF_NULL;
        HGLRC hRC = OF_NULL;
        HDC hDC = OF_NULL;

        if (OF_NULL == hWindow)
        {
            if (!WinCreate(hWindow))
            {
				Logd(TAG, Log(__FUNCTION__).setMessage("WinCreate failed"));
                return OF_Result_Failed;
            }
        }

        hDC = ::GetDC(hWindow);

        if (hDC == NULL)
        {
			Logd(TAG, Log(__FUNCTION__).setMessage("hDC == null"));
            ::DestroyWindow(hWindow);
            hWindow = OF_NULL;
            ::UnregisterClassW(L"orangefilter", GetModuleHandle(NULL));
            return OF_Result_Failed;
        }

        int nPixelFormat;
        PIXELFORMATDESCRIPTOR pfd = {
            sizeof(PIXELFORMATDESCRIPTOR),	// Size of this structure
            1,								// Version of this structure	
            PFD_DRAW_TO_WINDOW |			// Draw to Window (not to bitmap)
            PFD_SUPPORT_OPENGL,
            PFD_TYPE_RGBA,					// RGBA Color mode
            32,								// Want 32 bit color 
            0, 0, 0, 0, 0, 0,			    // Not used to select mode
            0, 0,							// Not used to select mode
            0, 0, 0, 0, 0,                  // Not used to select mode
            16,								// Size of depth buffer
            0,								// Not used 
            0,								// Not used 
            0,	            				// Not used 
            0,								// Not used 
            0, 0, 0 };						// Not used 

        //
        // Choose a pixel format that best matches that described in pfd.
        //
        nPixelFormat = ChoosePixelFormat(hDC, &pfd);

        if (nPixelFormat == 0)
        {
            DWORD errorCode = GetLastError();
			Logd(TAG, Log(__FUNCTION__).setMessage("ChoosePixelFormat ErrorCode: %u", errorCode));

            ::ReleaseDC(hWindow, hDC);
            ::DestroyWindow(hWindow);
            return OF_Result_Failed;
        }

        //
        // Set the pixel format for the device context.
        //
        BOOL bSet = ::SetPixelFormat(hDC, nPixelFormat, &pfd);
        if (bSet == FALSE)
        {
			Logd(TAG, Log(__FUNCTION__).setMessage("SetPixelFormat failed"));
            ::ReleaseDC(hWindow, hDC);
            ::DestroyWindow(hWindow);
            return OF_Result_Failed;
        }

        //
        // Create OGL context and make it current.
        //
        hRC = ::wglCreateContext(hDC);
        if (hRC == NULL)
        {
            DWORD errorCode = GetLastError();
			Logd(TAG, Log(__FUNCTION__).setMessage("wglCreateContext ErrorCode: %u", errorCode));
            ::ReleaseDC(hWindow, hDC);
            ::DestroyWindow(hWindow);
            return OF_Result_Failed;
        }

        BOOL bMake = ::wglMakeCurrent(hDC, hRC);
        if (bMake == FALSE)
        {
            DWORD errorCode = ::GetLastError();
			Logd(TAG, Log(__FUNCTION__).setMessage("wglMakeCurrent ErrorCode: %u", errorCode));

            ::wglDeleteContext(hRC);
            ::ReleaseDC(hWindow, hDC);
            ::DestroyWindow(hWindow);
            return OF_Result_Failed;
        }

        GLenum err = glewInit();
        if (GLEW_OK != err)
        {
			Logd(TAG, Log(__FUNCTION__).setMessage("glewInit ErrorCode: %u", err));
            return OF_Result_Failed;
        }
        _hWindow = hWindow;
        _hRC = hRC;
        _hDC = hDC;
        int main_version, sub_version, release_version;
        const char* version = (const char*)glGetString(GL_VERSION);
		Logd(TAG, Log(__FUNCTION__).setMessage("Opengl version:%s", version));
        sscanf_s(version, "%d.%d.%d", &main_version, &sub_version, &release_version);
        if (main_version < 3)
        {
            if (version)
            {
				Logd(TAG, Log(__FUNCTION__).setMessage("Current OpenGL version not support OF, OpenGL version:%s", version));
            }
            return OF_Result_Failed;
        }

		// »ñÈ¡À©Õ¹
		std::string strExtString = (char*)glGetString(GL_EXTENSIONS);
		split(strExtString, std::string(" "), &_strVector);
		for (int i = 0; i < _strVector.size(); i++) {
			Logd(TAG, Log(__FUNCTION__).setMessage("strVector[%d] = %s", i, _strVector[i].c_str()));
		}

        glGetIntegerv(GL_FRAMEBUFFER_BINDING, (GLint *)&_defaultfbo);
        glGenFramebuffers(1, &_fbo);
    }

    GLenum  error = glGetError();
    assert(error != GL_INVALID_ENUM);

    return OF_Result_Success;
}

OF_Result GLRuntimeEnvironment::OFWindowUninit()
{
    if (_fbo != 0)
    {
        glDeleteFramebuffers(1, &_fbo);
        _fbo = 0;
    }

    ::wglMakeCurrent(NULL, NULL);
    if (_hRC)
    {
        ::wglDeleteContext(_hRC);
        _hRC = OF_NULL;
    }

    if (_hDC)
    {
        ::ReleaseDC(_hWindow, _hDC);
        _hDC = OF_NULL;
    }
    if (_hWindow)
    {
        ::DestroyWindow(_hWindow);
        _hWindow = OF_NULL;
        ::UnregisterClassW(L"orangefilter", GetModuleHandle(NULL));
    }
    return OF_Result_Success;
}

OFUInt32 GLRuntimeEnvironment::GetFBO()
{
    return _fbo;
}

OFUInt32 GLRuntimeEnvironment::GetDefaultFBO()
{
    return _defaultfbo;
}


bool GLRuntimeEnvironment::CheckOpenglSupport(std::string extName) {
	bool ret = false;
	for (int i = 0; i < _strVector.size(); i++) {
		if (_strVector[i] == extName) {
			ret = true;
			break;
		}
	}

	return ret;
}
