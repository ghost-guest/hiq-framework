@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
where bash >nul 2>nul
if errorlevel 1 (
  echo bash not found; cannot run hiq-status.sh
  exit /b 1
)
bash "%SCRIPT_DIR%hiq-status.sh" %*
exit /b %ERRORLEVEL%
