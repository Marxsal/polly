﻿# polly-01k-TT.ps1

# GET COMMAND-LINE PARAMETERS -----------------
  param ([string]$ini, [string]$run); cls

# SET RUN LOCATION ----------------------------
  cd "$PSScriptRoot"

# LOAD LIBRARIES ------------------------------
  #region LoadLibraries

  # --- CORE
    . .\lib\Get-IniContent.ps1 
  # Core libraries used
    $libs = ".\lib\Get-IniContent.ps1"
  # --- EXTENSIONS [TESTING]
    #. .\dev\experiments.ps1

  #endregion LoadLibraries

# INTERNAL SETTINGS ---------------------------
  #region InternalSettings

  # --- APPLICATION NAME & VERSION 
    $appAndVer = "POLLY v0.1k-TT"

  # --- CONSOLE
    $console = $host.UI.RawUI
    $console.WindowTitle = "$appAndVer -- $mode mode"
    $console.BufferSize = New-Object System.Management.Automation.Host.Size(165,5000)
    $console.ForegroundColor = "yellow"

  # --- RUN MODE
    # Run mode default: can be overridden by parameter "-run ["auto"|"once"|"parrot"]
    $mode = "menu"
    # Command line parameter overrides
    #if($run -eq "auto") {$mode = "$run"}; if($run -eq "once") {$mode = "$run"}
    if (![string]::IsNullOrEmpty($run)){$mode = "$run"}
    # Additional modes from MENU: 'O' adds "once-menu", 'P' adds "parrot-menu" [NOT COMPLETE]

  # --- TIMING
    # "once" timeout default: seconds to close when $mode = "once"
    $closeSeconds = 15
  
  # --- PATHING & FILES
    # Script file 
    $scriptDrv  = $pwd.drive.name; $scriptDrv = "${scriptDrv}:" 
    $scriptDir  = "$PSScriptRoot"
    $scriptFile = $MyInvocation.MyCommand
  
    # Settings file default: can be overridden via command line parameter "-ini [file.ini]"
    $settingsFile = "settings.ini"
    # "settings.ini" template
    $iniTemplate = ".\lib\template.ini"
    # Settings help file
    $iniHelp = ".\lib\settings.txt"
    # Command line parameter overrides
    if (![string]::IsNullOrEmpty($ini)) {$settingsFile = "$ini"}
  
    # Usage notes
    $usageFile = ".\lib\usage.txt"
  
    # Resources
    $urlPollyHlpDesc = "Polly Help" ; $urlPollyHlp = "https://tidbits.wiki/polly/polly.html"  
    $urlPollyDevDesc = "Polly Code" ; $urlPollyDev = "https://tidbits.wiki/polly/polly-dev.html" 

  # --- MENU OPTIONS HIDING
    # Optional .ini settings that are null or empty are hidden, though active
    # R - Run Tests: "hide" (default) or "show". When hidden acesss to tests is also removed
    $hideTests = "show"

  # --- EDITOR
    $editor = "notepad.exe" 
  
  #endregion InternalSettings

