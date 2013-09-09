#! /bin/bash
# (just to make vim color the file)

alias make-deb="sudo chown mike:mike /opt/loggly/web;make deb SVN=\"git svn\""
alias puball="ssh build.loggly.org 'ls | grep -v tmp | xargs publish.sh; ls | grep -v tmp | xargs rm; exit'"

alias vbash="vim ~/.bashrc"
alias sbash="source ~/.bashrc"

alias g="git"

alias aoeu="setxkbmap us"
alias asdf="setxkbmap dvorak"

alias mine="sudo chown -R $USER:$USER ."

alias mvns="mvn -Dmaven.test.skip=true"
