@echo off

:: set global variable
set projectName=yymixer
set buildDir=%~dp0
set logDir=%buildDir%log
set appCfg=%workDir%..\app.config

if not exist %logDir% mkdir %logDir%

set buildoption=
if "%1"=="" (
		set buildtarget=release
	) else (
		if "%1"=="official" (
				set buildtarget=release
				set buildoption="DEFINES += OFFICIAL_BUILD"
			) else (
				set buildtarget=%1
			)
	)

if "%2"=="" (
		set z7tool=7z
	) else (
		set z7tool=%2
	)


if not "%VS140COMNTOOLS%"=="" (
    set "VS_COMMON_TOOLS=%VS140COMNTOOLS%"
	set "VS_PROJECT_VERSION=2015"
)    

if "%VS_COMMON_TOOLS%"=="" (
		set buildTool="msbuild"
	) else (
		set buildTool="%VS_COMMON_TOOLS%..\IDE\devenv.com"
	)

	