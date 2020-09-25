#include "OrangeFilterRender.h"
#include "stdio.h"
#include "pathutils.h"
#include <vector>
#include <mutex>
#include <algorithm>
#include "../../../common/log/loggerExt.h"
using namespace base;

static const char* TAG = "OrangeFilterRender";

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define ARRAY_LENGTH(arr) (sizeof(arr) / sizeof(arr[0]))

#define ORANGE_HELPER_CHECK() \
if (!m_orangeHelper) { \
	Logd(TAG, Log(__FUNCTION__).setMessage("m_orangeHelper is null")); \
	return false; \
}

std::recursive_mutex g_uiMutex;

OrangeFilterRender::OrangeFilterRender() :
m_quadVao(0),
m_quadVbo(0),
m_quadIbo(0),
m_copyProgram(0),
m_rewriteAlphaProgram(0),
m_tex_in(0),
m_tex_out(0),
m_tex_of_out(0),
m_fbo(0),
m_orangeHelper(NULL)
{
}

OrangeFilterRender::~OrangeFilterRender()
{
    if (m_orangeHelper)
	{
		delete m_orangeHelper;
		m_orangeHelper = NULL;
	}
}

void OrangeFilterRender::tearDown()
{
    if (m_tex_in)
    {
        glDeleteTextures(1, &m_tex_in);
        m_tex_in = 0;
    }

    if (m_tex_out)
    {
        glDeleteTextures(1, &m_tex_out);
        m_tex_out = 0;
    }

    if (m_tex_of_out)
    {
        glDeleteTextures(1, &m_tex_of_out);
        m_tex_of_out = 0;
    }

    if (m_quadVao)
    {
        glDeleteVertexArrays(1, &m_quadVao);
        m_quadVao = 0;
    }

    if (m_quadVbo)
    {
        glDeleteBuffers(1, &m_quadVbo);
        m_quadVbo = 0;
    }

    if (m_quadIbo)
    {
        glDeleteBuffers(1, &m_quadIbo);
        m_quadIbo = 0;
    }

    if (m_copyProgram)
    {
        glDeleteProgram(m_copyProgram);
        m_copyProgram = 0;
    }

    if (m_rewriteAlphaProgram)
    {
        glDeleteProgram(m_rewriteAlphaProgram);
        m_rewriteAlphaProgram = 0;
    }

    if (m_fbo)
    {
        glDeleteFramebuffers(1, &m_fbo);
        m_fbo = 0;
    }
}

void OrangeFilterRender::initQuad()
{
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
    float vertices[] = {
        -1, 1, 0, 0,
        -1, -1, 0, 1,
        1, -1, 1, 1,
        1, 1, 1, 0
    };

    glGenVertexArrays(1, &m_quadVao);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("1, glGetError() = %u", err));
	}
    glBindVertexArray(m_quadVao);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("2, glGetError() = %u", err));
	}

    glGenBuffers(1, &m_quadVbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("3, glGetError() = %u", err));
	}
    glBindBuffer(GL_ARRAY_BUFFER, m_quadVbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("4, glGetError() = %u", err));
	}
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("5, glGetError() = %u", err));
	}

    unsigned short indices[] = {
        0, 1, 2, 0, 2, 3
    };
    glGenBuffers(1, &m_quadIbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("6, glGetError() = %u", err));
	}
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_quadIbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("7, glGetError() = %u", err));
	}
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("8, glGetError() = %u", err));
	}

    glBindBuffer(GL_ARRAY_BUFFER, 0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("9, glGetError() = %u", err));
	}
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("10, glGetError() = %u", err));
	}
    glGenFramebuffers(1, &m_fbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("11, glGetError() = %u", err));
	}
    auto errorCode = glGetError();
    
}

void OrangeFilterRender::initCopyProgram()
{
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));

    const char* v = R"(
#version 120
uniform mat4 uMat;
attribute vec2 aPos;
attribute vec2 aUV;
varying vec2 vUV;
void main()
{
gl_Position = uMat * vec4(aPos, 0.0, 1.0);
vUV = aUV;
}
)";
    const char* f = R"(
#version 120
#ifdef GL_ES
    precision mediump float;
