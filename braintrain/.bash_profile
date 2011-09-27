
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

