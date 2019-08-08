    function getWikiFromDir {
    # --- TT MASS ENUMERATION
      # 1 - gci output capture to baby file

      # 2 - regex the baby for settings

      # 3 - append adolescent to settings
    } 
    getWikiFromDir
    pause

    function browserTests {
    # --- TT BROWSER LAUNCH  
    # test uris
    $uri1 = "$urlPollyHlp"                                     ; # web
    $uri2 = "https://tiddlywiki.com/prerelease/"               ; # web
    $uri3 = "file:///C:/bag/www/tidbits-wiki/polly/polly.html" ; # local

    # browsers -- Work different ways -- ?? needs research to see if there is a common method ??     
        
    #                                                                                                 -engine-
    $browFF = "..\..\..\..\..\FirefoxPortable\FirefoxPortable.exe"                   ; #Firefox       -gecko - works and loads in one NEW window
    $browGC = "..\..\..\..\..\GoogleChromePortable\GoogleChromePortable.exe"         ; #Google Chrome -blink - works and ADDS to existing window
    $browVI = "..\..\..\..\..\vivaldiPortable\Application\vivaldi.exe"               ; #Vivaldi       -blink - works and ADDS to existing window
    $browFA = "..\..\..\..\..\FalkonPortable\FalkonPortable.exe"                     ; #Falkon        -      - only LAST loads
    $browSJ = "..\..\..\..\..\slimjet\slimjet.exe"                                   ; #Slimjet       -blink - works and ADDS to existing window
    $browIR = "..\..\..\..\..\IronPortable\IronPortable.exe"                         ; #Iron          -blink - complains another instance is running
    $browBR = "..\..\..\..\..\brave-portable\brave-portable.exe"                     ; #Brave         -blink - works and ADDS to existing window
    $browOP = "..\..\..\..\..\OperaPortable\OperaPortable.exe"                       ; #Opera         -blink - INCONSISTENT -- treats first as if local & can't find it
    $browEC = """C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe""" ; #Edge Chromium -blink - Not yet working
    $browED = ""                                                                     ; #Edge          -edge  - only FIRST loads and ADDS to existing window
    
    # change last 2 letters to test a browser        
    $browser = $browBR
    invoke-expression "$browser $uri1 $uri2 $uri3"
    # for Edge only
    #invoke-expression "start $browser $uri1 $uri2" ; # doesn't like local file -- only FIRST loads and ADDS to existing window
    }
    browserTests
    pause

    function fetchTests {
    # --- TT FETCH
    #iwr -uri https://tiddlywiki.com/prerelease/ -OutFile ..\..\P\Users\Polly\Downloads\tw_fetch\tw5-pre-$(get-date -f yyyy-MM-dd).html
    }

    function unblockTests {
    # --- TT UNBLOCK
    #Unblock-File -path .\lib\Get-IniContent.ps1
    }