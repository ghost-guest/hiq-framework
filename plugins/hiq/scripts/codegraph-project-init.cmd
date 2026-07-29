@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM Windows (cmd) project CodeGraph init for hiq-init — non-interactive.
REM Usage: codegraph-project-init.cmd [project-root]

set "SCRIPT_DIR=%~dp0"
set "ROOT=%~1"
if "%ROOT%"=="" set "ROOT=%CD%"

REM Normalize root
pushd "%ROOT%" >nul 2>&1
if errorlevel 1 (
  echo hiq-cg-init: cannot cd to %ROOT%
  exit /b 1
)
set "ROOT=%CD%"
popd >nul

echo hiq-cg-init: os=windows root=%ROOT%

set "BIN=%HIQ_CODEGRAPH%"
if not defined BIN set "BIN=%USERPROFILE%\.hiq\bin\codegraph.exe"
if defined HIQ_BIN_DIR if not defined HIQ_CODEGRAPH set "BIN=%HIQ_BIN_DIR%\codegraph.exe"

if not exist "%BIN%" (
  echo hiq-cg-init: installing codegraph-rs...
  call "%SCRIPT_DIR%install-codegraph.cmd"
  if not defined HIQ_CODEGRAPH (
    if defined HIQ_BIN_DIR (
      set "BIN=%HIQ_BIN_DIR%\codegraph.exe"
    ) else (
      set "BIN=%USERPROFILE%\.hiq\bin\codegraph.exe"
    )
  )
)
if not exist "%BIN%" (
  echo hiq-cg-init: binary missing after install
  exit /b 1
)
echo hiq-cg-init: binary=%BIN%

REM init (ignore non-zero if .codegraph appears — agent UI needs TTY)
"%BIN%" init --path "%ROOT%"
if not exist "%ROOT%\.codegraph" (
  "%BIN%" init --no-index --path "%ROOT%"
)
if not exist "%ROOT%\.codegraph" (
  echo hiq-cg-init: FAILED — .codegraph not created
  exit /b 1
)

"%BIN%" index --path "%ROOT%"
"%BIN%" status --path "%ROOT%"

REM MCP wiring — portable (no absolute machine paths)
call "%SCRIPT_DIR%configure-codegraph-mcp.cmd" "%ROOT%"
if errorlevel 1 (
  echo hiq-cg-init: FAILED - portable MCP wiring failed
  exit /b 1
)

:mcp_done
where powershell >nul 2>&1
if errorlevel 1 (
  echo hiq-cg-init: warn - powershell not found; runtime-manifest.json not refreshed
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%lib\update_runtime_manifest.ps1" -Root "%ROOT%" -Bin "%BIN%"
)
echo hiq-cg-init: done os=windows root=%ROOT% binary=%BIN%
exit /b 0
