# do-settings-01k-TT.ps1
cls

 # TEST CONFIG --------------------------------
   <# Run in PollyApp dir if run indepedent of main script
   cd "$PSScriptRoot"; cd ..
   gci
   # Test for "settings.ini"
   if(!(test-path ".\settings.ini")){$SettingsIniExists = "no"} 
   else {$SettingsIniExists = "yes"}
   #>

# CREATE SETTINGS.INI IF IT DOES NOT EXIST ----
  if ($SettingsIniExists -eq "no"){
    echo ""
    echo ""
    echo "            | POLLY SETTINGS - $appAndVer"
    echo "            |"
    echo "            |"
    write-Warning "   |  You need to create a ""settings.ini"""
    write-warning "   |      file before Polly can work!"
    echo "            |"
    echo "            | C - Create ""settings.ini"""
    echo "            | "
    echo "            | Q - Quit?"
  }

# EDIT LOADED INI, OR CREATE NEW INI ----------
  else {
    echo ""
    echo ""
    echo "            | POLLY SETTINGS - $appAndVer"
    echo "            |"
    echo "            |"
    echo "            | E - Edit current ""$settingsFile""?"
    echo "            |" 
    echo "            | N - Create New settings file?"
    echo "            |"
    echo "            | Q - Quit?"
  }

# SELECT & DO ---------------------------------
  echo ""
  $selection = read-host "?             Key"
  # !! No error checking yet !!
  switch ($selection) {
    'C'{
      $iniName = "settings.ini"
      #Path check
      copy-item "$iniTemplate" -destination "$iniName"
    }  
    'E'{
      $iniName = "$settingsFile"
      #& $editor "$iniName"
    }
    'N'{
      echo ""
      $iniName = "new.ini"
      $iniName = Read-Host -Prompt "            | What do you want to call this ""$iniName"" file?"
      copy-item ".\lib\template.ini" -destination "$iniName"
      #& $editor "$iniName"
    }
    'Q' {cls; exit} 
  } 
  & $editor "$iniName"

# FINISH INI SETTINGS -------------------------
  cls; echo ""; echo "";
  get-content $iniHelp -raw 
  echo ""
  echo ""
  echo "            | EDITING ""$iniName"" in $editor ..."
  echo "            |"
  echo "            |"
  echo "            | Information on available settings is displayed above."
  echo "            |"
  write-warning "   | When you have finished editing, save the settings file," 
  write-warning "   | quit, then run the Polly batch for settings to be loaded."
  echo "            |"
  echo "            | To Quit..."
  echo ""
  pause
  cls
  exit

  # ?? BATCH FILE MAKER ??