@echo off
REM Dispatcher: hiq-run.cmd <task> [args...]
REM tasks: install-codegraph | project-init | init-project | install-skills | configure-mcp | codegraph | status | doctor | smoke
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"
set "TASK=%~1"
if "%TASK%"=="" (
  echo usage: hiq-run.cmd install-codegraph^|project-init^|init-project^|install-skills^|configure-mcp^|codegraph^|status^|doctor^|smoke [...]
  exit /b 2
)
shift
set "FORWARD_ARGS="
:collect_args
if "%~1"=="" goto dispatch
set "FORWARD_ARGS=%FORWARD_ARGS% "%~1""
shift
goto collect_args

:dispatch
if /I "%TASK%"=="install-codegraph" (
  call "%SCRIPT_DIR%install-codegraph.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="project-init" (
  call "%SCRIPT_DIR%codegraph-project-init.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="init-project" (
  call "%SCRIPT_DIR%init-project.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="install-skills" (
  call "%SCRIPT_DIR%install-skills.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="configure-mcp" (
  call "%SCRIPT_DIR%configure-codegraph-mcp.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="codegraph" (
  call "%SCRIPT_DIR%codegraph.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="status" (
  call "%SCRIPT_DIR%hiq-status.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="doctor" (
  call "%SCRIPT_DIR%hiq-doctor.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="smoke" (
  call "%SCRIPT_DIR%hiq-smoke.cmd" %FORWARD_ARGS%
  exit /b %ERRORLEVEL%
)
echo unknown task: %TASK%
exit /b 2
