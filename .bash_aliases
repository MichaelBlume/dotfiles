#! /bin/bash
# (just to make vim color the file)

alias ssh="ssh -X"
alias sshl="ssh app-mike.loggly.org"
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
alias infra="cd /home/mike/workspace/loggly_infra"
alias www="cd /var/www/optimize"

alias dshell="loggly; python -Qwarnall manage.py shell_plus"
alias runs="loggly; sudo python -Qwarnall manage.py runserver_plus 0.0.0.0:80"
alias ltail="cd /mnt/log/loggly/frontend/; tail -f loggly"

alias apstart="sudo /etc/init.d/apache2 start"
alias apstop="sudo /etc/init.d/apache2 stop"
alias apres="sudo /etc/init.d/apache2 restart"

alias g="git"
