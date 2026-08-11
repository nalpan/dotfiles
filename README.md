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

## マシンの追加

`flake.nix` の `darwinConfigurations` に新しいエントリを追加します。

```nix
darwinConfigurations."home" = mkDarwinConfig {
  username = "kazuhiro";
};
```

適用時に設定名を指定して実行します。

```bash
sudo darwin-rebuild switch --flake .#home
```

## 管理対象

### Home Manager ネイティブモジュール

- `programs.zsh` — シェル設定、エイリアス、autosuggestions、completions
- `programs.starship` — プロンプト
- `programs.git` — Git設定、エイリアス、グローバルignore

### dotfiles (home.file)

| ファイル | 配置先 |
|---|---|
| `.config/ghostty/config` | `~/.config/ghostty/config` |
| `AGENTS.md` | `~/.copilot/copilot-instructions.md`, `~/.claude/CLAUDE.md` |
| `.claude/settings.json` | `~/.claude/settings.json` |

### CLIパッケージ (home.packages)

bat, gh, ghq, gitui, gnupg, neovim, peco, tree, treemd

### GUIアプリ (nix-darwin + Homebrew cask)

Figma, Ghostty, Google Chrome Canary, Karabiner-Elements, MeetingBar, Raycast, Stats, Visual Studio Code, JetBrains Mono Nerd Font

## パッケージのバージョンアップ

`home.packages` などで指定しているパッケージのバージョンは、`flake.lock` が固定している `nixpkgs` のバージョンに従います。個別パッケージだけを狙ってアップデートすることはできないため、`nixpkgs` ごと更新します。

### すべての input を更新

```bash
nix flake update
```

### 特定の input だけ更新（例: nixpkgs のみ）

```bash
nix flake lock --update-input nixpkgs
```

`flake.lock` の差分を確認したらコミットし、変更を適用します。

```bash
sudo darwin-rebuild switch --flake .#default
```
