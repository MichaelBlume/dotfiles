# ~/.bashrc: executed by bash(1) for non-login shells.

export PS1='\h:\w\$ '
umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
alias l='ls -asl'
alias ls='/bin/ls --color'

# Loggly stuff
export LOGGLY_APP='/opt/loggly/web/app'
alias runserverssl='sudo stunnel4; HTTPS=on sudo $LOGGLY_APP/manage.py runserver_plus 0.0.0.0:443 --settings settingsdebug'
alias runserver='sudo $LOGGLY_APP/manage.py runserver_plus 0.0.0.0:80 --settings settingsdebug'
alias loggly='cd $LOGGLY_APP'
alias labs='cd /opt/loggly/labs/app'

export EDITOR=/usr/bin/vim
export SVN_EDITOR=/usr/bin/vim
export GREP_OPTIONS='--color=auto'


