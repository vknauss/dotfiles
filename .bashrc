#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# common options for ls
alias ls='ls --color=auto'

alias grep='grep --color=auto'

# set prompt
PS1='\[\e[0m\][ \[\e[0;38;5;33m\]\w \[\e[0m\]]\n\[\e[0;38;5;40m\]\u\[\e[0m\]@\[\e[0;95m\]\H \[\e[0;38;5;220m\]\$ \[\e[0m\]' 

# use nvim as vim and vi
alias vi=nvim
alias vim=nvim

# use wayland in firefox
# export MOZ_ENABLE_WAYLAND=1
# export MOZ_DISABLE_RDD_SANDBOX=1

# make qt applications run in wayland
# export QT_QPA_PLATFORM=wayland
# export QT_AUTO_SCREEN_SCALE_FACTOR=1

# set gtk theme
# export GTK_THEME=Arc-Dark

#export XDG_CURRENT_DESKTOP=sway

# pipe sway outputs to log files
SWAY_LOG=$HOME/logs/sway.log
SWAY_ERR_LOG=$HOME/logs/sway.err.log

alias sway='sway 2> $SWAY_ERR_LOG > $SWAY_LOG'

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
