@setlocal
@echo off

set COMPDIR=%~dp0_COMP
set BINDIR=%~dp0bin
if not EXIST %BINDIR% mkdir %BINDIR%
rem rd /q/s %COMPDIR%
if not EXIST %COMPDIR% mkdir %COMPDIR%

IF EXIST %BINDIR%\es_tools.exe GOTO build_commands
ecb -config %~dp0es_tools-safe.ecf -finalize -c_compile -clean -project_path %COMPDIR%
copy /Y %COMPDIR%\EIFGENs\es_tools\F_code\es.exe %BINDIR%
goto build_commands

:build_commands
set CMDBINDIR=%~dp0bin\tools
if not EXIST %CMDBINDIR% mkdir %CMDBINDIR%
for /f %%f in ('dir /b %~dp0commands') do (
	IF EXIST %CMDBINDIR%\%%f.exe echo %%f.exe already exists
	IF not EXIST %CMDBINDIR%\%%f.exe echo Build %%f
	IF not EXIST %CMDBINDIR%\%%f.exe ecb -config %~dp0commands\%%f\%%f-safe.ecf -finalize -c_compile -clean -project_path %COMPDIR%
	IF not EXIST %CMDBINDIR%\%%f.exe copy /Y %COMPDIR%\EIFGENs\%%f\F_code\%%f.exe %CMDBINDIR%
)
goto end

:end
endlocal
