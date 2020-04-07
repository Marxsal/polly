# polly-01Oa-MS.ps1 -- PS5/PS6/PS7

# GET COMMAND-LINE PARAMETERS -----------------
  param ([string]$ini, [string]$run); 
  #cls MAS

# SET RUN LOCATION ----------------------------
  Set-Location "$PSScriptRoot"

  $stemtracker = @{} # Map to keep track of unique stems.

# LOAD LIBRARIES ------------------------------
  #region LoadLibraries

  # --- CORE
    . ./lib/Get-IniContent.ps1 
    # Core libraries used
    $libs = "./lib/Get-IniContent.ps1, ./lib/do-settings.ps1"
# MAS Marker (c)heck-filedupes
    function check-filedupes( [string]$pFile1) {
        #param( [string]$pFullname )
        #$fullstem = $pFile1.split($SEPREG)[-1]
        $fullstem = Split-Path -Leaf $pFile1 ;
        if( $stemtracker.containskey( $fullstem)) {
            $file2 = $stemtracker[$fullstem]
            echo ""
            echo "=== DUPLICATE STEM ==="
            echo "Stem file $fullstem for "
            echo "$pFile1 is already in use by file "
            echo "$file2 . Please check your wiki file list "
            echo "and wiki dirs and eliminate duplicates."
            echo "Polly will now close in $closeSeconds seconds"
            start-sleep -seconds  $closeSeconds
                exit
        }
        return $fullstem
    }

 ### FOLLOWING FUNCTION CAN BE DELETED
  function get-fullstem {

      param( [string]$pFullname )
          $fileName = $pFullname.split($SEPREG)[-1]
          #echo ""
          #echo "| $fileName"
          #echo "|"
          
          $stempieces = $fileName.split(".")
          $exten = $stempieces[-1].trim()
          $stempieces = $stempieces[0..($stempieces.length-2)]
          $stem = $stempieces -join "."
      return $stem.$exten
  }

    # ???
    function expand-dir {
      param( [string]$pDirname )
      if ([string]::IsNullOrEmpty($pDirname)) {return $null} 
      $dirName = [System.Environment]::ExpandEnvironmentVariables($pDirname)

#if ($isWindows) { echo I think this is windows }
#if ($isLinux) { echo I think his is linux }

     if( ($isLinux -or $isMacOS) -and !$dirName.StartsWith("/") -and !$dirName.StartsWith("~")  ) {
         $dirName = "$scriptDir/$dirName"
     }
     if( $isWindows -and ![System.IO.Path]::IsPathRooted($dirName) ) {
         $dirName = "$scriptDir\$dirName"
     }
     return $dirName 
  }

  # --- EXTENSIONS [TESTING]
    #. ./dev/experiments.ps1

  #endregion LoadLibraries

