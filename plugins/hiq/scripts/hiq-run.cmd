@echo off
REM Dispatcher: hiq-run.cmd <task> [args...]
REM tasks: install-codegraph | project-init | configure-mcp | codegraph | status | doctor
setlocal
set "SCRIPT_DIR=%~dp0"
set "TASK=%~1"
if "%TASK%"=="" (
  echo usage: hiq-run.cmd install-codegraph^|project-init^|configure-mcp^|codegraph^|status^|doctor [...]
  exit /b 2
)
shift
if /I "%TASK%"=="install-codegraph" (
  call "%SCRIPT_DIR%install-codegraph.cmd" %*
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="project-init" (
  call "%SCRIPT_DIR%codegraph-project-init.cmd" %*
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="configure-mcp" (
  call "%SCRIPT_DIR%configure-codegraph-mcp.cmd" %*
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="codegraph" (
  call "%SCRIPT_DIR%codegraph.cmd" %*
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="status" (
  call "%SCRIPT_DIR%hiq-status.cmd" %*
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="doctor" (
  call "%SCRIPT_DIR%hiq-doctor.cmd" %*
  exit /b %ERRORLEVEL%
)
echo unknown task: %TASK%
exit /b 2
