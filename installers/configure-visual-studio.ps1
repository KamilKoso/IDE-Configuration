Set-Location $PSScriptRoot;
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module VSSetup -Scope CurrentUser
Import-Module ./modules/test-is-admin.psm1 -DisableNameChecking
Import-Module ./modules/messages.psm1 -DisableNameChecking
Import-Module ./modules/Download-From-VisualStudio-Marketplace.psm1 -DisableNameChecking

function Invoke-VsixInstaller {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [ValidateNotNull()][Parameter(Mandatory = $true, Position = 2)][Microsoft.VisualStudio.Setup.Instance]$VisualStudioInstance
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $VisualStudioInstance.InstallationPath + "\Common7\IDE\VSIXInstaller.exe"
    $psi.Arguments = "/q $File"

    if (-not (Test-Path $psi.FileName)) {
        throw "Could not find $($VisualStudioInstance.DisplayName) VSIXInstaller.exe at: ${psi.FileName}"
    }

    $process = [System.Diagnostics.Process]::Start($psi)
    $process.WaitForExit()
    return $process.ExitCode;
}

function Install-Vsix {
    [cmdletbinding()]
    Param(
        [ValidateNotNullOrEmpty()][Parameter(Mandatory = $true, Position = 0)][string]$ExtensionName,
        [ValidateNotNull()][Parameter(Mandatory = $true, Position = 1)][Microsoft.VisualStudio.Setup.Instance]$VisualStudioInstance
    )
    Write-Information "Installing ${ExtensionName} extension for $($VisualStudioInstance.DisplayName)..."; 
    try {
        $File = Download-From-VisualStudio-Marketplace $ExtensionName
        $ExitCode = Invoke-VsixInstaller -File $File -VisualStudioInstance $VisualStudioInstance
        if ($ExitCode -ne 0) {
            switch($ExitCode) {
                2003 {Write-Warning "${ExtensionName} is already installed for $($VisualStudioInstance.DisplayName)."} # Not really sure that this code stands for that
                default {Write-Error "VSIXInstaller exited with status code: '$($process.ExitCode)'"}
            }
        }
        else {
            Write-Success "Installed ${ExtensionName} extension for $($VisualStudioInstance.DisplayName)"; 
        }
    }
    catch {
        Write-Error "Error while installing ${ExtensionName} extension for $($VisualStudioInstance.DisplayName)"; 
        throw $_
    }
    finally {
        Remove-Item $File -Force
    }
}

function Import-VisualStudioSettingsFile {
    [CmdletBinding()]
    param(
        [ValidateNotNull()][Microsoft.VisualStudio.Setup.Instance] $VisualStudioInstance,
        [ValidateNotNullOrEmpty()][string] $PathToSettingsFile,
        [int] $SecondsToSleep = 20 # should be enough for most machines
    )
    $DevEnvExe = $VisualStudioInstance.InstallationPath + "\Common7\IDE\devenv.exe";
    if (-not (Test-Path $DevEnvExe)) {
        Write-Error "Could not find $($VisualStudioInstance.DisplayName) devenv.exe at: ${DevEnvExe}"
        return
    }

    if (-not (Test-Path $PathToSettingsFile)) {
        Write-Error "Could not find settings file at: $PathToSettingsFile"
        return
    }

    try {
        Write-Information "Importing $($VisualStudioInstance.DisplayName) settings from ${PathToSettingsFile}..."
        $Args = "/Command `"Tools.ImportandExportSettings /import:$PathToSettingsFile`""
        $Process = Start-Process -FilePath $DevEnvExe -ArgumentList $Args -Passthru -WindowStyle Hidden
        Start-Sleep -Seconds $SecondsToSleep #hack: couldnt find a way to exit when done
        $Process.Kill()
        Write-Success "Imported $($VisualStudioInstance.DisplayName) settings successfully"
    }
    catch {
        Write-Error "Error occurred while importing $($VisualStudioInstance.DisplayName) settings"
        throw $_
    }
}

function Get-VisualStudio-Instance {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()][string] $VisualStudioVersionName
    )
    $script:Instances = Get-VSSetupInstance
    return $Instances | Where-Object { $_.DisplayName -eq $VisualStudioVersionName } | Select-Object -First 1
}

Set-Location '..\VisualStudio\'
$configurations = Get-Content '.\configuration.json' | Out-String | ConvertFrom-Json

foreach ($configuration in $configurations) {
    $Instance = Get-VisualStudio-Instance -VisualStudioVersionName $configuration.visualStudioVersion
    if($null -eq $Instance) {
        $ErrorMsg = "Couldn't locate installed $($configuration.visualStudioVersion). "
        $InstancesCount = ($Instances | Measure-Object).Count
        if($InstancesCount -eq 0) {
            $ErrorMsg += "None versions were located."
        } else {
            $ErrorMsg += "Located following versions: "
            $ErrorMsg += $Instances.DisplayName -join ", "
        }
        Write-Error $ErrorMsg
        continue
    }

    Import-VisualStudioSettingsFile -VisualStudioInstance $Instance -PathToSettingsFile $configuration.settingsFile
    foreach ($ExtensionToInstall in $configuration.extensions) {
        Install-Vsix -ExtensionName $ExtensionToInstall -VisualStudioInstance $Instance
    }
}