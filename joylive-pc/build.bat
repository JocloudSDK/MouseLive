@echo off

::ini work evn
cd /d %0\..\build

set configureTarget=configure.bat
set compileTarget=compile.bat
set packageTarget=package.bat

if "%1"=="" (
		goto build
	) else (
		goto %1
	)

	
:build
	call %configureTarget%
	if ERRORLEVEL 1 goto error
	call %compileTarget%
	if ERRORLEVEL 2 goto error
	call %packageTarget%
	goto exit

:configure
	call %configureTarget%
	goto exit

:compile
	call %compileTarget%
	goto exit

:package
	call %packageTarget%
	goto exit

:help 
	echo examples:
	echo     build(configure + compile + package):
	echo         build.bat 
	echo     configure depends data:
	echo         build.bat configure
	echo     comiple vc:
	echo         build.bat compile
	echo     make default setup.exe:
	echo         build.bat package
	echo target:
	echo     help
	echo     configure
	echo     compile
	echo     package

:error
	echo project build failed
	goto exit

:exit

