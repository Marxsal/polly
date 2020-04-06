# polly
Batch file system using Windows Powershell to restore TiddlyWiki files from download directory to their original home directory

Effectively, this becomes a new way to save your files, but with these features:

- No binary executables
- Human-readable batch script.
- No special plugins in your TiddlyWiki file
- No special browser required
- No need for node.exe running in background 
- Total size expanded package only 100k
- Backups as regular file and/or zip to specified directories
- The ability to "parrot" extra copies to target directories (e.g. a Dropbox folder)

## Disclaimer

**WARNING!** This should be considered Beta or Alpha level software. It has not been tested under all possible
conditions. Please use parallel backup systems for any files you value. In particular, if you are using a networked
file system, check regularly to be sure your files are saving/restoring as intended. It is recommended that you use
one or more the backup systems (either zip or backup directory) but it is currently up to the user to periodically 
check and maintain those backup directories. Note that over time the backup directories may accumulate many megabytes
of files.

## Prerequisites

- Windows 7 or 10 
    - May work with Linux or Mac with Powershell installed. 
- Powershell 5+
- Linux with Powershell

It may actually work with earlier versions of Powershell, but some menus may disappear. You can download
Powershell 5 from MicroSoft for free. 

## Setup

- Download a zip image of the project
- Right click on the zip file and open properties. At the bottom, select "unblock"
- Unzip the file wherever you want to run
- Run polly.bat to begin. This will offer you the chance to set up your own settings.ini file.
- Alternatively, you may want to set up your own settings.ini file by hand.

### Known adjustments for Linux (and probably Mac)

- For Mac or Linux, you may need to edit or modify polly.bat and other files. e.g.
    - chmod 744 polly.bat
    - Change \ to / inside of polly.bat

## From the Usage file


    |
    |  powershell -file .\polly.ps1 [-ini "settingsfile.ini"] [-run "menu"|"auto"|"once"|"parrot"]
    |
    |   -----------------------------------------------------------------------------------------
    |
    | Command Line   -ini   "settingsfile.ini", a user defined settings file 
    |   Parameters         
    |   ----------     Without an -ini parameter Polly loads "settings.ini".     
    |                  Without "settings.ini" present Polly prompts to create it.
    |                  Once created users can make any number of additional ".ini" files.
    |  
    |                -run   "menu"    displays menu (which can start all other modes)                
    |                       "auto"    checks & restores wikis at user set intervals
    |                       "once"    checks & restores wikis, then exists
    |                       "parrot"  runs extended parroting (only), then exits [NOT YET DONE]
    |
    |                  Without a -run parameter Polly runs in "menu" mode.
    |
    |  Batch Files   Polly comes with three batch files ...
    |  -----------             
    |                       "polly.bat"      runs Polly in "menu" mode
    |                       "polly-auto.bat" runs Polly in "auto" mode
    |                       "polly-once.bat" runs Polly in "once" mode 
    |
    |                  All load the default "settings.ini" file.
    |                  The user can create as many ".bat" files as needed to load any "-ini". 

