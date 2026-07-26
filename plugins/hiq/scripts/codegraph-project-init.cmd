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
  set "BIN=%USERPROFILE%\.hiq\bin\codegraph.exe"
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
where py >nul 2>&1
if not errorlevel 1 (
  py -3 "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%"
  goto :mcp_done
)
where python >nul 2>&1
if not errorlevel 1 (
  python "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%"
  goto :mcp_done
)
where python3 >nul 2>&1
if not errorlevel 1 (
  python3 "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%"
  goto :mcp_done
)
echo hiq-cg-init: warn — no Python; writing portable mcp-liveagent.json via cmd
if not exist "%ROOT%\.hiq\graph" mkdir "%ROOT%\.hiq\graph"
if not exist "%ROOT%\.hiq\tools" mkdir "%ROOT%\.hiq\tools"
> "%ROOT%\.hiq\graph\mcp-liveagent.json" (
  echo {
  echo   "id": "codegraph",
  echo   "enabled": true,
  echo   "transport": "stdio",
  echo   "command": "codegraph",
  echo   "args": ["serve", "--mcp"],
  echo   "timeoutMs": 30000,
  echo   "hiq_portable": true
  echo }
)

:mcp_done
echo hiq-cg-init: done os=windows root=%ROOT% binary=%BIN%
exit /b 0
