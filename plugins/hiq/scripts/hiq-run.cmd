@echo off
REM Dispatcher: hiq-run.cmd <task> [args...]
REM tasks: install-codegraph | project-init | init-project | install-skills | configure-mcp | codegraph | hook | status | doctor | smoke
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"
set "TASK=%~1"
if "%TASK%"=="" (
  echo usage: hiq-run.cmd install-codegraph^|project-init^|init-project^|install-skills^|configure-mcp^|codegraph^|hook^|status^|doctor^|smoke [...]
  exit /b 2
)
shift
REM IMPORTANT: in cmd, SHIFT updates %1..%9 but does not rewrite %*.
REM Dispatch with the shifted numbered args directly so the task token is never
REM forwarded to the target script as an accidental root/path argument.
if /I "%TASK%"=="install-codegraph" (
  call "%SCRIPT_DIR%install-codegraph.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="project-init" (
  call "%SCRIPT_DIR%codegraph-project-init.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="init-project" (
  call "%SCRIPT_DIR%init-project.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="install-skills" (
  call "%SCRIPT_DIR%install-skills.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="configure-mcp" (
  call "%SCRIPT_DIR%configure-codegraph-mcp.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="codegraph" (
  call "%SCRIPT_DIR%codegraph.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="hook" (
  call "%SCRIPT_DIR%hiq-hook.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="status" (
  call "%SCRIPT_DIR%hiq-status.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="doctor" (
  call "%SCRIPT_DIR%hiq-doctor.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
if /I "%TASK%"=="smoke" (
  call "%SCRIPT_DIR%hiq-smoke.cmd" %1 %2 %3 %4 %5 %6 %7 %8 %9
  exit /b %ERRORLEVEL%
)
echo unknown task: %TASK%
exit /b 2
