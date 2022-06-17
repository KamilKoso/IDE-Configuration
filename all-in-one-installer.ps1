# Imports
Set-Location $PSScriptRoot;
Import-Module ./installers/modules/test-is-admin.psm1 -DisableNameChecking
Import-Module ./installers/modules/messages.psm1 -DisableNameChecking


function Write-Welcome-Message {
    Write-Host  "*********************  IDE Configuration Installer  *************************"
    Write-Host  "* Script to automate IDE configuration process                              *"
    Write-Host  "*                                                                           *"
    Write-Host  "*                                                                           *"
    Write-Host  "* Options:                Description:                                      *"
    Write-Host  "*  --------------------------------------------------------------------     *"
    Write-Host  "*  1 Install Tools:        Installs tools required in next steps            *"
    Write-Host  "*                                                                           *"
    Write-Host  "*  2 Install Pimped Bash:  Installs Windows Terminal, fonts, powerline,     *"
    Write-Host  "*                            lsd and configures all of it                   *"
    Write-Host  "*                                                                           *"
    Write-Host  "*  3 Install PowerToys:    Installs PowerToys and applies settings          *"
    Write-Host  "*                           located in PowerToys directory                  *"
    Write-Host  "*                                                                           *"
    Write-Host  "*  Visual Studio:          Automating this step became very complicated     *"
    Write-Host  "*                           so import settings manually                     *"
    Write-Host  "*                           by going to Tools -> Import and Export Settings *"
    Write-Host  "*                                                                           *"
    Write-Exit-Line
    Write-Host  "*****************************************************************************"
}

function Write-Exit-Line {
    Write-Host -NoNewline  "*"
    Write-Host -NoNewline  "  0 Exit:  Exits the script                                                " -ForeGroundColor Red
    Write-Host  "*"
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
            Invoke-Expression './installers/install-powertoys.ps1'
            break
        }
    }
    Write-Host "Press any key to continue..."
    [console]::ReadKey()
    Clear-Host
}