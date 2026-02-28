@echo off
title Windows Provisioning Toolkit
color 0A

:: ==============================
:: Check for Administrator Rights
:: ==============================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit
)

:MENU
cls
echo =====================================
echo        Windows Provisioning Menu
echo =====================================
echo.
echo   1 - Install Updates Only
echo   2 - Install Applications Only
echo   3 - Full Provisioning Run
echo   4 - Export Software Inventory
echo   5 - Check Startup Update Status
echo   6 - Enable Automatic Updates at Startup
echo   7 - Disable Automatic Updates at Startup
echo   8 - Exit
echo.
set /p choice=Select option:

if "%choice%"=="1" goto UPDATES
if "%choice%"=="2" goto APPS
if "%choice%"=="3" goto FULL
if "%choice%"=="4" goto EXPORT
if "%choice%"=="5" goto STATUS
if "%choice%"=="6" goto AUTOSTART
if "%choice%"=="7" goto DISABLE
if "%choice%"=="8" exit

echo.
echo Invalid selection!
timeout /t 2 >nul
goto MENU


:UPDATES
cls
echo Running software updates...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsProvisioning.ps1" -Mode Updates
pause
goto MENU


:APPS
cls
echo Installing applications...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsProvisioning.ps1" -Mode Apps
pause
goto MENU


:FULL
cls
echo Running full provisioning...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsProvisioning.ps1" -Mode Full
pause
goto MENU


:EXPORT
cls
echo Exporting installed software inventory...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsProvisioning.ps1" -Mode Export
pause
goto MENU


:STATUS
cls
echo Checking startup task status...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsProvisioning.ps1" -Mode Status
pause
goto MENU


:AUTOSTART
cls
echo Enabling automatic updates at system startup...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsProvisioning.ps1" -Mode EnableStartup
pause
goto MENU


:DISABLE
cls
echo Disabling automatic startup updates...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WindowsProvisioning.ps1" -Mode DisableStartup
pause
goto MENU