# INTERNAL SETTINGS ---------------------------
  #region InternalSettings

  # --- APPLICATION NAME & VERSION 
    $appAndVer = "POLLY v0.1Oa-MS (PS5/PS6/PS7)"

  # --- PATH SEPARATORS: support o/s variations 
    $SEPARATOR= [IO.Path]::DirectorySeparatorChar
    $SEPREG = '[/\\]+'
  
  # --- IF PS 6+/CORE NOT RUNNING: do Windows only
    if($PSVersionTable.PSVersion.major -lt 6) {
      # Variables auto-available in PSCore+
      $isWindows = $true ;
      $isMacOS   = $false;
      $isLinux   = $false;
    }

  # --- CONSOLE: ?? Not clear yet how cross-platform these settings can be ??
    $psHost = get-host
    $console = $psHost.UI.RawUI
    $console.WindowTitle = "$appAndVer -- $mode mode"
    $console.ForegroundColor = "yellow" 
       
    # ?? Breaks in PS IDE, but otherwise works ??
    #$sizeWidth = $console.WindowSize; $sizeWidth.Width = 85
    #$console.WindowSize = "$sizeWidth"
    # O/S variants
    if($isWindows){$console.BufferSize = New-Object System.Management.Automation.Host.Size(165,5000)}

  # --- RUN MODE
    # Run mode default: can be overridden by parameter "-run ["auto"|"once"|"parrot"]
    $mode = "menu"
    # Command line parameter overrides
    if (![string]::IsNullOrEmpty($run)){$mode = "$run"}
    # Additional modes from MENU: 'O' for "once-menu", 'P' for "parrot-menu" [NOT COMPLETE]

  # --- TIMING
    # polly-once /polly-parrot batch files with paramters "-run $mode" -- timeout to exit
    $closeSeconds = 15
    # once/'O' & parrot/'P' from menu -- timeout to refesh menu
    $menuRefreshSeconds = 10
  
  # --- PATHING & FILES
    # Script file 
    $scriptDrv  = $pwd.drive.name; $scriptDrv = "${scriptDrv}:" 
    $scriptDir  = "$PSScriptRoot"
    $scriptFile = $MyInvocation.MyCommand
  
    # Settings file default: can be overridden via command line parameter "-ini [file.ini]"
    $settingsFile = "settings.ini"
    # "settings.ini" template
    $iniTemplate = "./lib/template.ini"
    # Settings help file
    $iniHelp = "./lib/settings.txt"
    # Command line override
    if (![string]::IsNullOrEmpty($ini)) {$settingsFile = "$ini"}
  
    # Usage notes
    $usageFile = "./lib/usage.txt"
  
    # Resources
    $urlPollyHlpDesc = "Polly Help"   ; $urlPollyHlp = "https://tidbits.wiki/polly/polly.html"  
    $urlPollyDevDesc = "Polly GitHub" ; $urlPollyDev = "https://github.com/Marxsal/polly" 

  # --- MENU OPTIONS HIDING
    # Optional .ini settings that are null or empty are hidden, though active
    # Z - Run Tests: "hide" (default) or "show". When hidden, acesss to tests is also removed
    $hideTests = "hide"

  # --- EDITOR
    # ?? Move to do-settings.ps1 ??
    $editor = "notepad.exe" 
  
  #endregion InternalSettings

# USER SETTINGS -------------------------------
  #region UserSettings

  # --- CREATE SETTINGS.INI FILE IF MISSING
    if(!(test-path "./settings.ini")){#$SettingsIniExists = "no"; 
    . ./lib/do-settings.ps1; exit} 

  # --- GET SETTINGS FROM .INI FILE 
    $settings = Get-IniContent "$scriptDir/$settingsFile"; 
    $general = $settings["general"] ;
 
  # --- DOWNLOADS DIRECTORY: where browser downloads go
    $downloaddir = $general["downloaddir"]
    # If not defined use o/s "userprofile" variable
    if ([string]::IsNullOrEmpty($downloaddir)){$downloaddir = "$Env:userprofile\Downloads"}
    # Expand dir in case it contains environmental variables. Also conform to absolute address
    $downloaddir = expand-dir($downloaddir)
    # ?? should add a path check ?? Some (few?) users reset through registry the downloads dir!

   $filesHolder = $settings["wikis"].values ;

    # Parse files, convert to absolute paths
    #echo "I think count is $files.length"
    #get-member -InputObject $files
    $files = @()
    #for ($i = 0; $i -le ($files.length - 1); $i += 1) {
    foreach($file in $filesHolder) {
	#echo "File before expansion: $file"
        $file = expand-dir($file) 
	#echo "File after expansion: $file"
	$file_obj = Get-ChildItem $file 
	$file_fullname = $file_obj.fullname ;
	#echo "File fullname: $file_fullname"
        #if( ![System.IO.Path]::IsPathRooted($file) ) {
        #    $file = "$scriptDir\$file"
        #}
        $fullstem = check-filedupes $file_fullname 
        $files += $file  
        $stemtracker[$fullstem] = $file.fullname
        #echo "Expanded and absoluted file: $file"
    }

