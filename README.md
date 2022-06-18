# IDE Configuration
Simple set of scripts to automate IDE configuration.

## Installation
Easiest way to install anything you need is to run ``all-in-one-installer`` with admin privileges. But if you want install something manually there are instructions below.


**Do not close powershell when script is running, this may cause malfunctions in the system i.e. registry corruption, Visual Studio errors and more ❗**

## Pimped Bash
<img src="https://raw.githubusercontent.com/KamilKoso/IDE-Configuration/master/assets/pimped-bash.png">

### Manual installation
1. Install [Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal-preview/9N8G5RFZ9XK3)
2. Install [JetBrains Mono NL Regular Nerd Font Complete](https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/complete/JetBrains%20Mono%20NL%20Regular%20Nerd%20Font%20Complete.ttf) font
3. Install [scoop](https://scoop.sh/)
4. Install [powerline](https://github.com/diesire/git_bash_windows_powerline)
5. Install [lsd](https://github.com/Peltoche/lsd)
6. Copy ``settings.json`` to ``%USERPROFILE%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState``
7. Copy ``.bashrc`` to %USERPROFILE%

# Visual Studio
<img src="https://raw.githubusercontent.com/KamilKoso/IDE-Configuration/master/assets/VisualStudio-Icon.png" width="20%">

### Manual installation
1. Install [Visual Studio](https://visualstudio.microsoft.com/pl/)
2. Open it and import settings (under Tools -> Import and Export settins)
3. Install desired extensions (e.g. [CodeMaid](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid), [Add New File](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.AddNewFile64))

# Power Toys
<img src="https://raw.githubusercontent.com/KamilKoso/IDE-Configuration/master/assets/powertoys-icon.png" width="20%">

### Manual installation
1. Install [PowerToys](https://apps.microsoft.com/store/detail/microsoft-powertoys/XP89DCGQ3K6VLD)
2. Go to %LOCALAPPDATA%\Microsoft\PowerToys
3. Replace settings.json