# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Add home bin to path
export PATH=/home/mike/bin/:$PATH:/home/mike/workspace/google_appengine

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

export EDITOR=vim
export PYTHONPATH=/home/mike/lib/python/

# Git tab completion
source ~/.git-completion.bash

# Set Vim home
#export VIM=/home/mike/.vim

if [ -a /home/mike/bin/hub ];
then
    alias git=hub;
fi

alias ssh="ssh -X"
alias sshl="ssh app-mike.loggly.org"
alias sshp="ssh frontend1.prod.loggly.net"
alias sshp2="ssh frontend2.prod.loggly.net"

alias make-deb="sudo chown mike:mike /opt/loggly/web;make deb SVN=\"git svn\""
alias puball="ssh build.loggly.org 'ls | grep -v tmp | xargs publish.sh; ls | grep -v tmp | xargs rm; exit'"

alias loggly="cd /opt/loggly/web/app"
alias home="cd /home/mike/"
alias infra="cd /home/mike/workspace/loggly_infra"
alias www="cd /var/www/optimize"

alias dshell="loggly; python manage.py shell_plus"
alias runs="loggly; sudo python manage.py runserver_plus 0.0.0.0:80"
alias ltail="cd /mnt/log/loggly/frontend/; tail -f loggly"

alias apstart="sudo /etc/init.d/apache2 start"
alias apstop="sudo /etc/init.d/apache2 stop"
alias apres="sudo /etc/init.d/apache2 restart"

alias g="git"

alias com="g commit"
alias add="g add"
alias dif="g diff"
alias res="g reset"
alias co="g checkout"
alias branch="g branch"
alias merge="g merge"
alias st="g status"

alias push="g svn dcommit"
alias sreb="g svn rebase"
alias fetch="g svn fetch"

alias reb="g rebase remotes/trunk"
alias pull="fetch; merge remotes/trunk"
alias col="co collection"
alias master="co master; sreb"
alias prepush="branch -D master; co -b  master; g rebase -i --onto remotes/trunk mergebase"
alias rebc="g rebase --continue"
alias mb="branch -D mergebase; branch mergebase"
alias recol="col; pull; branch -D mergebase oldc; branch oldc; res --hard remotes/trunk; branch --no-merged | grep -v oldc | grep -v nm- | xargs git merge; branch mergebase; dif oldc;"


set -o vi

cd /opt/loggly/web/app/
