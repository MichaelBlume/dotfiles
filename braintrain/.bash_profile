
# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH
alias ll="ls -la"
set -o vi
bind -m vi-command L:end-of-line
bind -m vi-command H:vi-first-print


#aliases
alias svmb="echo 'logging into braintrain@10.0.20.133'; ssh braintrain@10.0.20.133"
alias svmh="echo 'logging into hoover@10.0.20.133'; ssh hoover@10.0.20.133"
alias bedit="vi ~/.bash_profile"
alias rh="echo 'sourcing bash profile'; source ~/.bash_profile"
alias stop="cd ~/src"

if [ -d /opt/loggly/web/app ]; then
    cd /opt/loggly/web/app/
fi

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function proml {
  local        BLUE="\[\033[0;34m\]"
  local         RED="\[\033[0;31m\]"
  local   LIGHT_RED="\[\033[1;31m\]"
  local       GREEN="\[\033[0;32m\]"
  local LIGHT_GREEN="\[\033[1;32m\]"
  local       WHITE="\[\033[1;37m\]"
  local  LIGHT_GRAY="\[\033[0;37m\]"
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
$BLUE[$RED\u@\h:\w$GREEN\$(parse_git_branch)$BLUE]\
$GREEN\$ "
PS2='> '
PS4='+ '
}
proml

