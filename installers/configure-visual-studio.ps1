Set-Location $PSScriptRoot;
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module VSSetup -Scope CurrentUser
Import-Module ./modules/test-is-admin.psm1 -DisableNameChecking
Import-Module ./modules/messages.psm1 -DisableNameChecking
Import-Module ./modules/download-from-github.psm1 -DisableNameChecking

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

    if ($process.ExitCode -ne 0) {
        throw "VSIXInstaller exit code: '$($process.ExitCode)'"
    }
}

function Install-Vsix {
    [cmdletbinding()]
    Param(
        [ValidateNotNullOrEmpty()][Parameter(Mandatory = $true, Position = 0)][string]$Author,
        [ValidateNotNullOrEmpty()][Parameter(Mandatory = $true, Position = 1)][string]$RepoName,
        [ValidateNotNullOrEmpty()][Parameter(Mandatory = $true, Position = 2)][string]$PackageToDownload,
        [ValidateNotNull()][Parameter(Mandatory = $true, Position = 3)][Microsoft.VisualStudio.Setup.Instance]$VisualStudioInstance
    )
    Write-Information "Installing ${RepoName} $($VisualStudioInstance.DisplayName) extension..."; 
    $File = Download-From-Github -Author $Author -RepoName $RepoName -PackageToDownload $PackageToDownload

    try {
        Invoke-VsixInstaller -File $File -VisualStudioInstance $VisualStudioInstance
        Write-Success "Installed ${RepoName} $($VisualStudioInstance.DisplayName) extension"; 
    }
    catch {
        Write-Error "Error while installing ${RepoName} $($VisualStudioInstance.DisplayName) extension"; 
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
        [ValidateNotNullOrEmpty()][string] $PathToSettingsFile = '..\VisualStudio\VS_2022.vssettings',
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
    $Instances = Get-VSSetupInstance
    $InstancesCount = ($Instances | Measure-Object).Count
    if ($InstancesCount -eq 0) {
        Write-Error "Couldn't find any Visual Studio instance installed"
        throw "Couldn't find any Visual Studio instance installed"
    }
    elseif ($InstancesCount -eq 1) {
        $script:Instance = ($Instances | Select-VSSetupInstance -Latest)
    }
    else {
        $Instances | Format-Table -Property InstanceId, @{N = 'Name'; E = { $_.DisplayName } }, @{N = 'Version'; E = { $_.InstallationVersion } }, @{N = 'Installation path'; E = { $_.InstallationPath } }, @{N = 'Installation date'; E = { $_.InstallDate } }
        $SelectedValue = Read-Host "Write InstanceId or Name of Visual Studio that you want to configure"
    
        $script:Instance = $Instances | Where-Object { $_.InstanceId -eq $SelectedValue -or $_.DisplayName -eq $SelectedValue } | Select-Object -First 1
        if ($null -eq $Instance) {
            Write-Error "Couldn't find provided instance, try again."
            Get-VisualStudio-Instance
        }
    }
}

Get-VisualStudio-Instance
Import-VisualStudioSettingsFile -VisualStudioInstance $Instance
Install-Vsix -Author "codecadwallader" -RepoName "codemaid" -PackageToDownload "VS2022.*.vsix" -VisualStudioInstance $Instance
Install-Vsix -Author "madskristensen" -RepoName "AddAnyFile" -PackageToDownload "vsix" -VisualStudioInstance $Instance