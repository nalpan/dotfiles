# dotfiles

Nix (nix-darwin + Home Manager) で管理する dotfiles です。**公開リポジトリ**なので、業務固有の情報は含まれていません。

端末ごとの差分は `local/` 配下や `*.local` ファイルで吸収します。対応関係は [配置ファイル](#配置ファイル) を参照してください。

## セットアップ

### 1. Nix のインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. dotfiles の適用

Xcode Command Line Tools に依存しないよう、Nix経由の一時的なgitでcloneします。

```bash
nix run nixpkgs#git -- clone https://github.com/nalpan/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo nix run nix-darwin -- switch --flake .#default --impure
```

2回目以降は次のコマンドで更新できます。`--impure` は常に必要で、付け忘れるとエラーで停止します。

```bash
sudo darwin-rebuild switch --flake .#default --impure
```

新しい端末を追加するときも、この手順をそのまま繰り返すだけです。

## 運用

### 設定を変更する

編集するファイルは変えたい内容によって決まります。

| 変えたい内容 | 編集するファイル |
|---|---|
| CLIパッケージ、zsh/Git設定、starship | `nix/home.nix` |
| GUIアプリ (Homebrew cask)、macOSシステム設定 | `nix/darwin.nix` |
| Claude Code / Copilot への共通指示 | `nix/shared/AGENTS.md` |
| flake input (nixpkgs等) の追加 | `flake.nix` |

公開ベースと端末固有の上書きを合成して配置するファイルは [配置ファイル](#配置ファイル) の表を参照してください。

```bash
darwin-rebuild build --flake .#default --impure    # 評価のみ確認
sudo darwin-rebuild switch --flake .#default --impure    # 適用
git add -A && git commit && git push    # 共通設定は他の端末にも反映するため
```

他の端末では、pullしてから適用します。

```bash
cd ~/dotfiles && git pull
sudo darwin-rebuild switch --flake .#default --impure
```

その端末だけに効かせたい設定は `local/` 配下、または `~/.zshrc.local` などの `*.local` ファイルに書きます。git管理外なので他の端末には影響せず、公開リポジトリにも載りません。

端末固有のClaude設定は見本をコピーして作成します。

```bash
mkdir -p ~/dotfiles/local/.claude
cp ~/dotfiles/local/.claude/settings.sample.json ~/dotfiles/local/.claude/settings.json
```

`~/.claude/settings.json` はClaude Code自身が書き込んだ値も残ります (恒久的に固定したい値は `local/` 側に書いてください)。

### パッケージを追加する

他の端末でも使うものは `nix/home.nix` (CLI) / `nix/darwin.nix` (GUI cask) に追加して共通設定として管理します。その端末だけで使うものはNixの宣言的管理の外に個別インストールします。新しい端末では再現されないため、必要な端末ごとに入れ直してください。

```bash
nix profile add nixpkgs#ffmpeg    # CLIパッケージ
brew install --cask slack    # GUIアプリ
```

### 更新する

`flake.lock` が固定している `nixpkgs` などのバージョンを更新します。

```bash
nix flake update    # すべてのinputを更新
nix flake lock --update-input nixpkgs    # nixpkgsだけ更新
sudo darwin-rebuild switch --flake .#default --impure
git add -A && git commit && git push    # 手順は「設定を変更する」と同じ
```

### 切り戻す

`darwin-rebuild switch` は世代 (generation) を積む形で適用されるため、直前の世代に戻せます。

```bash
darwin-rebuild --list-generations
sudo darwin-rebuild rollback
```

## 管理対象

管理対象を増減させたときは、このセクションも同時に更新します。詳しいルールは [AGENTS.md](./AGENTS.md) を参照してください。

### 配置ファイル

| 配置先 | 公開ベース | 端末固有の上書き | 合成 |
|---|---|---|---|
| `~/.claude/settings.json` | `nix/files/.claude/settings.json` | `local/.claude/settings.json` | JSONをマージ |
| `~/.config/ghostty/config` | `nix/files/.config/ghostty/config` | `local/.config/ghostty/config` | 末尾に追記 |
| `~/.claude/CLAUDE.md` | `nix/shared/AGENTS.md` | `~/.claude/CLAUDE.local.md` | 実行時に読み込み |
| `~/.copilot/copilot-instructions.md` | `nix/shared/AGENTS.md` | なし | — |
| `~/.zshrc` | `nix/home.nix` の `programs.zsh` | `~/.zshrc.local` | 末尾でsource |
| `~/.config/git/config` | `nix/home.nix` の `programs.git` | `~/.gitconfig.local` | `includes`で読み込み |

- `nix/files/` と `local/` は、`$HOME` からの相対パスをそのまま再現したミラーです。
- `local/` と `*.local` ファイルはgit管理外なので、端末固有の内容を自由に書けます。
- このほか `programs.starship` (プロンプト) と `programs.home-manager` を有効にしていますが、これらは設定ファイルを生成しません。

### CLIパッケージ

`nix/home.nix` の `home.packages`:

awscli2, bat, gh, ghq, gitui, gnupg, neovim, peco, tree, treemd, nix-claude-code (Claude Code)

### GUIアプリ・フォント

`nix/darwin.nix` の `homebrew.casks`:

claude, cmux, figma, font-jetbrains-mono-nerd-font, google-chrome@canary, karabiner-elements, meetingbar, obsidian, raycast, stats, visual-studio-code
