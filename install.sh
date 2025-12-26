DIR=~/dotfiles

echo $DIR

# create link
[[ ! -f ~/.zshrc ]] && ln -s $DIR/.zshrc ~/.zshrc
[[ ! -f ~/.gitconfig ]] && ln -s $DIR/.gitconfig ~/.gitconfig
