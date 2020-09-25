::dwinternal
xcopy /y /e /i ..\3rd\Thunderbolt\bin\x86\*.dll ..\bin\release
xcopy /y /e /i "..\shadow\bin\release\joy.exe" ..\bin\release
xcopy /y /e /i "..\shadow\bin\release\joy.pdb" ..\bin\release
xcopy /y /e /i ..\3rd\Hummer\lib\Release_x86\*.dll ..\bin\release
xcopy /y /e /i ..\src\resource\skin\*.qss ..\bin\release\skin
xcopy /y /e /i ..\3rd\Beauty\venus_models\* ..\bin\release\venus_models
xcopy /y /e /i ..\3rd\Beauty\effects\* ..\bin\release\effects
xcopy /y /e /i ..\depends\dwinternal\orangefilterpub2013\bin\release\x86\*.dll ..\bin\release

@echo off
echo %BUILD_NUMBER%>..\bin\release\number.txt

set QTPath=%QT5_SETUP_HOME%\Qt5.9.9\5.9.9

if "%QT5_SETUP_HOME%"=="" (
	set QTPath=E:\Qt\Qt5.9.9\5.9.9
) else (
	set QTPath=%QT5_SETUP_HOME%\Qt5.9.9\5.9.9
)

:: 设置 QT 路径
::set QTPath=E:\Qt\Qt5.9.9\5.9.9
::set QTPath=%QT5_SETUP_HOME%\Qt5.9.9\5.9.9

:: 设置 QT env2 路径
set QTMsvc2015Path=%QTPath%\msvc2015\bin

:: copy qt5
xcopy /y /e /i "%QTMsvc2015Path%\Qt5Core.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\Qt5Widgets.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\Qt5Gui.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\Qt5WebSockets.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\Qt5Network.dll" ..\bin\release\
xcopy /y /e /i "%QTMsvc2015Path%\..\plugins\platforms\qwindows.dll" ..\bin\release\platforms\