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
alias runserver='sudo stunnel4; HTTPS=on sudo /opt/loggly/web/app/manage.py runserver_plus 0.0.0.0:443 --settings settingsdebug; sudo /opt/loggly/web/app/manage.py runserver_plus 0.0.0.0:80 --settings settingsdebug'
alias loggly='cd /opt/loggly/web/app'
alias labs='cd /opt/loggly/labs/app'
alias rm='rm -i'
function sgrep() { grep -r "$@" | grep -v svn | grep -v migration; }
#alias grep='grep \$* | grep -v svn'
alias model='./manage.py graph_models -a -g > model.dot'
alias r='/etc/init.d/apache2 restart'
alias sd='svn diff --diff-cmd=/root/bin/svn_diff.sh'
alias ip='curl http://whatismyip.org; echo'
alias st='svn status /opt/loggly/base; svn status /opt/loggly/web; svn status /opt/loggly/proxy'
alias sc='cat /tmp/svn.notes'
alias se='vim /tmp/svn.notes'


set -o vi
export PATH=/root/bin:$PATH
export EDITOR=vi
export SVN_EDITOR=vi
#export SVN_EDITOR="cat /tmp/svn.notes > /tmp/svn.commit && cat svn-commit.tmp >> /tmp/svn.commit && mv /tmp/svn.commit svn-commit.tmp && vim "
export GREP_OPTIONS='--color=auto'
export dumphttp='tcpdump -As 0 -nnli eth0 dst port 80'
#alias vi="vim -c \"resize:12\" -c \"exe 2 . 'wincmd w'\" -o2 /tmp/svn.notes" 

# check out branch
# svn checkout https://loggly.unfuddle.com/svn/loggly_server/branches/ram/web web --username raffy

# edit ignore properties:
# svn propedit svn:ignore <path>

# copy branch
# svn copy https://loggly.unfuddle.com/svn/loggly_server/trunk https://loggly.unfuddle.com/svn/loggly_server/branches/ram -m 'Creating a branch for upgrading Django to 1.2'

# South migration:
# python manage.py startmigration customer tier_info --auto
# python manage.py migrate

# mysql -u root -p
# use django
# delete from south_migrationhistory;
# svn remove {invite,input,repo,signup,registration,customer,device}/migrations/*.py --force
# for app in invite input repo signup device registration customer; do ./manage.py startmigration $app --initial; done

