DIR=~/dotfiles

echo $DIR

# check if files are already linked
[[ -L ~/.zshrc ]] \
&& [[ -L ~/.gitconfig ]] \
&& [[ -L ~/AGENTS.md ]] \
&& [[ -L ~/.copilot/copilot-instructions.md ]] \
&& [[ -L ~/.config/git/ignore ]] \
&& echo "All files are already linked!" && exit 0

# backup existing files
[[ ! -f $DIR/backup/.zshrc ]] && mv ~/.zshrc $DIR/backup/.zshrc
[[ ! -f $DIR/backup/.gitconfig ]] && mv ~/.gitconfig $DIR/backup/.gitconfig
[[ ! -f $DIR/backup/AGENTS.md ]] && mv ~/AGENTS.md $DIR/backup/AGENTS.md
[[ -f ~/.config/git/ignore ]] && [[ ! -f $DIR/backup/.config/git/ignore ]] && mv ~/.config/git/ignore $DIR/backup/.config/git/ignore
[[ -f ~/.copilot/copilot-instructions.md ]] && [[ ! -f $DIR/backup/.copilot/copilot-instructions.md ]] && mv ~/.copilot/copilot-instructions.md $DIR/backup/.copilot/copilot-instructions.md
[[ -f ~/.claude/CLAUDE.md ]] && [[ ! -f $DIR/backup/.claude/CLAUDE.md ]] && mv ~/.claude/CLAUDE.md $DIR/backup/.claude/CLAUDE.md

# create directory and link
[[ ! -f ~/.zshrc ]] && ln -s $DIR/.zshrc ~/.zshrc
[[ ! -f ~/.gitconfig ]] && ln -s $DIR/.gitconfig ~/.gitconfig
[[ ! -f ~/AGENTS.md ]] && ln -s $DIR/AGENTS.md ~/AGENTS.md
mkdir -p ~/.config/git && ln -s $DIR/.config/git/ignore ~/.config/git/ignore
mkdir -p ~/.copilot && ln -s $DIR/.copilot/copilot-instructions.md ~/.copilot/copilot-instructions.md
mkdir -p ~/.claude && ln -s $DIR/.claude/CLAUDE.md ~/.claude/CLAUDE.md

echo "All files are linked!"
exit 0
