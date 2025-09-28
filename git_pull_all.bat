@echo off && setlocal EnableDelayedExpansion
if "%~dp0" neq "!guid!\" (set "guid=%tmp%\crlf.%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "!guid!\%~nx0" (mkdir "!guid!" 2>nul & find "" /v<"%~f0" >"!guid!\%~nx0")) & call "!guid!\%~nx0" %* & rmdir /s /q "!guid!" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Apply 'git xxx' command on git subfolder tree, by wenuam 2022

rem 'git_xxx_all' -> 'git xxx' on all '*(\.git\config)' found

rem Set code page to utf-8 (/!\ this file MUST be in utf-8, BOM or not)
for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
chcp 65001>nul

rem Set "quiet" suffixes
set "quiet=1>nul 2>nul"
set "fquiet=/f /q 1>nul 2>nul"

rem Set look-up parameters
set "carg=/B /A:D /ON"
set "clst=.clst.txt"

set "crel=%cd%"
set "ccfg=.git\config"

echo; Current folder : %crel%
echo; Scanning git folders...

del "%clst%" %fquiet%
rem dir %carg% /S ".git">"!clst!"
(
	rem Current path
	if exist "%ccfg%" (
		echo %crel%
	)
	rem Subfolders (one level deep only)
	for /f %%r in ('dir %carg% "%crel%\*"') do (
		if exist "%%~fr\%ccfg%" (
			echo %%~fr
		)
	)
)>"!clst!"
rem !clst! contains only nicely filtered folder path (where %ccfg% exists)
echo;
REM	goto :eof

rem If git folders found
if exist "!clst!" (
	rem Get git 'xxx' command from batch file name ('git_xxx_all')
	for /f "delims=_ tokens=1,2*" %%i in ("%~n0") do (
		if "%%i"=="git" if "%%k"=="all" (
			set "vcmd=%%j"
		)
	)

	if not "!vcmd!"=="" (
		set "vout=!vcmd!"
		rem Set display in UPPERCASE
		for %%b in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "vout=!vout:%%b=%%b!"
		rem Set command in lowercase (because git is case sensitive)
		for %%b in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "vcmd=!vcmd:%%b=%%b!"
REM		echo TODO : !vcmd!

		rem For all paths found (yet not checked as valid)
		for /f "delims=" %%i in (!clst!) do (
REM			echo %%i
			set "vdir=%%i"
			rem Check if "valid"
			if exist "!vdir!\%ccfg%" (
				rem Change path to apply git command
				pushd "!vdir!"

				rem Replace starting path with '.\'
				call set "vdir=!vdir:%crel%=.\!"
				rem Display the working folder
				echo === GIT !vout! : !vdir! =========
				git !vcmd! -v
				echo;

				popd
			)
		)

		echo Done...

		rem Restore path
		cd /d "%~dp0"
	) else (
		echo No git command found...
	)

	rem Delete git folders list
	del "%clst%" %fquiet%
)

rem Restore code page
chcp %cp%>nul
