# Imports
Set-Location $PSScriptRoot;
Import-Module ./installers/modules/test-is-admin.psm1 -DisableNameChecking
Import-Module ./installers/modules/messages.psm1 -DisableNameChecking


function Write-Welcome-Message {
    Write-Host  "******************************  IDE Configurer  ******************************"
    Write-Host  "*                                                                            *"
    Write-Host  "* Script to automate IDE configuration process                               *"
    Write-Host  "* adjust configuration.json file to your needs before running the script     *"
    Write-Host  "*                                                                            *"
    Write-Warning-Line
    Write-Host  "*                                                                            *"
    Write-Host  "*                                                                            *"
    Write-Host  "*  Options:                   Description:                                   *"
    Write-Host  "*  --------------------------------------------------------------------      *"
    Write-Host  "*  1. Install Tools           Installs tools that are required               *"
    Write-Host  "*                             in next steps                                  *"
    Write-Host  "*                                                                            *"
    Write-Host  "*  2. Install Pimped Bash     Installs Windows Terminal, fonts, powerline,   *"
    Write-Host  "*                             lsd and configures all of it                   *"
    Write-Host  "*                                                                            *"
    Write-Host  "*  3. Configure Visual Studio Imports settings and installs extensions       *"
    Write-Host  "*                             specified in VisualStudio/configuration.json   *"
    Write-Host  "*                             for every Visual Studio version specified      *"
    Write-Host  "*                                                                            *"
    Write-Exit-Line
    Write-Host  "*                                                                            *"
    Write-Host  "*****************************************************************************"
}

function Write-Exit-Line {
    Write-Host -NoNewline  "*"
    Write-Host -NoNewline  "  0. Exit  Exits the script                                                 " -ForeGroundColor Blue
    Write-Host  "*"
}

function Write-Warning-Line {
    Write-Host -NoNewline  "* "
    Write-Host -NoNewline "Do not close powershell when script is running, " -ForeGroundColor Red
    Write-Host  "*"

    Write-Host -NoNewline  "*"
    Write-Host -NoNewline  " this may cause malfunctions in the system !                                " -ForeGroundColor Red
    Write-Host "*"
}

# Check adming rights
if ((Test-Is-Admin) -eq $false) {
    if (!$elevated) {
        Write-Warning "This script requires admin prvileges. Grant it in order to continue."
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile', '-noexit', ('-file "{0}"' -f $myinvocation.MyCommand.Definition), '-elevated')
    }
    exit
}

while ($true) {
    Set-Location $PSScriptRoot;
    Write-Welcome-Message
    $key = [console]::ReadKey()
    Clear-Host
    switch ($key.Key) {
        'D0' {
            exit    
        }
        'D1' {
            Invoke-Expression './installers/install-tools.ps1'
            break
        }
        'D2' {
            Invoke-Expression './installers/install-pimped-bash.ps1'
            break
        }
        'D3' {
            Invoke-Expression './installers/configure-visual-studio.ps1'
            break
        }
    }
    Write-Host "Press any key to continue..."
    [console]::ReadKey()
    Clear-Host
}