# polly-test-basics-01k-TT.ps1

  cls
# SETTINGS ------------------------------------
  $appAndVerTouch = "POLLY TEST, BASICS v0.1k-TT"
  $console = $host.UI.RawUI
  $console.WindowTitle = "$appAndVerTouch"
  $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(160,5000)
  $console.ForegroundColor = "yellow"


# !! WARNING: ENSURE THIS SCRIPT **ONLY** RUNS IN THE TEST !!
  # See "CLAUSE 7" below to know why!
  cd "$PSscriptRoot" 
  $dummyDldDir = "P\Users\Polly\Downloads" 
  $dummyAppDir = "P\PollyApp"
  if(-not(test-path -path "$dummyDldDir")){
    echo ""
    echo "  | $appAndVerTouch" 
    echo "  | "   
    echo "  | !! Something is wrong !!"
    echo "  | "
    echo "  | The tests can ONLY run if..." 
    echo "  | "
    echo "  | ""$PSscriptRoot\P\Users\Polly\Downloads"""
    echo "  | "
    echo "  | ...exits. It doesn't!"
    echo "  | "
    echo "  | Press [Enter] to exit and consult a parrot about"
    echo "  | how to fix this problem."
    echo ""
    pause; cls; exit
  }
  cd "$dummyDldDir"
  # Address of PollyApp dir: used to locate settings.ini for deletion
  $dummyAppDir = "..\..\..\PollyApp"
  #gci "$dummyAppDir"
  #pause

# PRELIM --------------------------------------
  echo ""
  # PS version
  write-host "                       PowerShell:"$PsVersionTable.PSVersion
  # Polly prelim
  echo ""
  echo "           | $appAndVerTouch                    |"            
  echo "           |                                                |"
  echo "           | ""Who's a pretty Polly?  Who's a pretty Polly?"" |"
  echo "           |                                                |"
  echo "           |      --- Polly the mechanical parrot ---       !"
  echo ""
  echo "  | Polly Touch is a support script used in the test version of Polly."
  echo "  | "
  echo "  | It simulates ""Download Saving"" of browsers by creating files in"
  echo "  | a simulated download directory."
  echo "  | "
  echo "  | A series of tests are run to ensure that different features of " 
  echo "  | Polly are running correctly."
  echo "  |"
  echo "  | Once complete the tests can be restarted."

# TOUCH ---------------------------------------
  # Accepts piped input. If the file does not 
  # exist it is created.
  #
  # Options: (without option, changes both)
  #          "-only_modification" 
  #          "-only_access" 
  #          
  #  Source: ss64.com/ps/syntax-touch.html

function touch{
  param(
    [string[]]$paths,
    [bool]$only_modification = $false,
    [bool]$only_access = $false
  )

  begin {
    function updateFileSystemInfo([System.IO.FileSystemInfo]$fsInfo) {
      $datetime = get-date
      if ( $only_access )
      {
         $fsInfo.LastAccessTime = $datetime
      }
      elseif ( $only_modification )
      {
         $fsInfo.LastWriteTime = $datetime
      }
      else
      {
         $fsInfo.CreationTime = $datetime
         $fsInfo.LastWriteTime = $datetime
         $fsInfo.LastAccessTime = $datetime
       }
    }
   
    function touchExistingFile($arg) {
      if ($arg -is [System.IO.FileSystemInfo]) {
        updateFileSystemInfo($arg)
      }
      else {
        $resolvedPaths = resolve-path $arg
        foreach ($rpath in $resolvedPaths) {
          if (test-path -type Container $rpath) {
            $fsInfo = new-object System.IO.DirectoryInfo($rpath)
          }
          else {
            $fsInfo = new-object System.IO.FileInfo($rpath)
          }
          updateFileSystemInfo($fsInfo)
        }
      }
    }
   
    function touchNewFile([string]$path) {
      #$null > $path
      Set-Content -Path $path -value $null;
    }
  }
 
  process {
    if ($_) {
      if (test-path $_) {
        touchExistingFile($_)
      }
      else {
        touchNewFile($_)
      }
    }
  }
 
  end {
    if ($paths) {
      foreach ($path in $paths) {
        if (test-path $path) {
          touchExistingFile($path)
        }
        else {
          touchNewFile($path)
        }
      }
    }
  }
}

# CLAUSE 7: CLEAR DOWNLOADS & SETTINGS.NI -----
  function cleanup {
    # --- !! DELETES ALL FILES in test download directory and its sub-dirs
    #-Path C:\Temp -Include *.* -File -Recurse
    gci -path .\ -include *.* -file -recurse | remove-item
    # --- !! DELETE SETTINGS.INI
    remove-item  "$dummyAppDir\settings.ini"
  }

# CREATE DUMMY WIKI DOWNLOAD SAVES ------------
  $doTouch = "R"
  do {
    cleanup

    # --- TEST - CREATE SETTINGS.INI ----------
    echo ""
    echo "  | Test: SETTINGS.INI CREATION "
    echo ""
    echo "  | Polly Test deleted ""settings.ini"""
    echo "  | Lack of a settings.ini replicates first use,"
    echo "  | launching ""do-settings.ps1""."
    echo "  |"
    echo "  | Launch Polly using ANY PollyApp batch file to create it."
    echo "  |"
    echo "  | When done ..."
    echo ""
    pause
    echo ""

    # Begin: show "Downloads"
    echo ""
    echo "  | Download saving simulation is now ON "
    echo "  |"
    echo "  | So far no wikis have been downloaded to ""$dummyDldDir"""
    gci | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 

    echo "  | These are the wikis being tested on names & numbers ..."
    echo "  |"
    echo "  | P\tw-wikidir\tricky\ (latest first) ..."
    gci -file ..\..\..\tw-wikidir\tricky\tricky*.* | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 

    # -- TEST 1 -------------------------------
    echo "  | Test 1: Basic NAMES & NUMBERS -------------------------"
    echo "  |           "
    echo "  | Compare download saves in: ""P\Users\Polly\Downloads\"" "; 
    echo "  |              ... with ..."
    echo "  |               Restores in: ""P\tw-wikidir\tricky\"""; 
    echo "  |"; echo ""
    echo "Wait, creating 2 downloads for 7 wiki ..."; echo ""
 
    # tricky
    touch "tricky-test.html"     ; add-content -path .\tricky-test.html -value "I am: tricky-test.html"
    touch "tricky.polly"         ; add-content -path .\tricky.polly     -value "I am: tricky.polly"
    touch "tricky.html"          ; add-content -path .\tricky.html      -value "I am: tricky.html"
    touch "tricky.htm"           ; add-content -path .\tricky.htm       -value "I am: tricky.htm"
    touch "tricky.tw"            ; add-content -path .\tricky.tw        -value "I am: tricky.tw"
    touch "tricky(SUCCEED).html" ; add-content -path ".\tricky(SUCCEED).html"          -value "I am: tricky(SUCCEED).html"
    touch "tricky-accounts(2019).htm"; add-content -path ".\tricky-accounts(2019).htm" -value "I am: tricky-accounts(2019).htm"
      start-sleep -seconds 10  
    touch "tricky-test(2).html" ; add-content -path ".\tricky-test(2).html"  -value "I am: tricky-test(2).html"
    touch "tricky (2).polly"    ; add-content -path ".\tricky (2).polly"     -value "I am: tricky (2).polly"
    touch "tricky (2).html"     ; add-content -path ".\tricky (2).html"      -value "I am: tricky (2).html"
    touch "tricky (2).htm"      ; add-content -path ".\tricky (2).htm"       -value "I am: tricky (2).htm"
    touch "tricky (2).tw"       ; add-content -path ".\tricky (2).tw"        -value "I am: tricky (2).tw"
    touch "tricky(SUCCEED) (2).html" ; add-content -path ".\tricky(SUCCEED) (2).html"          -value "I am: tricky(SUCCEED) (2).html"
    touch "tricky-accounts(2019) (2).htm"; add-content -path ".\tricky-accounts(2019) (2).htm" -value "I am: tricky-accounts(2019) (2).htm"

    echo "  | Downloads (latest first) ..."
    gci -file tricky*.*| sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 
    echo "  | SWITCH to the PollyApp directory & RUN ""t_basics-once.bat"" " 
    echo "  |"
    echo "  | When complete press [Enter] to list ""restored"" files"
    echo "  |"
    echo "  | Compare ""write"" times & sizes between the directories " 
    echo "  | to ensure correct restore is occuring"
    echo "" 
      pause
    echo ""
    echo "  | P\tw-wikidir\tricky\ (latest first) ..."
    gci -file ..\..\..\tw-wikidir\tricky\tricky*.* | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 
      pause

    # -- TEST 2 -------------------------------
    echo ""; echo ""
    echo "  | Test 2: Advanced NAMES & NUMBERS ----------------------"
    echo "  |           "
    echo "  | Compare download saves in: ""P\Users\Polly\Downloads\"" "; 
    echo "  |              ... with ..."
    echo "  |               restores in: ""P\tw-wikidir\tricky\"""; 
    echo "  |"; echo ""
    echo "Wait, creating 1 download for 7 wiki ..."; echo ""
 
    # tricky
    touch "tricky-test(2)  (4).html"  
    touch "tricky (2)(9).polly"       
    touch "tricky (2)  (700).html" 
    touch "tricky (2) (8)    (9) (30).tw" 
    touch "tricky (2) (FAIL).htm" 
    touch "tricky-accounts(2019) (3).htm"
    touch "tricky(SUCCEED) (7) (46)(91).html" 

      # basic parrots for Test 4
      touch "parrot-green.html"    
      touch "parrot-red.html"  

    echo "  | Downloads (latest first) ..."
    gci -file tricky*.*| sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 
    echo "  | SWITCH to the PollyApp directory & RUN ""t_basics-once.bat"" " 
    echo "  |"
    echo "  | When complete press [Enter] to list ""restored"" files"
    echo "  |"
    echo "  | Compare ""write"" times between the directories to ensure" 
    echo "  | correct restore is occuring ..." 
    echo "  |"
    echo "  |   - ""tricky (2) (FAIL).htm"" should fail"
    echo "  |   - ""tricky(SUCCEED) (7) (46)(91).html"" should succeed"
    echo "  |   - ""tricky-accounts(2019) (3).htm"" should succeed" 
    echo ""
      pause
    echo ""
    echo "  | P\tw-wikidir\tricky\ (latest first) ..."
    gci -file ..\..\..\tw-wikidir\tricky\tricky*.* | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 
      pause

    # -- TEST 3 -------------------------------
    echo ""; echo ""
    echo "  | Test 3: BACKUPS & ZIP ARCHIVES ------------------------"
    echo "  |           "
    echo "  | Wikis in: ""P\tw-wikidir\tricky\"""; 
    echo "  |           backups & zip archives"
    echo "  | "
    echo "  | Both backups & zip-archives should be one generation behind"; 
    echo "  | the current wiki. To see the previous generation times scroll"
    echo "  | up to Test 1 results"
    echo ""

    # backups & zipped
    echo "  | P\Users\Polly\Downloads\tw_backups\wikis\ (latest for each wiki) ..."
    #gci -file .\tw_backups\wikis\tricky*.*  | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 
    echo ""
    gci -path .\tw_backups\wikis  *.* -recurse | where {$_.psiscontainer} | foreach {get-childitem $_.fullname | sort LastWriteTime | select -expand name -last 1}
    echo ""
    echo "  | P\Users\Polly\Downloads\tw_backups\zipped\ (latest for each wiki) ..."
    #gci -file .\tw_backups\zipped\tricky*.* | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders;
    echo ""
    gci -path .\tw_backups\zipped *.* -recurse | where {$_.psiscontainer} | foreach {get-childitem $_.fullname | sort LastWriteTime | select -expand name -last 1} 
    echo ""
      pause

    # -- TEST 4 -------------------------------
    echo ""; echo ""
    echo "  | Test 4: BASIC PAROTTING -------------------------------"
    echo "  |           "
    echo "  |          Wikis in: ""P\tw-wikidir\parrot\"""; 
    echo "  |  ... parroted ..."
    echo "  |                to: ""P\tw-sites\www.polly.net\"""; 
    echo "  |"
    echo "  | Files should be identical ..."; 
    echo ""
    echo ""
      
    # touch for parrotted files is in Test 2
    echo "  | Downloads (latest first) ..."
    gci -file parrot*.*| sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 
    echo "  |   Wikis: P\tw-wikidir\parrot\ ..."
    gci -file ..\..\..\tw-wikidir\parrot\*.* | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 
    echo "  | Parrots: P\tw-sites\www.polly.net\ ..."  
    gci -file ..\..\..\tw-sites\www.polly.net\*.* | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 

    # -- TEST 5 -------------------------------
    #echo ""; echo ""
    #echo "  | Test 5: Advanced PAROTTING ----------------------------"
    #echo "  |"   

    # -- TEST 6 -------------------------------
    #echo ""; echo ""
    #echo "  | Test 6: PORTABILITY -----------------------------------"
    #echo "  |" 

    # -- RESTART? -----------------------------          
    $doTouch = Read-Host "? | [R] to restart tests. Any other key to quit"
  } 
  while ($doTouch -eq "R")
  cls; exit
  