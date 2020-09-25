@echo off

:: set work dir:
set currentPath=%~dp0
set stringfile=%currentPath%\logfilter.list
echo %stringfile%

set log_file=%1


echo **********************************ERROR COUNT***********************************
findstr /i "项目: 个错误 个警告" %log_file%
findstr /i "Project: error(s) warning(s)" %log_file%
echo **********************************ERROR INFO***********************************
findstr /ig:%stringfile% %log_file%