# Get all htm/html files from specified "wikis" directories

    #echo "Download dir is at: $downloaddir"
    $dirsHolder = $settings["wikidirs"].values 
    #echo $dirsHolder
    foreach($dir in $dirsHolder) {
        # echo "File before expansion: $dir"
            $dir = expand-dir($dir) 
            # echo "File after expansion: $dir"
            if(test-path -path $dir -pathtype "container" ) {
                # echo "Comparing paths $dir and $downloaddir BEFORE"
                    if( (join-path $dir '') -eq (join-path $downloaddir '')) {
                         echo "Can not use download directory as wikis dir."
                    } else {
                        # echo "Dir $dir passes directory tests"
                        #$temp = compare-object -ReferenceObject $downloaddir -DifferenceObject $dir 
                        #$temp | select-object -property * -erroraction stop

                            # echo "Comparing paths $dir and $downloaddir AFTER"
                            #Get-ChildItem  -path $dir -recurse | ? -FilterScript {$_.extension -match "htm*|tw"} | sort-object -property Name | Format-Table Name, "in", Fullname -autosize -hidetableheaders;
                            $wfiles = Get-ChildItem  -path $dir -exclude $downloaddir | ? -FilterScript {$_.extension -match "htm*|tw"} 
                            #$wfiles | select-object
                            foreach($file in $wfiles) {
                                #echo $file.fullname
                                #$file | select-object          
				# MAS This seems to work, but keep in mind:
				# $fullstem = Split-Path -Leaf $pFile1 
                                $fullstem = $file.fullname.split($SEPREG)[-1]
                                #$fullstem = get-fullstem $file.fullname

                                #echo "Fullstem is: $fullstem"
                                $dummy = check-filedupes $file.fullname
                                $files += $file.fullname  
                                $stemtracker[$fullstem] = $file.fullname
                                #get-member #-InputObject $files
                            }       
                    }
            } else {
                echo "$dir is not a directory"
            }                
    }




  $parrots = $settings["parrots"].values ;

    # Parse "parrots" to "pollies" to avoid repeating on every restore
  $pollies = @{} 
    foreach ($parrot in $parrots) {
      $parrotName = $parrot.split($SEPARATOR)[-1]
      #echo "I see parrot stem: $parrotName " 
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
  
#-> TEST POLLIES <-
if ($pollies.Count -gt 0 ) {
   #echo "I don't think pollies is null. Here's what I see: "
   foreach ($polly in $pollies.keys) {
      $temp = $pollies[$polly]
      #echo "I see polly $polly with dir $temp "
   }
}
  
  # --- DESCRIPTION (optional): useful if you have more than one .ini file
    $inidescription = $general["inidescription"]

 
  # --- WIKIS DIRECTORY (optional): useful where wikis are nested under one directory
    $wikidir = $general["wikidir"]
      
  # --- WIKIS BACKUP DIR (optional): where to create date-stamped backups
    $backupdir= expand-dir $general["backupdir"]
    #$backupdir = expand-dir $backupdir
    

  # --- WIKIS BACKUP ZIP DIR (optional): where to create date-stamped zip archives
    $backupzipdir= expand-dir $general["backupzipdir"]

  # --- TIMING: seconds to wait between checks
    $waitSeconds = $general["waitseconds"]
  
  #endregion UserSettings

#-> TESTS: when 'Z' menu option activated <- 
function tests {echo ""; echo "  | TESTS"; echo "  |"; echo "  | Who's a pretty Polly! Who's a pretty Polly!"; echo ""

    # --- MS INI LOADING CHECK
#$settings = Get-IniContent "$scriptDir\$settingsFile"; 

$files = $settings["wikis"].values ;
foreach ($obj in $files) {echo "I see stem: " $obj.split($SEPARATOR)[-1]  } 
$objMembers = $settings["wikis"].psobject.members | where-object Name -like 'file'; 
$objMembers ;
foreach ($obj in $objMembers){ $obj.Value } ; $objMembers
   
#pause
#break
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
    echo "  |        Username: $Env:Username"                ; $policy = Get-ExecutionPolicy 
    echo "  |          Policy: $policy"
    echo "  |"
    echo "  |   Polly version: $appAndVer"
    echo "  |"
    echo "  |   Settings file: $settingsFile"                ; if (![string]::IsNullOrEmpty($inidescription)){
    echo "  |                  $inidescription"}
    echo "  |"
    echo "  | Script run mode: $mode"
    echo "  | Auto-mode timer: $waitSeconds seconds between checks"
    echo "  | Once-mode timer: $closeSeconds seconds to close after restore"
    echo "  |"
    echo "  |    Script drive: $scriptDrv"
    echo "  |      Script dir: $scriptDir"
    echo "  |      PS1 script: $scriptFile"
    echo "  |       Libraries: $libs" 
    echo "  |"
    echo "  |   O/S Downloads: $Env:userprofile$SEPARATOR`Downloads (guessed)"
    echo "  |   Downloads dir: $downloaddir (used by Polly)" ; if (![string]::IsNullOrEmpty($wikidir)){
    echo "  |       Wikis dir: $wikidir"}                    ; if (![string]::IsNullOrEmpty($backupdir)){
    echo "  |     Backups dir: $backupdir"}                  ; if (![string]::IsNullOrEmpty($backupzipdir)){
    echo "  | Zip backups dir: $backupzipdir"} 
    echo "  |"
    echo "  |     Usage notes: $usageFile"   
    echo "  |      $urlPollyHlpDesc`: $urlPollyHlp"   
    echo "  |    $urlPollyDevDesc`: $urlPollyDev" ; if($hideTests -eq "show"){
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

# PARROT --------------------------------------
 function parrot {
#echo "I am in parrot function"
  # Write pollies/parrots if applicable
      if ($pollies.Count -gt 0 ) {
        #echo "I don't think pollies is null. Am I repeating myself?"
#$pollies
                  #echo "Attempting to parrot $stem.$exten to $parrotDir"
          if($pollies.ContainsKey("$stem.$exten")) {
              $parrotDir = $pollies["$stem.$exten"] 
                  echo "|"
                  echo "|   Parroting: ""$stem.$exten"""
                  echo "|          to: $parrotDir$SEPARATOR$stem.$exten"
                  #echo "Attempting to parrot $stem.$exten to $parrotDir"
                  if ($mode -eq "parrot-menu") {
                    $copyme = get-item "$fileDir$SEPARATOR$stem.$exten"
                  }
                  Copy-Item $copyme -Destination "$parrotDir$SEPARATOR$stem.$exten"
          }
      }
  }

# MENU PRELIM ---------------------------------
  echo ""
  # PS version
  write-host "               PowerShell:"$PsVersionTable.PSVersion

# MENU ----------------------------------------
  function menu {
    echo ""
    echo "             +===========================+"  
    echo "              $appAndVer"
    echo "            +=============================+"     
    echo "            | A - Auto-Restore every $($waitSeconds.padleft(3,' '))s |"
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
    echo "            | H - Online Help & GitHub    |"
    echo "            |     ----------------------  |"  ; if($hideTests -eq "show"){
    echo "            | Z - Run Tests               |"
    echo "            |     ----------------------  |"}
    echo "            | Q - Quit                    |"
    echo "            +=============================+"
    echo "              $settingsFile active"
    echo "             +===========================+"
  }
# END FUNCTION MENU

$running=$true

while($running) {
#echo "INSIDE RUNNING LOOP (pausing)"
#start-sleep -seconds 10
  do {
      if($mode -eq "auto" -or $mode -eq "once") {$running=$false; break}
      menu
          $selection = read-host "?             Key"
          switch ($selection) {
              'A' {$mode = "auto"} 
              'O' {$mode = "once"       ; $closeSeconds = "$menuRefreshSeconds"; cls}
              'P' {$mode = "parrot-menu"; $closeSeconds = "$menuRefreshSeconds"; cls}
              'D' {cls; echo ""; echo ""; 
                echo "  | SAVED DOWNLOADS (newest first) in ... "; 
                echo "  |"; 
                echo "  | $downloaddir"
                Get-ChildItem -path $downloaddir *.* -file | sort-object -property LastWriteTime -descending | Format-Table Name, LastWriteTime, Length -autosize -hidetableheaders; 
              } 
              'T' {cls; echo ""; echo ""; 
                echo "  | TIDDLYWIKI FOLDER $wikidir"; 
                echo "  |"
                echo "  | Wikis & directories they are in ..."; 
                Get-ChildItem  -path $wikidir -recurse | ? -FilterScript {$_.extension -match "htm*|tw"} | sort-object -property Name | Format-Table Name, "in", Fullname -autosize -hidetableheaders;
              }
              'B' {cls; echo ""
                if($backupzipdir -ne $null){
                  echo ""
                  echo "  | ZIP ARCHIVES of Wikis";
                  echo "  |"
                  echo "  | Latest zip archive of each wiki, under: $backupzipdir"
                  echo ""
                  Get-ChildItem -path $backupzipdir *.* -recurse | where {$_.psiscontainer} | foreach {Get-ChildItem  $_.fullname | sort LastWriteTime | select -expand name -last 1}
                  } 
                if($backupdir -ne $null){
                  echo ""
                  echo "  | BACKUPS of Wikis";
                  echo "  |"
                  echo "  | Latest backup of each wiki, under: $backupdir"
                  echo ""
                  Get-ChildItem -path $backupdir *.* -recurse | where {$_.psiscontainer} | foreach {Get-ChildItem  $_.fullname | sort LastWriteTime | select -expand name -last 1}
                }
                echo ""
              } 
              'S' {. ./lib/do-settings.ps1; exit} 
              'U' {cls; runinfo; usage}
              'H' {cls; echo ""; echo "";
                invoke-expression "start $urlPollyHlp"
                invoke-expression "start $urlPollyDev"
                echo "  | ONLINE RESOURCES LAUNCHED ..."; 
                echo "  |"
                echo "  |   $urlPollyHlpDesc"
                echo "  |   $urlPollyHlp";  
                echo "  |"
                echo "  |   $urlPollyDevDesc"
                echo "  |   $urlPollyDev";  
                echo ""     
              }
              'Z' {if($hideTests -ne "show"){cls} else {cls; echo ""; runinfo; tests}}
              'Q' {
cls #MAS ; 
exit}
          }
  }
  until ($selection -eq 'a' -or $selection -eq 'o' -or $selection -eq 'p')

#echo "Broke out of menu decider loop (pausing)"
#start-sleep -seconds 5 

# RESTORER ------------------------------------
#region Restorer

        cls # MAS
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
#echo "INSIDE RESTORER LOOP"
        # OLD for($i=0;$i -lt $files.Length; $i++) 
        foreach($file in $files) {
          #$filePath = $[$i]
          #echo "File name before split: $file"
          #$fileName = $file.split($SEPREG)[-1] # We don't need this -- PS has tools for file path splitting
          #echo "Splitting a different way: "
          $fileName = Split-Path -Leaf $file ;
          echo ""
          echo "| $fileName"
          echo "|"
          
          $fileDir = $file.substring(0,$file.length - $fileName.length) 

          $stempieces = $fileName.split(".")
          $exten = $stempieces[-1].trim()
          $stempieces = $stempieces[0..($stempieces.length-2)]
          $stem = $stempieces -join "."


if($mode -ne "parrot-menu") {
          $pattern = [regex]::escape($stem) +  "(\s*\(\d+\))*" + [regex]::escape('.'+$exten) 
          echo "|   Using Pat: $pattern"
          $copyme = Get-ChildItem $downloaddir$SEPARATOR$stem*.$exten | Where-Object  {$_.Name -match  $pattern } | sort-object -property LastWriteTime | select -last 1

          
          $short_name = $copyme.Name
          $copyme_fullname  = $copyme.FullName

          if($copyme_fullname -eq $null) {
            echo "|    Skipping ""$stem.$exten"" as no saves found in downloads,"
            echo "|              ... maybe you have not downloaded it yet?"
            echo ""
            continue ;
          }
          
          $copyme = $copyme_fullname
          #echo "Checking fullname $copyme_fullname"

          $destination = Get-Item  "$fileDir$SEPARATOR$stem.$exten"
          $destinationTimestamp = $destination.LastWriteTime
          #$dt = $destinationTimestamp 
          $source = Get-Item "$copyme" 
          echo "|   Comparing: ""$short_name"" in downloads with ..."
          echo "|        Wiki: $destination"
          
          If( $source.LastWriteTime -gt $destination.LastWriteTime.addSeconds(1) ) {
              # Want to perform backup on DESTINATION before it is written over by the copy/move into place
              if($backupdir -ne $null ) {
                  $archiveFilename = generate-archivestring $destinationTimestamp "$stem-$exten" $exten 
                  echo "|"
                  echo "|      Backup: ""$archiveFilename"" of wiki ..."
                  echo "|    saved in: $backupdir$SEPARATOR$stem.$exten\"
                  #echo "Making backup from $destination to $backupdir\$archiveFilename"

                  Make-Directory "$backupdir$SEPARATOR$stem.$exten$SEPARATOR"  
                  Copy-item $destination -Destination "$backupdir$SEPARATOR$stem.$exten$SEPARATOR$archiveFilename"
              }
              # Want to perform ZIP backup on DESTINATION before it is written over by the copy/move into place
              if($backupzipdir -ne $null ) { 
                  $archiveFilename = generate-archivestring $destinationTimestamp "$stem-$exten" "zip" 
                  echo "|"
                  echo "| Zip archive: ""$archiveFilename"" of the wiki ..."
                  echo "|    saved in: $backupzipdir$SEPARATOR$stem.$exten$SEPARATOR"
                  
                  Make-Directory "$backupzipdir$SEPARATOR$stem.$exten$SEPARATOR"  
                  $ProgressPreference = 'SilentlyContinue'
                  Compress-Archive -LiteralPath $destination -Force -CompressionLevel Optimal -DestinationPath "$backupzipdir$SEPARATOR$stem.$exten$SEPARATOR$archiveFilename"
                  $ProgressPreference = 'Continue'
              }

            Copy-Item $copyme -Destination "$fileDir$SEPARATOR$stem.$exten"
            echo "|"
            echo "|   RESTORING: download ""$short_name"" to ..."
            echo "|        Wiki: $destination"
            #echo "  Copying $copyme to $fileDir\$stem.$exten"
            #echo ""

            parrot

            echo ""
          } # IF RESTORE IS NEEDED
          else {
            echo "|"
            echo "|  Restore of ""$short_name"" not required," 
            echo "|              ... this download has already been restored"
            echo ""    
        }  # ELSE RESTORE NOT NEEDED

} else { # END IF-NOT-PARROT-MENU 
 
          parrot
       }

        } # END FOR-EACH-FILE LOOP

        if($mode -eq "parrot-menu" ) {
          echo ""
          echo "  || RUN PARROTS - $appAndVer"
          echo "  ||"
          echo "  || Run mode ""$mode"" completed!" 
          echo "  ||"
          echo "  || Closes in $closeSeconds seconds ..."
          $mode = "menu"
          start-sleep -seconds  $closeSeconds
          # DEBUG 
          cls 
          break
 
       }

        if($mode -eq "once") {
          echo ""
          echo "  || RUN ONCE - $appAndVer"
          echo "  ||"
          echo "  || Run mode ""$mode"" completed!" 
          echo "  ||"
          echo "  || Closes in $closeSeconds seconds ..."
          $mode = "menu"
          start-sleep -seconds $closeSeconds
          # DEBUG 
          cls # MAS 
          #echo "About to break out of Once"
          break 
        }
        else {
          echo ""
          echo "  || Polly is pausing for $waitSeconds seconds ..."
          start-sleep -seconds $waitSeconds 
          echo ""
       } #IF
   } #RESTORE 
#echo "Outside of restore loop (pausing)"
#start-sleep -seconds 10

} #RUNNING (MENU)


#echo "Outside of running loop (pausing)"

#start-sleep -seconds 10
