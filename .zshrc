# source
source ~/.alias
source ~/.peco-src

# Emacs keybindings
bindkey -e

# activate, init
eval "$(starship init zsh)"
eval "$(mise activate zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi
