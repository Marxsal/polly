# polly-test-advanced-01j-TT.ps1

  cls
# SETTINGS ------------------------------------
  $appAndVerTouch = "POLLY TEST, ADVANCED v0.1j-TT"
  $console = $host.UI.RawUI
  $console.WindowTitle = "$appAndVerTouch"
  $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(160,5000)
  $console.ForegroundColor = "yellow"


# !! WARNING: ENSURE THIS SCRIPT **ONLY** RUNS IN THE TEST !!
  # See "CLAUSE 7" below to know why!
  cd "$PSscriptRoot"; $dummyDldDir = "P\Users\Polly\Downloads"; 
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

# PRELIM --------------------------------------
  echo ""
  # PS version
  write-host "                       PowerShell:"$PsVersionTable.PSVersion
  # Polly prelim
  echo ""
  echo "           | $appAndVerTouch                           |"            
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
  echo "  | Each ""cycle"" of the tool creates (dummy) wiki. There are 3" 
  echo "  | cycles. The first cycle starts immediatly. The next 2 cycles are"
  echo "  | started by pressing [Enter]."
  echo "  |"
  echo "  | Once complete the simulation can be restarted."

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

# CLAUSE 7: CLEAR DOWNLOADS -------------------
  function cleanup {
    # --- !! DELETES ALL FILES in test download directory and its sub-dirs
    gci * -include *.* -recurse | remove-item
  }


# CREATE DUMMY WIKI DOWNLOAD SAVES ------------
  $doTouch = "R"
  do {
    cleanup #; pause

    # Begin: show "wiki"
    echo "  |"
    echo "  | These are the wiki in the test ..."
    echo ""
    gci -path ..\..\..\..\P -recurse | where {$_.extension -like ".htm*" -or $_.extension -like ".tw" -or $_.extension -like ".polly" -or $_.extension -like ".nonexistent"} | foreach-object {$_.fullname}
    echo ""

    # Begin: show "Downloads"
    echo "  | Download saving simulation is now ON "
    echo "  |"
    echo "  | So far no wikis have been downloaded to ""$dummyDldDir"""
    gci | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 

    # -- CYCLE 1
    echo "  | Cycle 1 -- this simulation lasts 30 seconds & downloads 17 test wiki"
    echo "  |            including 5 ""tricky"" cases, 6 ""to parrot"" and 2 ""weirdos"""
    echo "  |"; 
    echo "  |            ... cycle 1 is running"; 
 
    # standard 
    touch "round-robin.tw"
    start-sleep -seconds 5  
 
    # to parrot      
    touch "me-duck-a.html"     ; add-content -path .\me-duck-a.html  -value "I am: me-duck-a-html"            
    touch "me-duck-b.html"     ; add-content -path .\me-duck-b.html  -value "I am: me-duck-b-html"   
    touch "me-duck-c.html"     ; add-content -path .\me-duck-c.html  -value "I am: me-duck-c-html"   
    touch "parrot-red.html"
    touch "parrot-green.html"
    start-sleep -seconds 2
    touch "goose-wiki.htm"
 
    # tricky
    touch "tricky-test.html"   ; add-content -path .\tricky-test.html -value "I am: tricky-test.html"
    touch "tricky.polly"       ; add-content -path .\tricky.polly     -value "I am: tricky.polly"
    touch "tricky.html"        ; add-content -path .\tricky.html      -value "I am: tricky.html"
    touch "tricky.htm"         ; add-content -path .\tricky.htm       -value "I am: tricky.htm"
    touch "tricky.tw"          ; add-content -path .\tricky.tw        -value "I am: tricky.tw"
    #touch "tricky-test.html"   ; add-content -path .\tricky-test.html -value "I am: tricky-test.html"

    # weird
    touch "quail.html"
    touch "the-old-sock.polly"
    echo "  |"; 
    echo "  | Quail is not really one of us"; 
    echo "  | Quail is a bit of a weirdo";
    start-sleep -seconds 11

    # not-html
    touch "polly.pdf"
    start-sleep -seconds 12 

    # standard
    touch "macaw-blog.html"
    touch "round-robin (2).tw"
    echo "  |"
    echo "  | The sleeper awakes to these downloads (latest first) ..."
    gci -file | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 


    # -- CYCLE 2
    echo "  | Cycle 2 -- lasts 120 seconds & updates downloads 15 times"
    echo "";  pause; echo ""; 
    echo "  |            ... cycle 2 is running";  

    # standard
    touch "round-robin (3).tw"
    start-sleep -seconds 1

    # not-html
    touch "polly.ico" 

    # tricky
    touch "tricky (2).html"  ; add-content -path ".\tricky (2).html" -value "I should be: tricky (2).html"
    start-sleep -seconds 12

    # to parrot 
    touch "goose-wiki (2).htm" 
    start-sleep -seconds 20                           
    touch "me-duck-a (2).html"    
    start-sleep -seconds 15                          
    touch "me-duck-b(2).html"

    # standard
    touch "macaw-blog (46).html"   
    echo "  |"; 
    echo "  | Hey-up me duck! I see you are testing Polly ..."; 
    start-sleep -seconds 45

    # to parrot     
    touch "me-duck-a (3).html" 
    start-sleep -seconds 2                     
    touch "me-duck-b(3).html"
    start-sleep -seconds 2
    touch "me-duck-c (2).html"
    touch "parrot-red (2).html"
    touch "parrot-green (2).html"            
    start-sleep -seconds 7   
    touch "me-duck-a (4).html" ; add-content -path ".\me-duck-a (4).html" -value "I should be: me-duck-a (4).html"

    # standard           
    touch "round-robin (4).tw"
    start-sleep -seconds 20 
    touch "macaw-blog (47).html"
    echo "  |"
    echo "  | By now Polly could have detected these many changes ..."
    gci -file | sort-object -property LastWriteTime -descending | ft  Name, LastWriteTime, Length -autosize -hidetableheaders; 


    # -- CYCLE 3
    echo "  | Cycle 3 -- lasts 400 seconds & updates in downloads 8 times"
    echo "";  pause; echo ""; 
    echo "  |            ... cycle 3 is running" 

    # standard   
    touch "round-robin (5).tw"
    start-sleep -seconds 76

    # to parrot  
    touch "goose-wiki (2).htm" 
    touch "me-duck-c (4).html" ; add-content -path ".\me-duck-c (4).html" -value "I should be: me-duck-c (4).html"
    start-sleep -seconds 58  

    # standard                         
    touch "macaw-blog (48).html" 
    start-sleep -seconds 62          
    echo "  |"; 
    echo "  | Polly is the kind of tool that father used to extract nails from plywood";     start-sleep -seconds 120                          
    
    # does not exist
    touch "mywiki-b (8).html" 
    start-sleep -seconds 4

    # not-html   
    touch "polly.png"  
    start-sleep -seconds 76  

    # standard          
    touch "round-robin (6).tw"
    touch "macaw-blog (49).html" 
    echo "  | "
    echo "  | Polly works hard to maintain the Empire ..."
    gci -file | sort-object -property LastWriteTime -descending | ft  Name, LastWriteTime, Length -autosize -hidetableheaders; 
    
    # Repeat?           
    $doTouch = Read-Host "? | [R] to restart simulation of downloads. Any other key to quit"
  } 
  while ($doTouch -eq "R")
  cleanup; cls; exit
  