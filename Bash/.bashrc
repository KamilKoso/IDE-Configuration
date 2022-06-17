# Theme
THEME=$HOME/.bash/themes/git_bash_windows_powerline/theme.bash
if [ -f $THEME ]; then
   . $THEME
fi
unset THEME

# Alliases
# alias ls='lsd' 
alias ls='TERM=dumb lsd' # https://github.com/Peltoche/lsd/issues/657 - Issue with crossterm