# dotfiles

Nix Home Manager で管理する dotfiles。

## セットアップ

### 1. Nix のインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. dotfiles の適用

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

初回実行時は `nix run home-manager/master -- switch --flake ~/dotfiles` が自動で実行されます。
2回目以降は `home-manager switch --flake ~/dotfiles` で更新できます。

### 3. Homebrew パッケージのインストール

以下のパッケージは Homebrew で別途インストールが必要です。

```bash
brew install ghq peco starship mise zsh-autosuggestions zsh-completions
```

## 管理対象ファイル

| ファイル | 配置先 |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.gitconfig` | `~/.gitconfig` |
| `.config/git/ignore` | `~/.config/git/ignore` |
| `.config/ghostty/config` | `~/.config/ghostty/config` |
| `AGENTS.md` | `~/.copilot/copilot-instructions.md`, `~/.claude/CLAUDE.md` |
