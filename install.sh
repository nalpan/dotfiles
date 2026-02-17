DIR=~/dotfiles
TODAY=$(date "+%Y%m%d%HH%MM")
BACKUP_DIR=$DIR/backup_$TODAY

echo "=== backup existing files ==="

echo backup to $BACKUP_DIR
mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"/.config/git
mkdir -p "$BACKUP_DIR"/.copilot
mkdir -p "$BACKUP_DIR"/.claude

[[ -e ~/.zshrc ]] && mv ~/.zshrc $BACKUP_DIR/.zshrc
[[ -e ~/.gitconfig ]] && mv ~/.gitconfig $BACKUP_DIR/.gitconfig
[[ -e ~/.config/git/ignore ]] && mv ~/.config/git/ignore $BACKUP_DIR/.config/git/ignore
[[ -e ~/.copilot/copilot-instructions.md ]] && mv ~/.copilot/copilot-instructions.md $BACKUP_DIR/.copilot/copilot-instructions.md
[[ -e ~/.claude/CLAUDE.md ]] && mv ~/.claude/CLAUDE.md $BACKUP_DIR/.claude/CLAUDE.md

echo "\n=== create directory and link ==="

echo link to $DIR

ln -s $DIR/.zshrc ~/.zshrc
ln -s $DIR/.gitconfig ~/.gitconfig
mkdir -p ~/.config/git && ln -s $DIR/.config/git/ignore ~/.config/git/ignore
mkdir -p ~/.copilot && ln -s $DIR/AGENTS.md ~/.copilot/copilot-instructions.md
mkdir -p ~/.claude && ln -s $DIR/AGENTS.md ~/.claude/CLAUDE.md

echo "\n=== All files are linked! ==="
exit 0
