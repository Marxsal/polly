@echo off && mode con:cols=85

:: START POWERSHELL SCRIPT -- has to be in same directory as this batch file

   powershell -file .\polly.ps1 -run once
