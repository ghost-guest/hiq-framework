@echo off
setlocal
REM Portable HiQ codegraph launcher (project-relative) for Windows cmd.
if defined HIQ_CODEGRAPH if exist "%HIQ_CODEGRAPH%" (
  "%HIQ_CODEGRAPH%" %*
  exit /b %ERRORLEVEL%
)
if exist "%USERPROFILE%\.hiq\bin\codegraph.exe" (
  "%USERPROFILE%\.hiq\bin\codegraph.exe" %*
  exit /b %ERRORLEVEL%
)
if exist "%USERPROFILE%\.hiq\bin\codegraph" (
  "%USERPROFILE%\.hiq\bin\codegraph" %*
  exit /b %ERRORLEVEL%
)
echo hiq-codegraph: binary not found. Run hiq-install / install-codegraph.cmd on this machine.
exit /b 127
