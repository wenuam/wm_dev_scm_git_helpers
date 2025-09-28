@echo off

rem Open certificate management dialog

start "" rundll32.exe keymgr.dll,KRShowKeyMgr
