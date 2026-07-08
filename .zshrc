export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

export FORGIT_FZF_DEFAULT_OPTS="
--tmux 100%,100%
--layout reverse
--min-height 20+
--border
--no-separator
--header-border horizontal
--border-label-pos 2
--color 'label:blue'
--preview-window 'down,66%'
--preview-border line
--bind 'ctrl-/:change-preview-window(right,50%|hidden|)'
"

plugins=(git fzf zsh-fzf-history-search forgit)

source "$ZSH/oh-my-zsh.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

bindkey '^H' backward-kill-word
bindkey '\e^?' backward-kill-word

alias curr="git rev-parse --abbrev-ref HEAD"
alias gpo='git push origin $(curr)'
alias sl='ls'
alias gs='git status'
alias ga='git add'
alias lg='lazygit'
alias mux='tmuxinator'
alias muxrepo='tmuxinator start monorepo'

if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
