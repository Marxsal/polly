:: polly-test-01j-TT.bat
@echo off && cls && mode con:cols=37 && setlocal 

  :: !! -- Launch this from the root directory of the Polly Test -- !!
  :: !! -- The .PS1 script will refuse to run if you don't -------- !!

:SETTINGS
  set "appAndVerTest=POLLY TEST v0.1j-TT"
  title %appAndVerTest%
  set "appAndVerTouch=POLLY TEST, BASICS v0.1j-TT"
  set "pollyAppTestDir=%~dp0\P\PollyApp"
  set "pollyAppTestLibDir=%~dp0\P\PollyApp\lib"
  set "fileExplorer=explorer.exe"

:PRELIM
  echo:
  echo   ^| %appAndVerTest%
  echo   ^| 
  echo   ^| Polly Test emulates a working 
  echo   ^| evironment with "wiki" in a 
  echo   ^| variety of folders.
  echo:
  echo   ^| First, it opens a file explorer
  echo   ^| in the Polly Test application 
  echo   ^| folder from where you can 
  echo   ^| launch Polly ("polly.bat").
  echo   ^|  
  echo   ^| Next, the "Polly Test" script
  echo   ^| starts.
  echo   ^| 
  echo   ^| It simulates saving to the 
  echo   ^| downloads folder by browsers.
  echo: 
  echo   ^| Ready to start? Press any
  echo   ^| key, or [Ctrl+C] to quit.
  echo:
  pause

:EXPLORER-LAUNCH
  start "%fileExplorer%" "%pollyAppTestDir%"

:START-TOUCHING
  :: Resize console & retitle
  mode con:cols=75 && title %appAndVerTouch%
  echo:
  echo %appAndVerTouch% is loading...

  :: Sequence of tests to check correct basic function of Polly
  powershell -executionpolicy bypass .\polly-test-basics.ps1  

  :: Complex script that can be tweaked to test complex cases (but its somewhat "noisy") 
  ::powershell -executionpolicy bypass .\polly-test-advanced.ps1  