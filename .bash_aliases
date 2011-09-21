#! /bin/bash
# (just to make vim color the file)

alias sshl="ssh frontend-mike2.office.loggly.net"
alias sshp="ssh frontend1.prod.loggly.net"
alias sshp2="ssh frontend2.prod.loggly.net"
alias sshh="ssh frontend1.hoover.loggly.net"
alias sshm="ssh frontend-marie1.office.loggly.net"
alias sshi="ssh frontend-ivan1.office.loggly.net"

alias make-deb="sudo chown mike:mike /opt/loggly/web;make deb SVN=\"git svn\""
alias puball="ssh build.loggly.org 'ls | grep -v tmp | xargs publish.sh; ls | grep -v tmp | xargs rm; exit'"

alias vbash="vim ~/.bashrc"
alias sbash="source ~/.bashrc"

alias loggly="cd /opt/loggly/web/app"
alias home="cd /home/mike/"
alias infra="cd /home/mike/workspace/infra"
alias deploy="cd /home/mike/workspace/deployments"
alias www="cd /var/www/optimize"

alias dshell="loggly; python -Qwarnall manage.py shell_plus"
alias runs="loggly; sudo python -Qwarnall manage.py runserver_plus 0.0.0.0:80"
alias ltail="cd /mnt/log/loggly/frontend/; tail -f loggly"

alias apstart="sudo /etc/init.d/apache2 start"
alias apstop="sudo /etc/init.d/apache2 stop"
alias apres="sudo /etc/init.d/apache2 restart"

alias g="git"

alias aoeu="setxkbmap us"
alias asdf="setxkbmap dvorak"

alias node="env NODE_NO_READLINE=1 rlwrap node"
alias pypy="~/Downloads/pypy-c-jit-43780-b590cf6de419-linux64/bin/pypy"
alias pypy-ei="~/Downloads/pypy-c-jit-43780-b590cf6de419-linux64/bin/easy_install"

alias vpn="cd ~/vpnconf; sudo openvpn openvpn.conf"

alias mine="sudo chown -R $USER:$USER ."
