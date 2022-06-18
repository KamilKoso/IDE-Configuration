Set-Location $PSScriptRoot;
Import-Module ./modules/test-is-admin.psm1 -DisableNameChecking
Import-Module ./modules/messages.psm1 -DisableNameChecking
Import-Module ./modules/download-from-github.psm1 -DisableNameChecking

function Install-WinGet {
    #Install the latest package from GitHub
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType("None")]
    [OutputType("Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage")]
    Param(
        [switch]$Passthru
    )
    if ($PSVersionTable.PSVersion.Major -eq 7) {
        Write-Error "This command does not work in PowerShell 7. You must install in Windows PowerShell."
        return
    }
    
    if ([bool](Get-Command -Name 'winget' -ErrorAction SilentlyContinue)) {
        Write-Information "Winget is already installed."
        return;
    }
    try {
        Write-Information "Installing Winget"
        $File = Download-From-Github -Author "Microsoft" -RepoName "winget-cli" -PackageToDownload "msixbundle"
        Add-AppxPackage -Path $File
        if ($passthru) {
            Get-AppxPackage microsoft.desktopAppInstaller
        }
        Write-Success "Installed Winget"
    }
    catch {
        Write-Error "Error occured while installing WinGet"
        throw $_
    }
    finally {
        Remove-Item $File -Force
    }
}

function InstallPowerToys {
    $PowerToysId = "Microsoft.PowerToys"
    $WingetResult = winget list $PowerToysId --accept-source-agreements | Out-String
    if ($WingetResult -match $PowerToysId) {
        Write-Information "Power Toys are already installed. Skipping step..."
        return
    }

    Write-Information "Installing Power Toys..."
    winget install $PowerToysId --source winget
    Write-Success "Installed Power Toys"
}


function ApplyPowerToysConfiguration {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()][string] $PathToSettingsFile
    )
    Write-Information "Applying configuration..."
    Copy-Item $PathToSettingsFile "$ENV:LOCALAPPDATA\Microsoft\PowerToys"
    Write-Success "Configuration applied."
}

Set-Location '..'
$configurations = (Get-Content '.\configuration.json' | Out-String | ConvertFrom-Json).tools;

Install-WinGet
if($null -ne $configurations.powerToys) {
    InstallPowerToys
    ApplyPowerToysConfiguration -PathToSettingsFile $configurations.powerToys.settingsPath
}