@setlocal
@echo off

set COMPDIR=%~dp0_COMP
set BINDIR=%~dp0bin

rd /q/s %COMPDIR%
rd /q/s %BINDIR%