# USER SETTINGS -------------------------------
  #region UserSettings

  # --- CREATE SETTINGS.INI FILE IF MISSING
    #if(!(test-path ".\$settingsFile")) # This would allow any setting to run that existed
    if(!(test-path ".\settings.ini")){$SettingsIniExists = "no"; #$settingsFile = "NO SETTINGS"
      . .\lib\do-settings.ps1; exit} 
    else{$SettingsIniExists = "yes"}

  # --- GET SETTINGS FROM .INI FILE 
  $settings = Get-IniContent "$scriptDir\$settingsFile"; 
  $general = $settings["general"] ;
  $files = $settings["wikis"].values ;
  $parrots = $settings["parrots"].values ;

  # --- Parse "parrots" into "pollies" so we don't have to repeat this step
  #     every time a file is restored.
  $pollies = @{} 
    foreach ($parrot in $parrots) {
      $parrotName = $parrot.split("\")[-1]
      echo "I see parrot stem: $parrotName " 
      #$parrotName
      $parrotDir = $parrot.substring(0,$parrot.length - $parrotName.length) 

      $pollies[$parrotName] = $parrotDir 
      #$stempieces = $parrotName.split(".")
      #$exten = $stempieces[-1].trim()
      #$stempieces = $stempieces[0..($stempieces.length-2)]
      #$stem = $stempieces -join "."
      #$copyme = ls $stem*.$exten | sort LastWriteTime | select -last 1
      #$copyme_fullname  = $copyme.FullName
    } 
  
  # --- TESTING POLLIES
  if ($pollies.Count -gt 0 ) {
     echo "I don't think pollies is null. Here's what I see: "
     foreach ($polly in $pollies.keys) {
        $temp = $pollies[$polly]
        echo "I see polly $polly with dir $temp "
     }
  }
  
  # --- DESCRIPTION (optional): useful if you have more than one .ini file
    $inidescription = $general["inidescription"]

  # --- DOWNLOADS DIRECTORY: where browser downloads go
    $downloaddir = $general["downloaddir"]
    # If not defined use o/s "userprofile" variable
    if ([string]::IsNullOrEmpty($downloaddir)){$downloaddir = "$Env:userprofile\Downloads"}
    # ?? should add a path check ?? Some (few?) users reset through registry the downloads dir!
  
  # --- WIKIS DIRECTORY (optional): useful where wikis are nested under one directory
    $wikidir = $general["wikidir"]
      
  # --- WIKIS BACKUP DIR (optional): where to create date-stamped backups
    $backupdir= $general["backupdir"]
  
  # --- WIKIS BACKUP ZIP DIR (optional): where to create date-stamped zip archives
    $backupzipdir= $general["backupzipdir"]

  # --- TIMING: seconds to wait between checks
    $waitSeconds = $general["waitseconds"]
  
  #endregion UserSettings

# TESTS --------------------------------------- 
  function tests {echo ""; echo "  | TESTS"; echo "  |"; echo "  | Who's a pretty Polly! Who's a pretty Polly!"; echo ""

    # --- MS INI LOADING CHECK
#$settings = Get-IniContent "$scriptDir\$settingsFile"; 

$files = $settings["wikis"].values ;
foreach ($obj in $files) {echo "I see stem: " $obj.split("\")[-1]  } 
$objMembers = $settings["wikis"].psobject.members | where-object Name -like 'file'; 
$objMembers ;
foreach ($obj in $objMembers){ $obj.Value } ; $objMembers
   
#pause
#break

    # --- TT BROWSER LAUNCH   
    #browserTests
 
    # --- TT FETCH
    #fetchTests

    # --- TT PORTABILITY ISSUES
    # The first part of script is in home dir and the second part runs in downloads folder
    # It destroys portability. 
  }

# MAKE ARCHIVE STRING FROM DATE, STEM & EXTEN -
  function generate-archivestring {
    param( [datetime]$dt, [string]$pFilename, [string]$pExten)
            return  "$pFilename-$(get-date -year $dt.year -month $dt.month -day $dt.day -hour $dt.hour -minute $dt.minute -second $dt.second -millisecond $dt.millisecond -f yyyy-MM-dd_HHmmss).$pExten"
  }

# RUN INFO ------------------------------------
  function runinfo {  
    cls
    echo ""
    echo ""
    echo "  | RUN INFO - $appAndVer"
    echo "  |"
    echo "  |"
    write-host "  |      PowerShell:"$PsVersionTable.PSVersion
    echo "  |        Username: $Env:Username"      ; $policy = Get-ExecutionPolicy 
    echo "  |          Policy: $policy"
    echo "  |"
    echo "  |   Polly version: $appAndVer"
    echo "  |"
    echo "  |   Settings file: $settingsFile"      ; if (![string]::IsNullOrEmpty($inidescription)){
    echo "  |                  $inidescription"}
    echo "  |"
    echo "  | Script run mode: $mode"
    echo "  | Auto-mode timer: $waitSeconds seconds between checks"
    echo "  | Once-mode timer: $closeSeconds seconds to close after restore"
    echo "  |"
    echo "  |    Script drive: $scriptDrv"
    echo "  |      Script dir: $scriptDir\"
    echo "  |      PS1 script: $scriptFile"
    echo "  |       Libraries: $libs" 
    echo "  |"
    echo "  |   O/S Downloads: $Env:userprofile\Downloads\ (guessed)"
    echo "  |   Downloads dir: $downloaddir\ (used by Polly)" ; if (![string]::IsNullOrEmpty($wikidir)){
    echo "  |       Wikis dir: $wikidir\"}         ; if (![string]::IsNullOrEmpty($backupdir)){
    echo "  |     Backups dir: $backupdir\"}       ; if (![string]::IsNullOrEmpty($backupzipdir)){
    echo "  | Zip backups dir: $backupzipdir\"} 
    echo "  |"
    echo "  |     Usage notes: $usageFile"   
    echo "  |      $urlPollyHlpDesc`: $urlPollyHlp"   
    echo "  |      $urlPollyDevDesc`: $urlPollyDev" ; if($hideTests -eq "show"){
    echo "  |"
    echo "  |         Testing: on"}
    echo ""
  }

# USAGE ---------------------------------------
  function usage {  
    echo ""
    echo ""
    echo "  | POLLY USAGE - $appAndVer"
    echo "  |"
    get-content $usageFile -raw 
  }

# MAKE-DIRECTORY ------------------------------
  function Make-Directory {

    param( [string]$DirectoryToCreate)

    if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
        
        try {
            New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
        }
        catch {
            Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
        }
            #echo "|   Comparing: ""$short_name"" in downloads with ..."
            echo "|     New dir: Created directory '$DirectoryToCreate'."
    }
    else {
       #echo "|     New dir: Created directory '$DirectoryToCreate'."
            "|  No new dir: $DirectoryToCreate already exists"
    }
  }

# PRELIM --------------------------------------
  echo ""
  # PS version
  write-host "               PowerShell:"$PsVersionTable.PSVersion

# MENU ----------------------------------------
  function menu {
    echo ""
    echo "             +===========================+"  
    echo "              $appAndVer"
    echo "            +=============================+"     
    echo "            | A - Auto-Restore every $($waitSeconds.padright(3,' '))s |"
    echo "            | O - Restore Once            |"  ; if (![string]::IsNullOrEmpty($parrots)){
    echo "            | P - Parrot Now              |"}
    echo "            |     ----------------------  |"  
    echo "            | D - Downloads Folder        |"  ; if (![string]::IsNullOrEmpty($wikidir)) {
    echo "            | T - TiddlyWiki Folder       |"} ; if (![string]::IsNullOrEmpty($backupzipdir) -or ![string]::IsNullOrEmpty($backupdir)){
    echo "            | B - Backups                 |"} 
    echo "            |     ----------------------  |"
    echo "            | S - Settings                |"  
    echo "            |     ----------------------  |" 
    echo "            | U - Usage & Run Info        |"  
    echo "            | H - Online Help             |"
    echo "            |     ----------------------  |"  ; if($hideTests -eq "show"){
    echo "            | Z - Run Tests               |"
    echo "            |     ----------------------  |"}
    echo "            | Q - Quit                    |"
    echo "            +=============================+"
    echo "              $settingsFile active"
    echo "             +===========================+"
  }
  do {
    if($mode -eq "auto" -or $mode -eq "once" -or $mode -eq "once-menu"){break}
    menu
    $selection = read-host "?             Key"
    switch ($selection) {
      'A' {$mode = "auto"} 
      'O' {$mode = "once"}
      'P' {$mode = "parrot-menu"; cls}
      'D' {cls; echo ""; echo ""; 
           echo "  | SAVED DOWNLOADS (newest first) in ... "; 
           echo "  |"; 
           echo "  | $downloaddir\"
           gci -path $downloaddir *.* -file | sort-object -property LastWriteTime -descending | ft Name, LastWriteTime, Length -autosize -hidetableheaders; 
          } 
      'T' {cls; echo ""; echo ""; 
           echo "  | TIDDLYWIKI FOLDER $wikidir\"; 
           echo "  |"
           echo "  | Wikis & directories they are in ..."; 
           gci -path $wikidir -recurse | ? -FilterScript {$_.extension -match "htm*|tw"} | sort-object -property Name | ft Name, "in", Directory -autosize -hidetableheaders;
           #echo "" 
          }
      'B' {cls; echo ""
            if($backupzipdir -ne $null){
              echo ""
              echo "  | ZIP ARCHIVES of Wikis";
              echo "  |"
              echo "  | Latest zip archive of each wiki, under: $backupzipdir\"
              echo ""
              gci -path $backupzipdir *.* -recurse | where {$_.psiscontainer} | foreach {get-childitem $_.fullname | sort LastWriteTime | select -expand name -last 1}

# --- Temporary hack for relative pathing in TEST
#gci -path $downloaddir\$backupzipdir *.* -recurse | where {$_.psiscontainer} | foreach {get-childitem $_.fullname | sort LastWriteTime | select -expand name -last 1}
            } 
            if($backupdir -ne $null){
              echo ""
              echo "  | BACKUPS of Wikis";
              echo "  |"
              echo "  | Latest backup of each wiki, under: $backupdir\"
              echo ""
              gci -path $backupdir *.* -recurse | where {$_.psiscontainer} | foreach {get-childitem $_.fullname | sort LastWriteTime | select -expand name -last 1}

# --- Temporary hack for relative pathing in TEST
#gci -path $downloaddir\$backupdir *.* -recurse | where {$_.psiscontainer} | foreach {get-childitem $_.fullname | sort LastWriteTime | select -expand name -last 1}
            }
            echo ""
          } 
      'S' {. .\lib\do-settings.ps1; exit} 
      'U' {cls; runinfo; usage}
      'H' {cls; echo ""; echo "";
           invoke-expression "start $urlPollyHlp"
           echo "  | ONLINE WIKI LAUNCHED ..."; 
           echo "  |"
           echo "  |   $urlPollyHlpDesc"
           echo "  |"
           echo "  |   $urlPollyHlp";  
           echo ""     
          }
      'Z' {if($hideTests -ne "show"){cls} else {cls; echo ""; runinfo; tests}}
      'Q' {cls; exit}
    }
  }
  until ($selection -eq 'a' -or $selection -eq 'o')

# RESTORER ------------------------------------
  #region Restorer

  # Make sure script now runs in downloads directory
  # --- !! Running in downloads was a mistake on my part :-( 
  # --- !! It breaks portability. Need to fix. !!
  cd $downloaddir
  cls
  echo ""
  echo "  || AUTO-RESTORE - $appAndVer"
  echo "  ||"
  echo "  || Every $waitSeconds seconds checks for new saves in ..."
  echo "  ||"
  echo "  ||   ""$downloaddir"" "
  echo "  ||"
  echo "  || Press [Ctrl+C] to exit"
  echo ""

  #endregion Restorer

while(1) {

    # OLD for($i=0;$i -lt $files.Length; $i++) {
    foreach($file in $files) {
      #$filePath = $[$i]
      $fileName = $file.split("\")[-1]
      echo ""
      echo "| $fileName"
      echo "|"
      
      $fileDir = $file.substring(0,$file.length - $fileName.length) 

      $stempieces = $fileName.split(".")
      $exten = $stempieces[-1].trim()
      $stempieces = $stempieces[0..($stempieces.length-2)]
      $stem = $stempieces -join "."
      #echo  "Stem-dot-extension: $stem*.$exten"

      # [wikiname-literal][regex-of-number-cruft][.extension-literal] 
      # (\s*\(\d+\))*

      $pattern = [regex]::escape($stem) +  "(\s*\(\d+\))*" + [regex]::escape('.'+$exten) 
      echo "|   Using Pat: $pattern"
      #$copyme = ls $stem*.$exten | sort LastWriteTime | select -last 1
      $copyme = gci $stem*.$exten | Where-Object  {$_.Name -match  $pattern } | sort LastWriteTime | select -last 1

# --- TT tests on left
$short_name = $copyme.Name
      $copyme_fullname  = $copyme.FullName

      if($copyme_fullname -eq $null) {
        echo "|    Skipping ""$stem.$exten"" as no saves found in downloads,"
        echo "|              ... maybe you have not downloaded it yet?"
        echo ""
        #echo "Polly could not find any downloads for '$stem'."
        #echo "Possibly you have not yet saved (downloaded) the associated file?"
        #echo "Skipping file stem '$stem. "
        #echo ""
        continue ;
      }
      
      $copyme = $copyme_fullname
      #echo "Checking fullname $copyme_fullname"

      $destination = Get-Item  "$fileDir\$stem.$exten"
      $destinationTimestamp = $destination.LastWriteTime
      #$dt = $destinationTimestamp 
      $source = Get-Item "$copyme" 
      echo "|   Comparing: ""$short_name"" in downloads with ..."
      echo "|        Wiki: $destination"
      
      If($source.LastWriteTime -gt $destination.LastWriteTime.addSeconds(1) ) {
          # Want to perform backup on DESTINATION before it is written over by the copy/move into place
          if($backupdir -ne $null) {
              #$formattedTimestamp = Get-Date -Date $destinationTimestamp -Format "yyyy-MM-dd_HHmmss"
              #$archiveFilename = "$stem-$exten-$(get-date -f yyyy-MM-dd_HH-mm-ss).$exten"
              #$archiveFilename = "$stem-$exten-$(get-date -Date ""$destinationTimestamp"" -f yyyy-MM-dd_HHmmss).$exten"
              #$archiveFilename = "$stem-$exten-$(get-date -year $dt.year -month $dt.month -day $dt.day -hour $dt.hour -minute $dt.minute -second $dt.second -millisecond $dt.millisecond -f yyyy-MM-dd_HHmmss).$exten"
              #$archiveFilename = generate-archivestring $destinationTimestamp $stem $exten   
              $archiveFilename = generate-archivestring $destinationTimestamp "$stem-$exten" $exten 
              echo "|"
              echo "|      Backup: ""$archiveFilename"" of wiki ..."
              echo "|    saved in: $backupdir\$stem.$exten\"
              #echo "Making backup from $destination to $backupdir\$archiveFilename"

              #$ProgressPreference = 'SilentlyContinue'
              #echo  "$backupdir\$stem.$exten\"
              #md -Path "$backupdir\$stem.$exten\" 
              Make-Directory "$backupdir\$stem.$exten\"  
              Copy-item $destination -Destination "$backupdir\$stem.$exten\$archiveFilename"
              #$ProgressPreference = 'Continue'
          }
          # Want to perform ZIP backup on DESTINATION before it is written over by the copy/move into place
          if($backupzipdir -ne $null) { 
              #$archiveFilename = "$stem-$exten-$(get-date -f yyyy-MM-dd_HH-mm-ss).zip"
              #$archiveFilename = "$stem-$exten-$(get-date -Date ""$destinationTimestamp"" -f yyyy-MM-dd_HHmmss).zip"
              #$archiveFilename = generate-archivestring $destinationTimestamp $stem "zip" 
              $archiveFilename = generate-archivestring $destinationTimestamp "$stem-$exten" "zip" 
              echo "|"
              echo "| Zip archive: ""$archiveFilename"" of the wiki ..."
              echo "|    saved in: $backupzipdir\$stem.$exten\"
              
              Make-Directory "$backupzipdir\$stem.$exten\"  
              $ProgressPreference = 'SilentlyContinue'
              Compress-Archive -LiteralPath $destination -Force -CompressionLevel Optimal -DestinationPath "$backupzipdir\$stem.$exten\$archiveFilename"
              $ProgressPreference = 'Continue'
          }

        Copy-Item $copyme -Destination "$fileDir\$stem.$exten"
        echo "|"
        echo "|   RESTORING: download ""$short_name"" to ..."
        echo "|        Wiki: $destination"
        #echo "  Copying $copyme to $fileDir\$stem.$exten"
        #echo ""

        # Write pollies/parrots if applicable
        if ($pollies.Count -gt 0 ) {
            #echo "I don't think pollies is null. Am I repeating myself?"
            if($pollies.ContainsKey("$stem.$exten")) {
                $parrotDir = $pollies["$stem.$exten"] 
                echo "|"
                echo "|   Parroting: ""$stem.$exten"""
                echo "|          to: $parrotDir$stem.$exten"
                #echo "Attempting to parrot $stem.$exten to $parrotDir" 
                Copy-Item $copyme -Destination "$parrotDir\$stem.$exten"
            }
        }
        echo ""
      }
      else {
        echo "|"
        echo "|  Restore of ""$short_name"" not required," 
        echo "|              ... this download has already been restored"
        echo ""    
      }
    }
    if($mode -eq "once") {
      echo ""
      echo "  || RUN ONCE - $appAndVer"
      echo "  ||"
      echo "  || Run mode ""$mode"" completed!" 
      echo "  ||"
      echo "  || Closes in $closeSeconds seconds ..."
      start-sleep -seconds $closeSeconds
      cls; exit
    }
    else {
      echo ""
      echo "  || Polly is pausing for $waitSeconds seconds ..."
      start-sleep -seconds $waitSeconds 
      echo ""
    }
  }