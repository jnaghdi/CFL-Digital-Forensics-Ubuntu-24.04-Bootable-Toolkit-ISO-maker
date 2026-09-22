# CFL Forensics zsh configuration
autoload -Uz colors && colors

PROMPT='%F{white}%n@%m%f %F{blue}%1~%f %# '

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY HIST_IGNORE_DUPS EXTENDED_HISTORY
bindkey -e

alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias please='sudo'

# forensic shortcuts
alias forensic-on='sudo forensics-mode on'
alias forensic-off='sudo forensics-mode off'
alias tools='cfl-tools'

echo "CFL Forensics 1.0 - type 'cfl-tools' for the tool inventory, 'forensics-mode on' before attaching evidence."
