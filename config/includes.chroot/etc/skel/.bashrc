# CFL Forensics bashrc - hand over to zsh (macOS-style default shell) when interactive.
if [ -t 1 ] && [ -z "$ZSH_VERSION" ] && [ -z "$CFLFORENSICS_NO_ZSH" ] && [ -x /usr/bin/zsh ]; then
    export SHELL=/usr/bin/zsh
    exec /usr/bin/zsh -l
fi

alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias df='df -h'
