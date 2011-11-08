# ~/.bashrc: executed by bash(1) for non-login shells.

GIT=`which git`
function parse_git_branch {
      $GIT branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1] /'
}

export PS1='\h:\w$(parse_git_branch)\$ '
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
alias runserverssl='sudo stunnel4; HTTPS=on sudo /opt/loggly/web/app/manage.py runserver_plus 0.0.0.0:443'
alias runserver='sudo /opt/loggly/web/app/manage.py runserver_plus 0.0.0.0:80'
alias loggly='cd $LOGGLY_APP'

alias rungunicorn='sudo /opt/loggly/web/app/manage.py run_gunicorn --traceback --bind 0.0.0.0:80 --workers 3'

export EDITOR=/usr/bin/vim
export SVN_EDITOR=/usr/bin/vim
export GREP_OPTIONS='--color=auto'