#endif
uniform sampler2D uTexture;
varying vec2 vUV;
void main()
{
vec4 rgbColor = texture2D(uTexture, vUV);
gl_FragColor = rgbColor;
}
)";

    GLuint vs = glCreateShader(GL_VERTEX_SHADER);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("1, glGetError() = %u", err));
	}
    glShaderSource(vs, 1, &v, OF_NULL);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("2, glGetError() = %u", err));
	}
    glCompileShader(vs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("3, glGetError() = %u", err));
	}

    int len = 0;
    glGetShaderInfoLog(vs, 0, &len, nullptr);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("4, glGetError() = %u", err));
	}
    if (len > 0)
    {
        std::string str;
        str.resize(len + 1);
        glGetShaderInfoLog(vs, str.size(), &len, &str[0]);
        Logd(TAG, Log(__FUNCTION__).setMessage("%s\n", str.c_str()));
    }

    GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("5, glGetError() = %u", err));
	}
    glShaderSource(fs, 1, &f, OF_NULL);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("6, glGetError() = %u", err));
	}
    glCompileShader(fs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("7, glGetError() = %u", err));
	}

    len = 0;
    glGetShaderInfoLog(fs, 0, &len, nullptr);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("8, glGetError() = %u", err));
	}
    if (len > 0)
    {
        std::string str;
        str.resize(len + 1);
        glGetShaderInfoLog(fs, str.size(), &len, &str[0]);
        Logd(TAG, Log(__FUNCTION__).setMessage("%s\n", str.c_str()));
    }

    m_copyProgram = glCreateProgram();
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("9, glGetError() = %u", err));
	}
    glAttachShader(m_copyProgram, vs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("10, glGetError() = %u", err));
	}
    glAttachShader(m_copyProgram, fs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("11, glGetError() = %u", err));
	}
    glLinkProgram(m_copyProgram);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("12, glGetError() = %u", err));
	}
    glDeleteShader(vs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("13, glGetError() = %u", err));
	}
    glDeleteShader(fs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("14, glGetError() = %u", err));
	}
}


void OrangeFilterRender::initRewriteAlphaProgram()
{
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));

    const char* v = R"(
#version 120
uniform mat4 uMat;
attribute vec2 aPos;
attribute vec2 aUV;
varying vec2 vUV;
void main()
{
gl_Position = uMat * vec4(aPos, 0.0, 1.0);
vUV = aUV;
}
)";
    const char* f = R"(
#version 120
#ifdef GL_ES
    precision mediump float;
#endif
uniform sampler2D uTexture;
varying vec2 vUV;
void main()
{
vec4 rgbColor = texture2D(uTexture, vUV);
gl_FragColor = vec4(rgbColor.rgb, 1.0);
}
)";

    GLuint vs = glCreateShader(GL_VERTEX_SHADER);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("1, glGetError() = %u", err));
	}
    glShaderSource(vs, 1, &v, OF_NULL);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("2, glGetError() = %u", err));
	}
    glCompileShader(vs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("3, glGetError() = %u", err));
	}

    int len = 0;
    glGetShaderInfoLog(vs, 0, &len, nullptr);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("4, glGetError() = %u", err));
	}
    if (len > 0)
    {
        std::string str;
        str.resize(len + 1);
        glGetShaderInfoLog(vs, str.size(), &len, &str[0]);
        Logd(TAG, Log(__FUNCTION__).setMessage("%s\n", str.c_str()));
    }

    GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("5, glGetError() = %u", err));
	}
    glShaderSource(fs, 1, &f, OF_NULL);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("6, glGetError() = %u", err));
	}
    glCompileShader(fs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("7, glGetError() = %u", err));
	}

    len = 0;
    glGetShaderInfoLog(fs, 0, &len, nullptr);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("8, glGetError() = %u", err));
	}
    if (len > 0)
    {
        std::string str;
        str.resize(len + 1);
        glGetShaderInfoLog(fs, str.size(), &len, &str[0]);
        Logd(TAG, Log(__FUNCTION__).setMessage("%s\n", str.c_str()));
    }

    m_rewriteAlphaProgram = glCreateProgram();
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("9, glGetError() = %u", err));
	}
    glAttachShader(m_rewriteAlphaProgram, vs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("10, glGetError() = %u", err));
	}
    glAttachShader(m_rewriteAlphaProgram, fs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("11, glGetError() = %u", err));
	}
    glLinkProgram(m_rewriteAlphaProgram);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("12, glGetError() = %u", err));
	}
    glDeleteShader(vs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("13, glGetError() = %u", err));
	}
    glDeleteShader(fs);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("14, glGetError() = %u", err));
	}
}

