#basic options
setopt autocd
autoload -U compinit promptinit
compinit
promptinit

#PATH
#export PATH=$PATH:/usr/local/lib/node_modules/npm/bin/:/usr/local/lib/node_modules/coffee-script/bin/

#alias
alias ez="vim ~/.zshrc"
alias stop="cd ~/src"
alias ll="ls -l"
alias rh="echo 'sourcing ~/.zshrc';source ~/.zshrc"
alias node='/usr/local/bin/node'
#adding hostname
export PROMPT='$%M:%/ '

#ssh DEV and BUILD
#alias svm="ssh -v 10.0.20.82" 
alias sbuild="ssh -v build.loggly.org"

#ssh PROD
#alias sproxy10="ssh -v proxy10.prod.loggly.net"
#alias sproxy9="ssh -v proxy9.prod.loggly.net"
#alias sproxy8="ssh -v proxy8.prod.loggly.net"
#alias sproxy7="ssh -v proxy7.prod.loggly.net"

