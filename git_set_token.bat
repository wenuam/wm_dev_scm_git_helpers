@echo off && setlocal EnableDelayedExpansion EnableExtensions
if "%~dp0" neq "!guid!\" (set "guid=%tmp%\crlf.%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "!guid!\%~nx0" (mkdir "!guid!" 2>nul & find "" /v<"%~f0" >"!guid!\%~nx0")) & call "!guid!\%~nx0" %* & rmdir /s /q "!guid!" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Change git access token on subfolder tree, by wenuam 2022

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
set "curl=https://"
set "caut=oauth2:"
set "ctok=ghp_"

echo; Current folder: %crel%
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

rem If git command found
if exist "!clst!" (
	rem Get token if not provided as argument
	set "vtok=%~1"
	if "!vtok!"=="" (
		set /p vtok=Enter valid git access token ^(ghp_xxx^):
		echo;
	)

	if not "!vtok!"=="" (
		if "!vtok:~0,4!"=="!ctok!" (
			rem For all paths found (yet not checked as valid)
			for /f "delims=" %%i in (!clst!) do (
REM				echo %%i
				set "vdir=%%i"
				rem Check if "valid"
				if exist "!vdir!\%ccfg%" (
					rem Change path to apply git command
					pushd "!vdir!"

					rem Replace starting path with '.\'
					call set "vdir=!vdir:%crel%=.\!"
					rem Display the working folder
					echo === GIT SET TOKEN : !vdir! =========
					rem Get remote 'origin' url
					for /f %%u in ('git config --get remote.origin.url') do set "vurl=%%u"
					rem vurl=https://ghp_xxx@github.com/corp/repo.git
REM					echo vurl=!vurl!
					set "vpre="
					rem Strip protocol(https://) | auth(oauth2:) & token(ghp_) & @
					if "!vurl:~0,8!"=="!curl!" set "vurl=!vurl:~8!" & set "vpre=!curl!"
					if "!vurl:~0,7!"=="!caut!" set "vurl=!vurl:~7!" & set "vpre=!caut!"
					if "!vurl:~0,4!"=="!ctok!" set "vurl=!vurl:~40!"
					if "!vurl:~0,1!"=="@" set "vurl=!vurl:~1!"
					rem vurl=github.com/corp/repo.git
					if not "!vurl!"=="" (
						rem Set new token in 'origin'
						echo Remote "origin" = !vpre!!vurl!
						git remote set-url origin !vpre!!vtok!@!vurl!
						echo;
					)

					popd
				)
			)

			echo Done...
		) else (
			echo Invalid token...
		)

		rem Restore path
		cd /d "%crel%"
	) else (
		echo No token provided...
	)

	rem Delete git folders list
	del "%clst%" %fquiet%
)

rem Restore code page
chcp %cp%>nul
