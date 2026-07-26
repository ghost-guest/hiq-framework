@echo off
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"
set "BIN=%HIQ_CODEGRAPH%"
if not defined BIN set "BIN=%USERPROFILE%\.hiq\bin\codegraph.exe"
if not exist "%BIN%" (
  call "%SCRIPT_DIR%install-codegraph.cmd"
  set "BIN=%USERPROFILE%\.hiq\bin\codegraph.exe"
)
if not exist "%BIN%" (
  echo hiq-codegraph: missing binary
  exit /b 127
)
"%BIN%" %*
exit /b %ERRORLEVEL%
