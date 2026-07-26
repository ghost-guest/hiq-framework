@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
set "ROOT=%~1"
if "%ROOT%"=="" set "ROOT=%CD%"
where py >nul 2>&1 && py -3 "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%" && exit /b %ERRORLEVEL%
where python >nul 2>&1 && python "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%" && exit /b %ERRORLEVEL%
where python3 >nul 2>&1 && python3 "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%" && exit /b %ERRORLEVEL%
where powershell >nul 2>&1 && powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%lib\configure_codegraph_mcp.ps1" -Root "%ROOT%" && exit /b %ERRORLEVEL%
echo configure-mcp: Python or PowerShell required on Windows
exit /b 1
