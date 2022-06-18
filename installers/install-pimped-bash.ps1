# Imports
Set-Location $PSScriptRoot;
Import-Module ./modules/test-is-admin.psm1 -DisableNameChecking
Import-Module ./modules/messages.psm1 -DisableNameChecking

function Install-Windows-Terminal {
     if (![bool](Get-Command -Name 'wt.exe' -ErrorAction SilentlyContinue)) {
          Write-Information "Installing Windows Terminal..."
          winget install --id=Microsoft.WindowsTerminal -e
          Write-Success "Instaled Windows Terminal"
     }
     else {
          Write-Information "Windows Terminal already installed. Skipping step..."
     }

     Copy-Item settings.json $ENV:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState
     Copy-Item .bashrc $ENV:USERPROFILE
}
     
function Install-PowerLine {
     $InstallationFolder = $HOME + "\.bash\themes\git_bash_windows_powerline"
     if (Test-Path $InstallationFolder) {
          Write-Information "Powerline is already installed. Skipping step..."
          return
     }
     Write-Information "Installing PowerLine..."
     git clone https://github.com/diesire/git_bash_windows_powerline.git $InstallationFolder
     Write-Success "Installed PowerLine"
}
     
function Install-Font {
     $FontName = "JetBrains Mono NL Regular Nerd Font Complete.ttf"
     $FontFile = Join-Path  $ENV:TEMP -ChildPath $FontName
     Write-Host $FontFile;
     $FontsPath = "$env:windir\Fonts"
     $TargetPath = Join-Path $FontsPath $FontName
     if (Test-Path $TargetPath) {
          Write-Information ($FontName + " is already installed. Skipping step.")
          return
     }
     try {
          Write-Information ("Installing " + $FontName + " font...")
          $FontUrl = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/complete/JetBrains%20Mono%20NL%20Regular%20Nerd%20Font%20Complete.ttf"
          Invoke-WebRequest -Uri $FontUrl -OutFile $FontFile
          $ShellFolder = (New-Object -COMObject Shell.Application).Namespace($FontsPath)
          $ShellFile = $shellFolder.ParseName($FontFile)
          $ShellFileType = $shellFolder.GetDetailsOf($shellFile, 2)
          #Set the $FontType Variable
          If ($ShellFileType -Like '*TrueType font file*') {
               $FontType = '(TrueType)'
          }
          #Update Registry and copy font to font directory
          $RegName = $shellFolder.GetDetailsOf($shellFile, 21) + ' ' + $FontType
          New-ItemProperty -Name $RegName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontName -Force | out-null
          Copy-item $FontFile -Destination $FontsPath
          Write-Success ("Instaled " + $FontName + " font")
     }
     catch {
          Write-Error "Error occured while installing font"
          throw $_
     }
     finally {
          Remove-Item $FontFile -Force
     }
}

function Install-Lsd {
     # Install scoop if not installed
     if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
          Write-Information "Installing scoop..."
          Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
          Invoke-Expression "& {$(Invoke-WebRequest get.scoop.sh)} -RunAsAdmin"
          Write-Success "Installed scoop"
     }
     else {
          Write-Information "Scoop is already installed, trying to update instead..."
          Invoke-Expression "scoop update"
     }
     # Install lsd if not installed
     if (Test-Path "~\scoop\apps\lsd") {
          Write-Information "Lsd is already installed, trying to update instead..."
          Invoke-Expression "scoop update lsd"
     }
     else {
          Write-Information "Installing lsd..."
          Invoke-Expression "scoop install lsd"
          Write-Success "Installed lsd"
     }

}

# Check adming rights
if ((Test-Is-Admin) -eq $false) {
     if (!$elevated) {
          Write-Warning "This script requires admin prvileges. Grant it in order to continue."
          Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile', '-noexit', ('-file "{0}"' -f $myinvocation.MyCommand.Definition), '-elevated')
     }
     exit
}

Set-Location '..\Bash'
Install-Windows-Terminal
Install-PowerLine
Install-Font
Install-Lsd




