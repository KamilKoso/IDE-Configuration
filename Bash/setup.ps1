
function Test-IsAdministrator {
     return ([Security.Principal.WindowsPrincipal]`
             [Security.Principal.WindowsIdentity]::GetCurrent()`
     ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
 }

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
          Write-Information "Winget is already installed. Skipping step."
          return;
     }

     Write-Information "Installing Winget"
     #test for requirement
     $Requirement = Get-AppPackage "Microsoft.DesktopAppInstaller"
     if (-Not $requirement) {
         Write-Information "Installing Desktop App Installer"
         Try {
             Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -erroraction Stop
         }
         Catch {
             Throw $_
         }
     }
 
     $uri = "https://api.github.com/repos/microsoft/winget-cli/releases"
         $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
         $data = $get[0].assets | Where-Object name -Match 'msixbundle'
         $appx = $data.browser_download_url
         Write-Verbose "[$((Get-Date).TimeofDay)] $appx"
         If ($pscmdlet.ShouldProcess($appx, "Downloading asset")) {
             $file = Join-Path -path $env:temp -ChildPath $data.name
 
             Write-Verbose "[$((Get-Date).TimeofDay)] Saving to $file"
             Invoke-WebRequest -Uri $appx -UseBasicParsing -DisableKeepAlive -OutFile $file
 
             Write-Verbose "[$((Get-Date).TimeofDay)] Adding Appx Package"
             Add-AppxPackage -Path $file -ErrorAction Stop
 
             if ($passthru) {
                 Get-AppxPackage microsoft.desktopAppInstaller
             }
         }
 }

 function Write-Information {
     [CmdletBinding()]
     param  
     (  
          [Parameter(Mandatory = $true, Position=0)][ValidateNotNullOrEmpty()][string]$InformationMessage  
     )  
     Write-Host (Get-Date) "[Information]" $InformationMessage -ForegroundColor Blue
 }

function Install-Font {
     [CmdletBinding()]
     param  
     (  
          [Parameter(Mandatory = $true, Position=0)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$FontFile  
     )  
      
     #Get Font Name from the File's Extended Attributes  
     $oShell = new-object -com shell.application  
     $Folder = $oShell.namespace($FontFile.DirectoryName)  
     $Item = $Folder.Items().Item($FontFile.Name)  
     $FontName = $Folder.GetDetailsOf($Item, 21)  
     try {  
          switch ($FontFile.Extension) {  
               ".ttf" { $FontName = $FontName + [char]32 + '(TrueType)' }  
               ".otf" { $FontName = $FontName + [char]32 + '(OpenType)' }  
          }  
          $Copy = $true  
          Write-Host ('Copying' + [char]32 + $FontFile.Name + '.....') -NoNewline  
          Copy-Item -Path $fontFile.FullName -Destination ("C:\Windows\Fonts\" + $FontFile.Name) -Force  
          #Test if font is copied over  
          If ((Test-Path ("C:\Windows\Fonts\" + $FontFile.Name)) -eq $true) {  
               Write-Host ('Success') -Foreground Yellow  
          }
          else {  
               Write-Host ('Failed') -ForegroundColor Red  
          }  
          $Copy = $false  
          #Test if font registry entry exists  
          If ((Get-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue) -ne $null) {  
               #Test if the entry matches the font file name  
               If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {  
                    Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline  
                    Write-Host ('Success') -ForegroundColor Yellow  
               }
               else {  
                    $AddKey = $true  
                    Remove-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Force  
                    Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline  
                    New-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
                    If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {  
                         Write-Host ('Success') -ForegroundColor Yellow  
                    }
                    else {  
                         Write-Host ('Failed') -ForegroundColor Red  
                    }  
                    $AddKey = $false  
               }  
          }
          else {  
               $AddKey = $true  
               Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline  
               New-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
               If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {  
                    Write-Host ('Success') -ForegroundColor Yellow  
               }
               else {  
                    Write-Host ('Failed') -ForegroundColor Red  
               }  
               $AddKey = $false  
          }  
           
     }
     catch {  
          If ($Copy -eq $true) {  
               Write-Host ('Failed') -ForegroundColor Red  
               $Copy = $false  
          }  
          If ($AddKey -eq $true) {  
               Write-Host ('Failed') -ForegroundColor Red  
               $AddKey = $false  
          }  
          write-warning $_.exception.message  
     }  
     Write-Host  
}  

function Install-Windows-Terminal {
     $WindowsTerminalId="Microsoft.WindowsTerminal"
     Write-Information "Installing Windows Terminal..."
     winget install --id=$WindowsTerminalId -e
     Copy-Item settings.json $ENV:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState
     Copy-Item .bashrc $ENV:USERPROFILE
}
     
function Install-PowerLine {
     $InstallationFolder = $HOME + "\.bash\themes\git_bash_windows_powerline"
     if(Test-Path $InstallationFolder) {
          Write-Information "Powerline is already installed. Skipping step..."
     }
     Write-Information "Installing PowerLine..."
     git clone https://github.com/diesire/git_bash_windows_powerline.git $InstallationFolder
}
     
function Install-Fonts {
     $FontName = "JetBrains Mono NL Regular Nerd Font Complete.ttf"
     Write-Information ("Installing " + $FontName + " font...")
     $FontUrl = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/complete/JetBrains%20Mono%20NL%20Regular%20Nerd%20Font%20Complete.ttf"
     Invoke-RestMethod -Uri $FontUrl -OutFile $FontName
     Install-Font (Get-Item $FontName)
     Remove-Item $FontName
}

function Install-Lsd {
     # Install scoop if not installed
     if (![bool](Get-Command -Name 'scoop' -ErrorAction SilentlyContinue)) {
          Write-Information "Installing scoop..."
          Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
          Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
      } else {
          Write-Information "Scoop is already installed, trying to update instead..."
          Invoke-Expression "scoop update"
      }
      # Install lsd if not installed
      if(Test-Path "~\scoop\apps\lsd") {
          Write-Information "Lsd is already installed, trying to update instead..."
          Invoke-Expression "scoop update lsd"
      } else {
            Write-Information "Installing lsd..."
           Invoke-Expression "scoop install lsd"
      }

}




if ((Test-IsAdministrator) -eq $false) {
     if ($elevated) {
          # tried to elevate, did not work, aborting
     }
     else {
          Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile', '-noexit', ('-file "{0}"' -f $myinvocation.MyCommand.Definition), '-elevated')
     }
     exit
}

Set-Location -Path $PSScriptRoot
Install-WinGet
Install-Windows-Terminal
Install-PowerLine
Install-Fonts
Install-Lsd




