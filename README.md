# dotfiles

Nix (nix-darwin + Home Manager) で管理する dotfiles。

## セットアップ

### 1. Nix のインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. dotfiles の適用

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo nix run nix-darwin -- switch --flake .#default
```

2回目以降は `sudo darwin-rebuild switch --flake .#default` で更新できます。

## 管理対象

### dotfiles (Home Manager)

| ファイル | 配置先 |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.alias` | `~/.alias` |
| `.peco-src` | `~/.peco-src` |
| `.gitconfig` | `~/.gitconfig` |
| `.config/git/ignore` | `~/.config/git/ignore` |
| `.config/ghostty/config` | `~/.config/ghostty/config` |
| `AGENTS.md` | `~/.copilot/copilot-instructions.md`, `~/.claude/CLAUDE.md` |
| `.claude/settings.json` | `~/.claude/settings.json` |

### CLIパッケージ (Home Manager)

gh, ghq, gitui, neovim, peco, starship, tree, treemd, zsh-autosuggestions, zsh-completions

### GUIアプリ (nix-darwin + Homebrew cask)

Figma, Ghostty, Google Chrome Canary, Karabiner-Elements, MeetingBar, Raycast, Stats, Visual Studio Code, JetBrains Mono Nerd Font
