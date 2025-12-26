# source
source ~/dotfiles/.alias
source ~/dotfiles/.peco-src

# Emacs keybindings
bindkey -e

# activate, init
eval "$(starship init zsh)"
eval "$(mise activate zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
