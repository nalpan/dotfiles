DIR=~/dotfiles

echo $DIR

# check if files are already linked
[[ -L ~/.zshrc ]] && [[ -L ~/.gitconfig ]] && echo "All files are already linked!" && exit 0

# backup existing files
[[ ! -f $DIR/backup/.zshrc ]] && mv ~/.zshrc $DIR/backup/.zshrc
[[ ! -f $DIR/backup/.gitconfig ]] && mv ~/.gitconfig $DIR/backup/.gitconfig

# create link
[[ ! -f ~/.zshrc ]] && ln -s $DIR/.zshrc ~/.zshrc
[[ ! -f ~/.gitconfig ]] && ln -s $DIR/.gitconfig ~/.gitconfig