void OrangeFilterRender::drawQuad(GLuint intex, GLuint outtex, OFUInt32 width, OFUInt32 height, float* transform, GLuint currentProgram)
{
    int err1 = glGetError();
    if (err1 != 0)
    {
        Logd(TAG, Log(__FUNCTION__).setMessage("DrawQuad start  GL error %d\n", err1));
    }

    GLint oldFBO;
    GLint last_program;
    GLint last_texture;
    GLenum last_active_texture;
    bool ret = true;
    glGetIntegerv(GL_ACTIVE_TEXTURE, (GLint*)&last_active_texture);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("1, glGetError() = %u", err));
	}
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("2, glGetError() = %u", err));
	}
    
    glGetIntegerv(GL_CURRENT_PROGRAM, &last_program);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("3, glGetError() = %u", err));
	}
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("4, glGetError() = %u", err));
	}

    glBindFramebuffer(GL_FRAMEBUFFER, m_fbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("5, glGetError() = %u", err));
	}
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, outtex, 0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("6, glGetError() = %u", err));
	}
    glViewport(0, 0, width, height);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("7, glGetError() = %u", err));
	}
    glClearColor(0, 0, 0, 1);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("8, glGetError() = %u", err));
	}
    glClear(GL_COLOR_BUFFER_BIT);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("9, glGetError() = %u", err));
	}
    glDisable(GL_BLEND);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("10, glGetError() = %u", err));
	}
    glDisable(GL_SCISSOR_TEST);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("11, glGetError() = %u", err));
	}

    int loc;
    glUseProgram(currentProgram);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("12, glGetError() = %u", err));
	}
    GLboolean  ispro = glIsProgram(currentProgram);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("13, glGetError() = %u", err));
	}
    glActiveTexture(GL_TEXTURE0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("14, glGetError() = %u", err));
	}
    loc = glGetUniformLocation(currentProgram, "uTexture");
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("15, glGetError() = %u", err));
	}
    glUniform1i(loc, 0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("16, glGetError() = %u", err));
	}
    glBindTexture(GL_TEXTURE_2D, intex);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("17, glGetError() = %u", err));
	}

    loc = glGetUniformLocation(currentProgram, "uMat");
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("18, glGetError() = %u", err));
	}
    glUniformMatrix4fv(loc, 1, false, transform);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("19, glGetError() = %u", err));
	}

    glBindBuffer(GL_ARRAY_BUFFER, m_quadVbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("20, glGetError() = %u", err));
	}

    int locPos = glGetAttribLocation(currentProgram, "aPos");
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("21, glGetError() = %u", err));
	}
    glEnableVertexAttribArray(locPos);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("22, glGetError() = %u", err));
	}
    glVertexAttribPointer(locPos, 2, GL_FLOAT, GL_FALSE, 4 *sizeof(float), (void*)0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("23, glGetError() = %u", err));
	}
    
    int locUV = glGetAttribLocation(currentProgram, "aUV");
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("24, glGetError() = %u", err));
	}
    glEnableVertexAttribArray(locUV);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("25, glGetError() = %u", err));
	}
    glVertexAttribPointer(locUV, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)(sizeof(float) * 2));
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("26, glGetError() = %u", err));
	}

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_quadIbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("27, glGetError() = %u", err));
	}
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("28, glGetError() = %u", err));
	}

    glDisableVertexAttribArray(locPos);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("29, glGetError() = %u", err));
	}
    glDisableVertexAttribArray(locUV);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("30, glGetError() = %u", err));
	}

    glBindBuffer(GL_ARRAY_BUFFER, 0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("31, glGetError() = %u", err));
	}
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("32, glGetError() = %u", err));
	}
    glActiveTexture(last_active_texture);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("33, glGetError() = %u", err));
	}
    glBindTexture(GL_TEXTURE_2D, (GLuint)last_texture);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("34, glGetError() = %u", err));
	}
    glUseProgram(last_program);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("35, glGetError() = %u", err));
	}
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("36, glGetError() = %u", err));
	}
    
    glEnable(GL_BLEND);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("37, glGetError() = %u", err));
	}
    glEnable(GL_SCISSOR_TEST);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("38, glGetError() = %u", err));
	}
}

