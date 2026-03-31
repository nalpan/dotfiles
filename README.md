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
nix run home-manager/master -- switch --flake .
```

2回目以降は `home-manager switch --flake .` で更新できます。

### 3. Homebrew パッケージのインストール

以下のパッケージは Homebrew で別途インストールが必要です。

```bash
brew install mise
```

## 管理対象ファイル

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
