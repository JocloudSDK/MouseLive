@echo off

:: ini build evn
call buildenv.bat %1


:: 获取当前sln路径
set CurrentProjectPath=%buildDir%..\

:: 获取当前盘符
set CurrentPath=%~d0

:: 设置 QT 路径
::set QTPath=E:\Qt\Qt5.9.9\5.9.9

if "%QT5_SETUP_HOME%"=="" (
	set QTPath="D:\install\Qt\Qt5.9.9\5.9.9"
) else (
	set QTPath=%QT5_SETUP_HOME%\Qt5.9.9\5.9.9
)

:set QTPath=%QT5_SETUP_HOME%\Qt5.9.9\5.9.9

:: 设置 QT env2 路径
set QTMsvc2015Path=%qtPath%\msvc2015\bin

:: 设置 vs2015 vcvarsall.bat 路径
::set VS2015VcvarsallPath=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC
set VS2015VcvarsallPath=%VS140COMNTOOLS%..\..\VC

echo ====================================================================================================
echo CurrentProjectPath
echo %CurrentProjectPath%
echo CurrentPath
echo %CurrentPath%
echo QTPath
echo %QTPath%
echo QTMsvc2015Path
echo %QTMsvc2015Path%
echo VS2015VcvarsallPath
echo %VS2015VcvarsallPath%



echo ====================================================================================================
echo run qtenv2.bat
:: 执行环境命令
call %QTMsvc2015Path%\qtenv2.bat

echo ====================================================================================================
echo run vcvarsall.bat

call "%VS2015VcvarsallPath%\vcvarsall.bat"

echo ====================================================================================================
echo go CurrentPath = %CurrentProjectPath%

:: 重新进入路径
%CurrentPath%
cd %CurrentProjectPath%src

echo ====================================================================================================
echo compile

echo qmake Joy.pro -spec win32-msvc

call D:\install\Qt\Qt5.9.9\5.9.9\msvc2015\bin\qmake.exe Joy.pro -spec win32-msvc

echo jom.exe qmake_all

set QTCreate=%QTPath%..\Tools\QtCreator\bin

call D:\install\Qt\Qt5.9.9\Tools\QtCreator\bin\jom.exe qmake_all

echo jom.exe -f Makefile.Release

call D:\install\Qt\Qt5.9.9\Tools\QtCreator\bin\jom.exe -f Makefile.Release

echo ====================================================================================================
echo compile  end

if ERRORLEVEL 1 (
   call %buildDir%\genlog.bat %logFile%
   exit /b 22
   ) 

cd %buildDir%..\


cd %CurrentProjectPath%Build

xcopy /y /e /i ..\3rd\Hummer\lib\Release_x86\*.dll ..\bin\release
xcopy /y /e /i ..\3rd\Thunderbolt\bin\x86\*.dll ..\bin\release
xcopy /y /e /i "..\src\release\joy.exe" ..\bin\release
xcopy /y /e /i "..\src\release\joy.pdb" ..\bin\release
xcopy /y /e /i ..\src\resource\skin\*.qss ..\bin\release\skin
xcopy /y /e /i ..\3rd\Beauty\venus_models\* ..\bin\release\venus_models
xcopy /y /e /i ..\3rd\Beauty\effects\* ..\bin\release\effects
xcopy /y /e /i ..\depends\dwinternal\orangefilterpub2013\bin\release\x86\*.dll ..\bin\release

:: copy qt5
xcopy /y /e /i "%QTMsvc2015Path%\Qt5Core.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\Qt5Widgets.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\Qt5Gui.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\Qt5WebSockets.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\Qt5Network.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\..\plugins\platforms\qwindows.dll" ..\bin\release\platforms\

echo %BUILD_NUMBER%>..\bin\release\number.txt

exit /b ERRORLEVEL

