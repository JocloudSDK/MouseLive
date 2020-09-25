@echo off

::ini work evn
set currentPath=%~dp0
cd %currentPath%

echo [info]build work dir: %currentPath%
::get_depend_data.py %depends_dir% %cfg_file%
python .\pytools\get_depend_data.py ..\depends .\config\depend2015.list
if ERRORLEVEL 1 exit /b 1