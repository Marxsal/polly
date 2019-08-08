@echo off && mode con:cols=105

:: START POWERSHELL SCRIPT: has to be in same directory as this batch file

   powershell -file .\polly.ps1 -run "auto" 
