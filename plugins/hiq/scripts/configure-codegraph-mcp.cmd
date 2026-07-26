@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
set "ROOT=%~1"
if "%ROOT%"=="" set "ROOT=%CD%"
where py >nul 2>&1 && py -3 "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%" && exit /b %ERRORLEVEL%
where python >nul 2>&1 && python "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%" && exit /b %ERRORLEVEL%
where python3 >nul 2>&1 && python3 "%SCRIPT_DIR%lib\codegraph_mcp.py" "%ROOT%" && exit /b %ERRORLEVEL%
echo configure-mcp: Python required on Windows
exit /b 1
