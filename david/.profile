# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n
set -o vi
bind -m vi-command L:end-of-line
bind -m vi-command H:vi-first-print

alias ll="ls -la"

