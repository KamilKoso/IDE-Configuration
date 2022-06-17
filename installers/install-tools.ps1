Set-Location $PSScriptRoot;
Import-Module ./modules/test-is-admin.psm1 -DisableNameChecking
Import-Module ./modules/messages.psm1 -DisableNameChecking

function Install-WinGet {
    #Install the latest package from GitHub
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType("None")]
    [OutputType("Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage")]
    Param(
        [switch]$Passthru
    )
    if ($PSVersionTable.PSVersion.Major -eq 7) {
         Write-Warning "This command does not work in PowerShell 7. You must install in Windows PowerShell."
         return
    }
    
    if([bool](Get-Command -Name 'winget' -ErrorAction SilentlyContinue)) {
         Write-Information "Winget is already installed."
         return;
    }

    Write-Information "Installing Winget"
    $uri = "https://api.github.com/repos/microsoft/winget-cli/releases"
        $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
        $data = $get[0].assets | Where-Object name -Match 'msixbundle'
        $appx = $data.browser_download_url
        If ($pscmdlet.ShouldProcess($appx, "Downloading asset")) {
            $file = Join-Path -path $env:temp -ChildPath $data.name

            Invoke-WebRequest -Uri $appx -UseBasicParsing -DisableKeepAlive -OutFile $file

            Write-Verbose "[$((Get-Date).TimeofDay)] Adding Appx Package"
            Add-AppxPackage -Path $file -ErrorAction Stop

            if ($passthru) {
                Get-AppxPackage microsoft.desktopAppInstaller
            }
        }
    Write-Success "Installed Winget"
}

Install-WinGet