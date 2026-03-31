# source
source ~/.alias
source ~/.peco-src

# Emacs keybindings
bindkey -e

# activate, init
eval "$(starship init zsh)"
eval "$(mise activate zsh)"

source ~/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh

FPATH=~/.nix-profile/share/zsh/site-functions:$FPATH
autoload -Uz compinit
compinit
