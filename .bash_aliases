#! /bin/bash
# (just to make vim color the file)

alias ssh="ssh -X"
alias sshl="ssh app-mike.loggly.org"
alias sshp="ssh frontend1.prod.loggly.net"
alias sshp2="ssh frontend2.prod.loggly.net"

alias make-deb="sudo chown mike:mike /opt/loggly/web;make deb SVN=\"git svn\""
alias puball="ssh build.loggly.org 'ls | grep -v tmp | xargs publish.sh; ls | grep -v tmp | xargs rm; exit'"

alias vbash="vim ~/.bashrc"
alias sbash="source ~/.bashrc"

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

alias resh="res --hard"
alias reb="g rebase remotes/trunk"
alias pull="fetch; merge remotes/trunk"
alias col="co collection; pull"
alias master="co master; sreb"
alias prepush="branch -D master; co -b master; g rebase -i --onto remotes/trunk mergebase"
alias rebc="g rebase --continue"
alias mb="branch -D mergebase; branch mergebase"
alias recol="branch -D mergebase oldc; co -b mergebase remotes/trunk; branch --no-merged | grep -v collection | grep -v nm- | xargs git merge; col; branch oldc; g rebase -i mergebase; dif oldc;"

