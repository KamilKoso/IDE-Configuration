Set-Location $PSScriptRoot;
Import-Module ./modules/test-is-admin.psm1 -DisableNameChecking
Import-Module ./modules/messages.psm1 -DisableNameChecking

function InstallPowerToys {
    $PowerToysId = "Microsoft.PowerToys"
    $WingetResult = winget list $PowerToysId | Out-String
    if ($WingetResult -match $PowerToysId) {
        Write-Information "Power Toys are already installed. Skipping step..."
        return
    }

    Write-Information "Installing Power Toys..."
    winget install $PowerToysId --source winget
    Write-Success "Installed Power Toys"
}


function ApplyConfiguration {
    Write-Information "Applying configuration..."
    Copy-Item "..\PowerToys\settings.json" "$ENV:LOCALAPPDATA\Microsoft\PowerToys"
    Write-Success "Configuration applied."
}

InstallPowerToys
ApplyConfiguration