// https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glTexImage2D.xhtml
// glTexImage2D 部分机器 internalformat 不能传入 GL_BGRA
void OrangeFilterRender::updateTexture(OFUInt8 *frame, OFUInt32 width, OFUInt32 height)
{
    GLint last_texture;
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("1, glGetError() = %u", err));
	}

    if (0 == m_tex_in || 0 == m_tex_out || 0 == m_tex_of_out || width != m_width || height != m_height)
    {
        if ( m_tex_in)
        {
            glDeleteTextures(1, &m_tex_in);
            m_tex_in = 0;
        }

        if (m_tex_out)
        {
            glDeleteTextures(1, &m_tex_out);
            m_tex_out = 0;
        }

        if (m_tex_of_out)
        {
            glDeleteTextures(1, &m_tex_of_out);
            m_tex_of_out = 0;
        }

        glGenTextures(1, &m_tex_in);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("2, glGetError() = %u", err));
		}
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("3, glGetError() = %u", err));
		}
        glBindTexture(GL_TEXTURE_2D, m_tex_in);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("4, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("5, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("6, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("7, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("8, glGetError() = %u", err));
		}
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, m_tex_format, GL_UNSIGNED_BYTE, frame);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("9, glGetError() = %u", err));
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, frame);
			err = glGetError();
			Logd(TAG, Log(__FUNCTION__).setMessage("91, glGetError() = %u", err));
		}

        glGenTextures(1, &m_tex_out);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("10, glGetError() = %u", err));
		}
        glBindTexture(GL_TEXTURE_2D, m_tex_out);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("11, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("12, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("13, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("14, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("15, glGetError() = %u", err));
		}
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, m_tex_format, GL_UNSIGNED_BYTE, nullptr);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("16, glGetError() = %u", err));
		}

        glGenTextures(1, &m_tex_of_out);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("17, glGetError() = %u", err));
		}
        glBindTexture(GL_TEXTURE_2D, m_tex_of_out);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("18, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("19, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("20, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("21, glGetError() = %u", err));
		}
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("22, glGetError() = %u", err));
		}
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, m_tex_format, GL_UNSIGNED_BYTE, nullptr);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("23, glGetError() = %u", err));
		}
		glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("24, glGetError() = %u", err));
		}

        m_width = width;
        m_height = height;
    }
    else
    {
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("25, glGetError() = %u", err));
		}
        glBindTexture(GL_TEXTURE_2D, m_tex_in);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("26, glGetError() = %u", err));
		}
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, m_tex_format, GL_UNSIGNED_BYTE, frame);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("27, glGetError() = %u", err));
		}
		glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			Logd(TAG, Log(__FUNCTION__).setMessage("28, glGetError() = %u", err));
		}
    };
    // Restore state
    glBindTexture(GL_TEXTURE_2D, last_texture);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("29, glGetError() = %u", err));
	}
}

bool OrangeFilterRender::copyTextureToMemory(unsigned char* data, OFUInt32 width, OFUInt32 height,OFUInt32 fbo, GLuint texID)
{
    bool ret = true;
    GLint last_texture;
    GLint oldFrameBuffer;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFrameBuffer);
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);

	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("copyTexToMemry 1, glGetError() = %u", err));
		return false;
	}

    glViewport(0, 0, width, height);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("copyTexToMemry 2, glGetError() = %u", err));
		return false;
	}
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("copyTexToMemry 3, glGetError() = %u", err));
		return false;
	}
    glBindTexture(GL_TEXTURE_2D, texID);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("copyTexToMemry 4, glGetError() = %u", err));
		return false;
	}
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texID, 0);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("copyTexToMemry 5, glGetError() = %u", err));
		return false;
	}
    glReadPixels(0, 0, width, height, m_tex_format, GL_UNSIGNED_BYTE, data);
	err = glGetError();
	if (err != GL_NO_ERROR)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("copyTexToMemry 6, glGetError() = %u", err));
		return false;
	}
    glFinish();
    err = glGetError();
    if (err != GL_NO_ERROR)
    {
        Logd(TAG, Log(__FUNCTION__).setMessage("copyTexToMemry 7, glGetError() = %u", err));
        ret = false;
    }

    //Restore
    glBindTexture(GL_TEXTURE_2D, last_texture);
    glBindFramebuffer(GL_FRAMEBUFFER, oldFrameBuffer);
    return ret;
}

