
call "E:\Qt\Qt5.9.9\5.9.9\msvc2015\bin\qtenv2.bat"

call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"

F:
cd F:\zhangjianping\2.work\joy\joy-pc\src

E:\Qt\Qt5.9.9\5.9.9\msvc2015\bin\qmake Joy.pro -spec win32-msvc

E:\Qt\Qt5.9.9\Tools\QtCreator\bin\jom.exe qmake_all

E:\Qt\Qt5.9.9\Tools\QtCreator\bin\jom.exe -f Makefile.Release
