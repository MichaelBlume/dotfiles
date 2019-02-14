#! /bin/bash
# (just to make vim color the file)

alias vbash="vim ~/.bashrc"
alias sbash="source ~/.bashrc"

alias g="git"

alias aoeu="setxkbmap us"
alias asdf="setxkbmap dvorak"

alias mine="sudo chown -R $USER:$USER ."

alias mvns="mvn -Dmaven.test.skip=true"

alias killplay='ps aux | grep play.server.Server | grep -v grep | tr -s " " | cut -f2 -d " " | xargs kill -9'