bool OrangeFilterRender::checkSerialNumber(const std::string& runDir, const std::string& serialNumber) {
	std::string licensePath;
	PathJoinA(licensePath, runDir, "of_offline_license.licence");

	m_orangeHelper = new OrangeHelper();
	bool ret = m_orangeHelper->createContext(serialNumber, licensePath, runDir);
	if (!ret)
	{
		Logd(TAG, Log(__FUNCTION__).setMessage("sdk init failed.\n"));
		return ret;
	}
	return ret;
}

void OrangeFilterRender::init()
{
    std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
    initQuad();
    initCopyProgram();
    initRewriteAlphaProgram();
}

bool OrangeFilterRender::unInit()
{
    std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
    tearDown();
	if (m_orangeHelper) {
		m_orangeHelper->destroyContext();
	}
    return true;
}

bool OrangeFilterRender::applyFrame(OFUInt8 *srcframe, OFUInt8 *dstframe, OFUInt32 width, OFUInt32 height, OrangeFilterRenderFormat srcformat)
{
	ORANGE_HELPER_CHECK();

    std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
    glBindVertexArray(m_quadVao);

	int tmpSrcFormat;
	if (srcformat == OrangeFilterRenderFormat::BGRA) {
		tmpSrcFormat = OF_PixelFormat_BGR32;
		m_tex_format = GL_BGRA;
	}
	else if (srcformat == OrangeFilterRenderFormat::RGBA) {
		tmpSrcFormat = OF_PixelFormat_RGB32;
		m_tex_format = GL_RGBA;
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("Format is error =="));
		return false;
	}

	updateTexture(srcframe, width, height);

	OrangeHelper::GLTexture texIn, texOut;
	texIn.textureId = m_tex_in;
	texIn.width = width;
	texIn.height = height;
	texIn.format = m_tex_format;
	texIn.target = GL_TEXTURE_2D;

	texOut.textureId = m_tex_of_out;
	texOut.width = width;
	texOut.height = height;
	texOut.format = m_tex_format;
	texOut.target = GL_TEXTURE_2D;

	OrangeHelper::ImageInfo image;
	memset(&image, 0, sizeof(image));
	image.data = srcframe;
	image.orientation = 0;
	image.width = width;
	image.height = height;
	image.format = tmpSrcFormat;
	image.frontCamera = 0;
	image.timestamp = 0;
	image.dir = 0;

	bool ret = m_orangeHelper->updateFrameParams(texIn, texOut, image);
	if (ret)
	{
		//this code for m_rewriteAlphaProgram.need this code because imgui enable GL_BLEND, it some out put modify src alpha may be influenced
		// so this pass and draw call rewrite alpha
		float flipY[] =
		{
			1.0f,  0.0f, 0.0f, 0.0f,
			0.0f, -1.0f, 0.0f, 0.0f,
			0.0f,  0.0f, 1.0f, 0.0f,
			0.0f,  0.0f, 0.0f, 1.0f,
		};

#if 0
		// alpha 通道会卡主
		drawQuad(m_tex_of_out, m_tex_out, width, height, flipY, m_rewriteAlphaProgram);
		glFinish();
		auto errorCode = glGetError();
		errorCode = errorCode;
		//If you need output pixel buffer then call this function
		copyTextureToMemory(dstframe, width, height, m_fbo, m_tex_out);
		glBindVertexArray(0);
#endif
		copyTextureToMemory(dstframe, width, height, m_fbo, m_tex_of_out);
		glBindVertexArray(0);
	}
	//else
	//{
	//	float identity[] =
	//	{
	//		1.0f, 0.0f, 0.0f, 0.0f,
	//		0.0f, 1.0f, 0.0f, 0.0f,
	//		0.0f, 0.0f, 1.0f, 0.0f,
	//		0.0f, 0.0f, 0.0f, 1.0f,
	//	};
	//	float flipY[] =
	//	{
	//		1.0f,  0.0f, 0.0f, 0.0f,
	//		0.0f, -1.0f, 0.0f, 0.0f,
	//		0.0f,  0.0f, 1.0f, 0.0f,
	//		0.0f,  0.0f, 0.0f, 1.0f,
	//	};
	//	//drawQuad(m_tex_in, m_tex_out, width, height, flipY, m_copyProgram);
	//	//If you need output pixel buffer then call this function
	//	//copyTextureToMemory(dstframe, m_width, m_height, m_fbo, m_tex_out);
	//}

	return true;
}

