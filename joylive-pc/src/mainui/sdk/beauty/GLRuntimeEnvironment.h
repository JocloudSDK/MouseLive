#pragma once
#include "orangefilter.h"
#include "GL/glew.h"
#include "GL/wglew.h"
#include <string>
#include <vector>

class GLRuntimeEnvironment {
public:
    GLRuntimeEnvironment()
       :_hWindow(OF_NULL),
        _hDC(OF_NULL),
        _hRC(OF_NULL),
        _fbo(0) {}

    ~GLRuntimeEnvironment() {}
    /**
    * Create window and init OpenGL environment
    */
    OF_Result OFWindowInit();

    /**
    * Destroy window and release OpenGL resource
    */
    OF_Result OFWindowUninit();

    /**
    * Create texture from pixel buffer
    * @param[in] data, image pixel buffer pointer
    * @param[in] texformat, format for create texture
    * @param[in] width, image width
    * @param[in] height, image height
    * @param[in] piexlformat, image format, just support RGB24 and RGBA32 right now, 
    * if in date is YUV, BGR24 or BGRA32 need using effect to convert format
    */
    OF_Texture CreateTexture(OFUInt8* data,         /* [in] */
        OFUInt32 texformat,                         /* [in] */
        OFUInt32 width,                             /* [in] */
        OFUInt32 height,                            /* [in] */
        OFUInt32 piexlformat);                      /* [in] */

    /**
    * Release texture 
    * @param[in] texRGB, release OF_Texture
    */
    OF_Result TextureRelease(OF_Texture &texRGB);    /* [in] */

    /**
    * Update texture
    * @param[in] srcData, image pixel buffer pointer
    * @param[in] texRGB, update texRGB texture by srcData
    * @param[in] width, image width
    * @param[in] height, image height
    * @param[in] piexlformat, image format, just support RGB24 and RGBA32 right now,
    * if in date is YUV, BGR24 or BGRA32 need using effect to convert format
    */
    OF_Result TextureUpdate(OFUInt8* srcData, 
        OF_Texture &texRGB, 
        OFUInt32 width, 
        OFUInt32 height, 
        OFUInt32 piexlformat);

    /**
    * Copy texture to memory
    * @param[out] outData, out image pixel buffer pointer
    * @param[in] outTexRGB, the texture which need to copy out
    * @param[in] format, outData's format
    */
    OF_Result CopyTextureToMemory(OFUInt8* outData,     /* [out] */
        const OF_Texture outTexRGB,                     /* [in] */
        OFUInt32 format);                               /* [in] */

    OFUInt32 GetFBO();
    OFUInt32 GetDefaultFBO();

	bool CheckOpenglSupport(std::string extName);

private:
     HWND _hWindow;
     HGLRC _hRC;
     HDC _hDC;
     GLuint _fbo;
     GLuint _defaultfbo;
	 std::vector<std::string> _strVector;
};

