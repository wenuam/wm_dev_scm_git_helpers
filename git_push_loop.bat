@echo off && setlocal EnableDelayedExpansion

rem Retry 'git push' until it works, by wenuam 2022

rem Used when many/large files are pushed (random timeout might occurs)
rem Mostly when using a 'slow' connection ('slow' by git standard)

REM	fatal: The remote end hung up unexpectedly

rem Try the following commands as well:
REM	git config --global core.compression 9
REM	git config --global http.lowSpeedLimit 0
REM	git config --global http.lowSpeedTime 999999
REM	git config --global http.postBuffer 524288000
REM	git config --global ssh.postBuffer 524288000
REM	set GIT_HTTP_MAX_REQUEST_BUFFER=100M

rem Reset counter
set /a tries=0

:repeat
rem Display current time
set /a tries+=1
echo === GIT PUSH : %tries% @ %time% ===========================================
rem Loop if it fails
(git push) || goto :repeat

rem Print number of times it tried
echo; %time% : Success! (tried %tries% times)
echo;

rem You may want to request user input before exiting
REM	pause
