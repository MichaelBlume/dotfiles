# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# source system bashrc -- for some reason our puppet etc/profile skips this
[ -f /etc/bash.bashrc ] && source /etc/bash.bashrc

# Add home bin to path
export PATH=/home/mike/bin:/usr/local/git/bin:/Users/mike/bin:/home/mike/.cabal/bin:/Users/mike/Library/Haskell/bin/:/opt/loggly/web/app/bin:/usr/local/bin:$PATH:/home/mike/workspace/google_appengine:/home/mike/workspace/js2coffee/bin:/var/lib/gems/1.8/bin:/Users/mike/Downloads/storm-0.8.1/bin

# Complete Me
source /usr/local/bin/setup_completeme_key_binding.sh

# Try to set JAVA_HOME
export JAVA_HOME=`/usr/libexec/java_home -v 1.7 2> /dev/null`

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

#My additions:

#Ignore certain suffixes for purposes of completion

export FIGNORE=".hi:.o"


export EDITOR=vim
export PYTHONPATH="$PYTHONPATH:/home/mike/lib/python/"

# Git tab completion
if [ -f ~/workspace/git/contrib/completion/git-completion.bash ]; then
    source ~/workspace/git/contrib/completion/git-completion.bash
elif [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
fi

#complete -o default -o nospace -F _git g
__git_complete g _git

# Set Vim home
#export VIM=/home/mike/.vim

if [ -a /home/mike/bin/hub ];
then
    alias git=hub;
fi



set -o vi

source ~/.git-prompt.sh
function proml {
  local        BLUE="\[\033[0;34m\]"
  local         RED="\[\033[0;31m\]"
  local       GREEN="\[\033[0;32m\]"
  case $TERM in
    xterm*)
    TITLEBAR='\[\033]0;\u@\h:\w\007\]'
    ;;
    *)
    TITLEBAR=""
    ;;
  esac

PS1="${TITLEBAR}\
$BLUE[$RED\$(date +%H:%M)$BLUE]\
$BLUE[$RED\u@\h:\w$GREEN\$(__git_ps1 '(%s)')$BLUE]\
$GREEN\$ "
PS2='> '
PS4='+ '
}
proml
export GIT_PS1_SHOWDIRTYSTATE=yes
