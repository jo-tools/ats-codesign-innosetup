@ECHO OFF

REM ats-codesign.bat | Parameter %1: file-to-be-signed.exe
REM ******************************************************
REM
REM This batch script can be used from InnoSetup to
REM CodeSign using Azure Trusted Signing.
REM
REM InnoSetup is running under wine.
REM We now want to execute a Linux command: ats-codesign.sh
REM
REM The issue is that cmd /c start /wait will run asychronous :(
REM This .bat needs to wait until CodeSigning is really finished.
REM We do this by waiting for a file to be written by
REM ats-codesign-wine.sh

SET FILE="%*"
SET LookForFile="%FILE%.signed"
set cycles=................
set cntr=

REM Check if result exists (from a previous run)
IF EXIST %LookForFile% DEL %LookForFile%

REM Launch ats-codesign on Linux (asynchronous)
cmd /c start /wait /unix /usr/local/bin/ats-codesign-wine.sh "%FILE%"

:CheckForFile
IF EXIST %LookForFile% GOTO FoundIt

REM If we get here, the file is not found.
REM so let's wait a second and check again.
SET cntr=%cntr%.
IF "%cycles%"=="%cntr%" GOTO Cleanup

ping 192.0.2.1 -n 1 -w 2000 >nul

GOTO CheckForFile

:FoundIt
GOTO Cleanup

:Cleanup
REM remove temporary file
DEL %LookForFile%
