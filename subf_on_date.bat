@echo off && setlocal EnableDelayedExpansion && chcp 65001>nul
if "%~dp0" neq "!guid!\" (set "guid=%tmp%\crlf.%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "!guid!\%~nx0" (mkdir "!guid!" 2>nul & find "" /v<"%~f0" >"!guid!\%~nx0")) & call "!guid!\%~nx0" %* & rmdir /s /q "!guid!" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Sort files into created subfolders based on files' date (opt. filter on ext as parameter), by wenuam 2023

rem Change default helpers
set "quiet=1>nul 2>nul"
set "fquiet=/f /q 1>nul 2>nul"

rem Set look-up parameters
set "cext="
set "carg=/B /A:-D /ON"
set "clst=.%~n0.lst.txt"

rem echo Check parameter...
if not "%1"=="" (
	if exist "%~f1\*" (
		echo IS DIR
		set /a "vchk=2"
	) else if exist "%~f1" (
		echo IS FILE
		set /a "vchk=1"
		set "cext=%~x1"
	) else (
		echo NO THING
		set /a "vchk=0"
		set "cext=%~x1"
	)
) else (
	echo NO PARAM
)

REM	echo cext1=!cext!

rem Default extension
if "!cext!"=="" (
	set "cext=*"
)

REM	echo cext2=!cext!

if not "!cext!"=="" (
	if "!cext:~0,1!"=="." set "cext=!cext:~1!"

REM	echo cd="%cd%\*.!cext!"
	dir %carg% "%cd%\*.!cext!">"%clst%"

	rem Clean self name
	set "vnam=%~n0"
:clean_name
	if "!vnam:~0,1!"==" " ( set "vnam=!vnam:~1!" && goto clean_name )
	if "!vnam:~0,1!"=="_" ( set "vnam=!vnam:~1!" && goto clean_name )
	if "!vnam:~-1!"==" " ( set "vnam=!vnam:~0,-1!" && goto clean_name )
	if "!vnam:~-1!"=="_" ( set "vnam=!vnam:~0,-1!" && goto clean_name )
REM	echo vnam=!vnam!

	rem Exclude current file (always)
REM	findstr /i /v "%~nx0" "%clst%">"%clst%.sort"
	findstr /i /v ".*!vnam!.*%~x0" "%clst%">"%clst%.sort"
	if exist "%clst%.sort" (
		move /y "%clst%.sort" "%clst%"
	)

REM	pause
REM	goto :eof

	if exist "%clst%" (
		for /f "delims=" %%i in (%clst%) do (
REM			echo   Sorting %%~nxi... : %%~ti
			echo   ./%%~nxi

			for /f "tokens=1,2,3,4 delims=/ " %%a in ("%%~ti") do set "fdate=%%c%%b%%a"
			rem Remove millenary and century
			if "!fdate:~0,1!"=="2" set "fdate=!fdate:~1!"
			if "!fdate:~0,1!"=="0" set "fdate=!fdate:~1!"
REM			echo     fdate="!fdate!"

			set "fmove=%cd%\!fdate! - A"
REM			echo     fmove="!fmove!"

			if not "1"=="" if not "%%~nxi"=="%%~nx0" if not "%%~nxi"=="%clst%" (
				mkdir "!fmove!" %quiet%
				move /y "%%~fi" "!fmove!" %quiet%
			)
		)

REM		echo Delete list...
		del "%clst%" %fquiet%
	)
)
