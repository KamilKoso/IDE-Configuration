# IDE Configuration
Simple set of scripts to automate IDE configuration process. Configuration is defined in ``configuration.json`` file and description is defined under [Configuration](https://github.com/KamilKoso/IDE-Configuration#Configuration) section

## Installation
Easiest way to install anything you need is to run ``all-in-one-installer`` with admin privileges. But if you want install something manually there are instructions below.

**Do not close powershell when script is running, this may cause malfunctions in the system i.e. registry corruption, Visual Studio errors and more ❗**

## Configuration

### Visual Studio:
- ``visualStudioVerison`` - For which visual studio version configuration should be applied
- ``settingsFile`` - Location of settings file that will be applied, can be absolute or relative path
- ``extensions`` - Extensions that will be installed. Extensions are downloaded from [Visual Studio Marketplace](https://marketplace.visualstudio.com/). They should be denifed in the given format {Author}.{PackageName}, easiest way to grab correct format is to copy ``itemName`` query parameter from the [Visual Studio Marketplace](https://marketplace.visualstudio.com/) site (e.g. for [CodeMaid Extension](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid) correct format would be "SteveCadwallader.CodeMaid")

### Pimped Bash
- ``bashrcPath`` - Location of .bashrc file, can be absolute or relative path
- ``windowsTerminalSettingsPath`` - Location of Windows Terminal settings file, can be absolute or relative path
- `installLsd` - A flag whether or not install [lsd](https://github.com/Peltoche/lsd)
- `installPowerline` - A flag whether or not install [powerline](https://github.com/diesire/git_bash_windows_powerline)
- ``fontsToInstall`` - Array of object specyfing which fonts to install
  - ``fontName`` - Name under which font will be installed
  - ``fontDownloadUri`` - Download uri for the font

### Tools
- ``powerToys``
  - ``settingsPath`` - Location of PowerToys settings file, can be absolute or relative path

## Manual installation

### Pimped Bash
<img src="https://raw.githubusercontent.com/KamilKoso/IDE-Configuration/master/assets/pimped-bash.png">

1. Install [Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal-preview/9N8G5RFZ9XK3)
2. Install [JetBrains Mono NL Regular Nerd Font Complete](https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/complete/JetBrains%20Mono%20NL%20Regular%20Nerd%20Font%20Complete.ttf) font
3. Install [scoop](https://scoop.sh/)
4. Install [powerline](https://github.com/diesire/git_bash_windows_powerline)
5. Install [lsd](https://github.com/Peltoche/lsd)
6. Copy ``settings.json`` to ``%USERPROFILE%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState``
7. Copy ``.bashrc`` to ``%USERPROFILE%``

### Visual Studio
<img src="https://raw.githubusercontent.com/KamilKoso/IDE-Configuration/master/assets/VisualStudio-Icon.png" width="20%">

1. Install [Visual Studio](https://visualstudio.microsoft.com/pl/)
2. Open it and import settings (under Tools -> Import and Export settins)
3. Install desired extensions (e.g. [CodeMaid](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid), [Add New File](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.AddNewFile64))

### Power Toys
<img src="https://raw.githubusercontent.com/KamilKoso/IDE-Configuration/master/assets/powertoys-icon.png" width="20%">

1. Install [PowerToys](https://apps.microsoft.com/store/detail/microsoft-powertoys/XP89DCGQ3K6VLD)
2. Go to ``%LOCALAPPDATA%\Microsoft\PowerToys``
3. Replace ``settings.json``
