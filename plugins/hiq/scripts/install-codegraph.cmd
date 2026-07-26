@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM Install Cleboost/codegraph-rs on Windows (cmd). Prefer this over bash on Windows.
REM Usage: install-codegraph.cmd

set "REPO=Cleboost/codegraph-rs"
set "BIN_NAME=codegraph.exe"
set "SCRIPT_DIR=%~dp0"
set "HIQ_PLUGIN=%SCRIPT_DIR%.."
set "VERSION_FILE=%HIQ_PLUGIN%\vendor\codegraph-rs.version"
set "HIQ_USER_BIN=%USERPROFILE%\.hiq\bin"
set "HIQ_PLUGIN_BIN=%HIQ_PLUGIN%\bin"

if defined HIQ_BIN_DIR set "HIQ_USER_BIN=%HIQ_BIN_DIR%"

set "TAG="
if exist "%VERSION_FILE%" (
  set /p TAG=<"%VERSION_FILE%"
)
if "%TAG%"=="" set "TAG=v1.2.0"

REM Only x86_64 release published for Windows currently
set "TARGET=x86_64-pc-windows-msvc"
set "URL=https://github.com/%REPO%/releases/download/%TAG%/codegraph-%TARGET%.zip"

echo hiq-codegraph: os=windows target=%TARGET%
echo hiq-codegraph: downloading %URL%

set "TMPDIR=%TEMP%\hiq-cg-%RANDOM%"
mkdir "%TMPDIR%" >nul 2>&1

where curl >nul 2>&1
if errorlevel 1 (
  echo curl not found; try PowerShell Invoke-WebRequest fallback
  powershell -NoProfile -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%TMPDIR%\cg.zip'"
) else (
  curl -fsSL "%URL%" -o "%TMPDIR%\cg.zip"
)
if errorlevel 1 (
  echo download failed
  exit /b 1
)

powershell -NoProfile -Command "Expand-Archive -Path '%TMPDIR%\cg.zip' -DestinationPath '%TMPDIR%\out' -Force"
if errorlevel 1 (
  echo expand failed
  exit /b 1
)

set "SRC="
if exist "%TMPDIR%\out\codegraph.exe" set "SRC=%TMPDIR%\out\codegraph.exe"
if exist "%TMPDIR%\out\codegraph" set "SRC=%TMPDIR%\out\codegraph"
if "%SRC%"=="" (
  for /r "%TMPDIR%\out" %%F in (codegraph.exe) do (
    set "SRC=%%F"
    goto :found
  )
)
:found
if "%SRC%"=="" (
  echo binary not found in zip
  exit /b 1
)

if not exist "%HIQ_USER_BIN%" mkdir "%HIQ_USER_BIN%"
if not exist "%HIQ_PLUGIN_BIN%" mkdir "%HIQ_PLUGIN_BIN%"
copy /Y "%SRC%" "%HIQ_USER_BIN%\%BIN_NAME%" >nul
copy /Y "%SRC%" "%HIQ_PLUGIN_BIN%\%BIN_NAME%" >nul
echo hiq-codegraph: installed %TAG% -^> %HIQ_USER_BIN%\%BIN_NAME%
echo hiq-codegraph: installed %TAG% -^> %HIQ_PLUGIN_BIN%\%BIN_NAME%

if not exist "%HIQ_PLUGIN%\vendor" mkdir "%HIQ_PLUGIN%\vendor"
> "%HIQ_PLUGIN%\vendor\codegraph-rs.installed" echo %TAG%
> "%HIQ_PLUGIN%\vendor\codegraph-rs.meta" (
  echo repo=https://github.com/%REPO%
  echo tag=%TAG%
  echo target=%TARGET%
  echo os=windows
  echo user_bin=%HIQ_USER_BIN%\%BIN_NAME%
)

"%HIQ_USER_BIN%\%BIN_NAME%" --version
echo hiq-codegraph: add to USER PATH for portable MCP (command name codegraph):
echo   %HIQ_USER_BIN%
echo hiq-codegraph: done
rmdir /s /q "%TMPDIR%" >nul 2>&1
exit /b 0
