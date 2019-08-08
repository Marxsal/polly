<# Get-IniContent-01k-TT.ps1
 #
 #  Changes prefixed by "# TT -" & "# MAS -"
 #
 #  -----------------------------------------------------------------------------------
 #  This is a modified PS1 module that reads ".ini" files, a component of "PsIni 3.1.2"
 #
 #              Info & code: https://github.com/lipkau/PsIni
 #         Component source: https://www.powershellgallery.com/packages/PsIni/3.1.2/Content/Functions%5CGet-IniContent.ps1
 #  Component (MIT) license: https://github.com/lipkau/PsIni/blob/master/LICENSE
 #>

Function Get-IniContent {  
    <#  
    .Synopsis  
        Gets the content of an INI file  
          
    .Description  
        Gets the content of an INI file and returns it as a hashtable  
          
    .Notes  
        Author        : Oliver Lipkau <oliver@lipkau.net>  
        Blog          : http://oliver.lipkau.net/blog/  
        Source        : https://github.com/lipkau/PsIni 
                      : http://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91 
        Version       1.0 - 2010/03/12 - Initial release  
                      1.1 - 2014/12/11 - Typo (Thx SLDR) 
                                         Typo (Thx Dave Stiff) 
                      1.3 - 2019/07/01 - Don't pass back comments (MAS)
                      1.4 - 2019/07/18 - Various changes to section tests (TT)
                      1.5 - 2019/07/22 - Needs 'continue' at bottom of section test (MAS)  

        #Requires -Version 2.0  
          
    .Inputs  
        System.String  
          
    .Outputs  
        System.Collections.Hashtable  
          
    .Parameter FilePath  
        Specifies the path to the input file.  
          
    .Example  
        $FileContent = Get-IniContent "C:\myinifile.ini"  
        -----------  
        Description  
        Saves the content of the c:\myinifile.ini in a hashtable called $FileContent  
      
    .Example  
        $inifilepath | $FileContent = Get-IniContent  
        -----------  
        Description  
        Gets the content of the ini file passed through the pipe into a hashtable called $FileContent  
      
    .Example  
        C:\PS>$FileContent = Get-IniContent "c:\settings.ini"  
        C:\PS>$FileContent["Section"]["Key"]  
        -----------  
        Description  
        Returns the key "Key" of the section "Section" from the C:\settings.ini file  
          
    .Link  
        Out-IniFile  
    #>  
      
    [CmdletBinding()]  
    Param(  
        [ValidateNotNullOrEmpty()]  
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]  
        [Parameter(ValueFromPipeline=$True,Mandatory=$True)]  
        [string]$FilePath  
    )  
      
    Begin  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"}  
          
    Process  
    {  
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Processing file: $Filepath"  
              
        $ini = @{}  
        switch -regex -file $FilePath  
        {  
  # TT - Added discard of leading and trailing whitespace  
            "^\s*\[(.+?)\]\s*$"                    # Section  
            {  
                $section = $matches[1]  
                $ini[$section] = @{}  
                $CommentCount = 0  
            }  
  # TT - Added "-" as a possible first character for a comment line  
            "^([\-;].*)$"                         # Comment  
            {  
                if (!($section))  
                {  
                    $section = "No-Section"  
                    $ini[$section] = @{}  
                }  
                $value = $matches[1]  
                $CommentCount = $CommentCount + 1  
                $name = "Comment" + $CommentCount  
  # MAS - Fix to enable "continue"
                #$ini[$section][$name] = $value 
                continue               
            }
  # TT - Added discard of excess whitespace   
            "(.+?)\s*=\s*(.*?)\s*$"               # Key  
            {  
                if (!($section))  
                {  
                    $section = "No-Section"  
                    $ini[$section] = @{}  
                }  
                $name,$value = $matches[1..2]  
                $ini[$section][$name] = $value  
            }  
        }  
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Processing file: $FilePath"  
        Return $ini  
    }  
          
    End  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}  
} 