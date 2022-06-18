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

Install-WinGet