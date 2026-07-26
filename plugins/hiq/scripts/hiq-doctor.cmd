@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
where bash >nul 2>nul
if errorlevel 1 (
  echo bash not found; cannot run hiq-doctor.sh
  exit /b 1
)
bash "%SCRIPT_DIR%hiq-doctor.sh" %*
exit /b %ERRORLEVEL%