const GLuint OrangeFilterRender::getOutTextureID()
{
    std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
    return m_tex_out;
}

bool OrangeFilterRender::enableEffect(OrangeHelper::EffectType effectType, bool enabled)
{
	ORANGE_HELPER_CHECK();

	std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
	return m_orangeHelper->enableEffect(effectType, enabled);
}

bool OrangeFilterRender::enableSticker(const std::string& path, bool enabled)
{
	ORANGE_HELPER_CHECK();

	if (!doesFileExist(path)) {
		return false;
	}

	std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
	if (m_currentStickerPath != path)
	{
		m_orangeHelper->releaseSticker(m_currentStickerPath);
		m_currentStickerPath = path;
	}
	return m_orangeHelper->enableSticker(path, enabled);
}

bool OrangeFilterRender::releaseCurrentSticker() {
	ORANGE_HELPER_CHECK();

	std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
	auto ret = m_orangeHelper->releaseSticker(m_currentStickerPath);
	m_currentStickerPath = "";
	return ret;
}

bool OrangeFilterRender::enableGesture(const std::string& path, bool enabled) {
	ORANGE_HELPER_CHECK();

	if (!doesFileExist(path)) {
		return false;
	}

	std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
	auto it = std::find_if(m_currentGesturePath.begin(), m_currentGesturePath.end(),
		[&](const std::string& p) { return p == path; });
	if (it == m_currentGesturePath.end()) {
		m_currentGesturePath.emplace_back(path);
	}

	if (!enabled) {
		return m_orangeHelper->releaseGesture(path);
	}
	return m_orangeHelper->enableGesture(path, enabled);
}

void OrangeFilterRender::clearAllGesture() {
	if (!m_orangeHelper) {
			Logd(TAG, Log(__FUNCTION__).setMessage("m_orangeHelper is null"));
			return;
	}

	std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
	for (auto t = m_currentGesturePath.begin(); t != m_currentGesturePath.end(); t++) {
		m_orangeHelper->releaseGesture(*t);
	}
	m_currentGesturePath.clear();
}

int OrangeFilterRender::getEffectParam(OrangeHelper::EffectParamType paramType)
{
	if (!m_orangeHelper) {
		Logd(TAG, Log(__FUNCTION__).setMessage("m_orangeHelper is null"));
		return -1;
	}

	std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
	return m_orangeHelper->getEffectParam(paramType);
}

int OrangeFilterRender::getEffectParamDetail(OrangeHelper::EffectParamType paramType, OrangeHelper::EffectParam& paramVal)
{
	if (!m_orangeHelper) {
		Logd(TAG, Log(__FUNCTION__).setMessage("m_orangeHelper is null"));
		return -1;
	}

	std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
	return m_orangeHelper->getEffectParamDetail(paramType, paramVal);
}

bool OrangeFilterRender::setEffectParam(OrangeHelper::EffectParamType paramType, int value)
{
	ORANGE_HELPER_CHECK();

	std::lock_guard<std::recursive_mutex> lock(g_uiMutex);
	return m_orangeHelper->setEffectParam(paramType, value);
}

void OrangeFilterRender::clearAll() {

}
