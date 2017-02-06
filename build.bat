@setlocal
@echo off

set COMPDIR=%~dp0_COMP
set BINDIR=%~dp0bin
set T_LOGFILE=%COMPDIR%\comp.log
set ESTOOLNAME=es.exe

if not EXIST %BINDIR% mkdir %BINDIR%
rem rd /q/s %COMPDIR%
if not EXIST %COMPDIR% mkdir %COMPDIR%

echo Build "%ESTOOLNAME%" tool
IF not EXIST %BINDIR%\es.exe GOTO build_es_tool
echo - "%ESTOOLNAME%" tool is already available at %BINDIR%\%ESTOOLNAME%
goto build_commands
:build_es_tool
ecb -config %~dp0es_tools.ecf -target es_tools -finalize -c_compile -clean -project_path %COMPDIR% >> %T_LOGFILE%
copy /Y %COMPDIR%\EIFGENs\es_tools\F_code\es.exe %BINDIR%\%ESTOOLNAME%
echo - "%ESTOOLNAME%" tool copied under %BINDIR%\%ESTOOLNAME%
goto build_commands

:build_commands
echo Build commands
set CMDBINDIR=%~dp0bin\tools
if not EXIST %CMDBINDIR% mkdir %CMDBINDIR%
for /f %%f in ('dir /b %~dp0commands') do (call :get_command_f %%f)

goto end

:get_command_f
	set T_CMD_NAME=%1
	IF not EXIST %CMDBINDIR%\%T_CMD_NAME%.exe goto build_command_f
	echo - command "%T_CMD_NAME%.exe" already exists
	goto build_next_command

:build_command_f
	echo - command "%T_CMD_NAME%.exe": building ...
	ecb -config %~dp0commands\%T_CMD_NAME%\%T_CMD_NAME%.ecf -target %T_CMD_NAME% -finalize -c_compile -clean -project_path %COMPDIR%  >> %T_LOGFILE%
	copy /Y %COMPDIR%\EIFGENs\%T_CMD_NAME%\F_code\%T_CMD_NAME%.exe %CMDBINDIR%\%T_CMD_NAME%.exe
	echo - command "%T_CMD_NAME%.exe": copied to %CMDBINDIR%\%T_CMD_NAME%.exe .
	goto build_next_command

:build_next_command
	goto :eof

)
goto end

:end
endlocal
