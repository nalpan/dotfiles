# dotfiles

Nix (nix-darwin + Home Manager) で管理する dotfiles です。

## セットアップ

### 1. Nix のインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. dotfiles の適用

Nix 経由の一時的な git を使います(Xcode Command Line Tools に依存しません)。

```bash
nix run nixpkgs#git -- clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo nix run nix-darwin -- switch --flake .#home            # 私用端末の場合
sudo nix run nix-darwin -- switch --flake .#work --impure   # 業務端末の場合
```

2回目以降は `sudo darwin-rebuild switch --flake .#home`(業務端末は `--flake .#work --impure`)で更新できます。業務端末だけ `--impure` が必要な理由は [業務端末で --impure が必要な理由](#業務端末で---impure-が必要な理由) を参照してください。

## 運用

### パッケージのバージョンアップ

`home.packages` などで指定しているパッケージのバージョンは、`flake.lock` が固定している `nixpkgs` のバージョンに従います。個別パッケージだけを狙ってアップデートすることはできないため、`nixpkgs` ごと更新します。

すべての input を更新する場合:

```bash
nix flake update
```

特定の input だけ更新する場合(例: nixpkgs のみ):

```bash
nix flake lock --update-input nixpkgs
```

`flake.lock` の差分を確認したら、共通設定の変更と同じ手順で適用してコミット・pushします。

```bash
sudo darwin-rebuild switch --flake .#home            # 私用端末の場合
sudo darwin-rebuild switch --flake .#work --impure   # 業務端末の場合
```

### 設定の変更

変更したい内容が「両方の端末に反映したいもの」か「その端末だけのもの」かで手順が分かれます。

| 変えたいもの | 編集先 | git管理 | rebuild |
|---|---|---|---|
| 共通設定(両方の端末に反映) | リポジトリ内の `nix/` 配下・`flake.nix` | する | 必要 |
| 端末固有設定(その端末だけ) | ホームの `~/.zshrc.local` など | しない | 不要 |
| 端末固有のCLI/GUI(その端末だけ) | ファイル編集なし(コマンドで直接インストール) | しない | 不要 |

#### 共通設定を変更したい場合

`nix/` 配下の設定は `home` / `work` 両方の端末で共通なので、片方の端末で変更してpushし、もう片方でpullして適用します。

編集するファイルは変えたい内容によって決まります。

| 変えたい内容 | 編集するファイル |
|---|---|
| CLIパッケージの追加・削除、zsh設定、エイリアス、Git設定、starship | `nix/home.nix` |
| GUIアプリ(Homebrew cask)、macOSシステム設定 | `nix/darwin.nix` |
| Claude Code / Copilot への共通指示 | `nix/config/AGENTS.md` |
| Claude Code の設定(権限・フックなど) | `nix/config/claude/settings.json` |
| ターミナル(Ghostty)の設定 | `nix/config/ghostty/config` |
| flake input(nixpkgs等)の追加、端末(`darwinConfigurations`)の追加 | `flake.nix` |

作業した端末:

1. 上表のファイルを編集します
2. ビルドのみ実行して、システムに影響を与えずに評価が通ることを確認します

   ```bash
   darwin-rebuild build --flake .#home            # 私用端末の場合
   darwin-rebuild build --flake .#work --impure   # 業務端末の場合
   ```

3. 問題なければ適用します

   ```bash
   sudo darwin-rebuild switch --flake .#home            # 私用端末の場合
   sudo darwin-rebuild switch --flake .#work --impure   # 業務端末の場合
   ```

4. 変更をコミット・pushします

もう一方の端末:

```bash
cd ~/dotfiles
git pull
sudo darwin-rebuild switch --flake .#home            # 私用端末の場合
sudo darwin-rebuild switch --flake .#work --impure   # 業務端末の場合
```

##### 業務端末で --impure が必要な理由

このリポジトリは公開しているため、業務端末のユーザー名を `flake.nix` に書かず、実行時の環境から取得しています(`flake.nix` の `workUsername`)。環境変数を読むには純粋評価モードを外す必要があるため、`.#work` を扱うコマンドにだけ `--impure` を付けます(`.#home` は不要です)。

ユーザー名は `DOTFILES_WORK_USER` → `SUDO_USER` → `USER` の順に解決します。`SUDO_USER` は `sudo` が自動的に設定するため、**通常は何も設定する必要がありません**。`--impure` を付け忘れた場合は、その旨のエラーメッセージが出て停止します。

自動判定が効かない環境では、明示的に指定できます。

```bash
sudo DOTFILES_WORK_USER=<ユーザー名> darwin-rebuild switch --flake .#work --impure
```

#### 端末固有設定を変更したい場合

その端末にだけ効かせたい設定(私用端末・業務端末とも手順は同じ)は、リポジトリではなくホームディレクトリのローカルファイルに直接書きます。git管理外なのでもう一方の端末には影響せず、rebuildも不要ですぐ反映されます。業務固有の情報(社内向けの設定や業務用メールアドレスなど)をリポジトリに入れずに済みます。

| 変えたい内容 | 編集するファイル | 読み込まれ方 |
|---|---|---|
| シェル設定(PATH、エイリアス、環境変数など) | `~/.zshrc.local` | `.zshrc` の末尾で自動的に読み込まれます |
| Claude Code への追加指示 | `~/.claude/CLAUDE.local.md` | `~/.claude/CLAUDE.md` から自動的に読み込まれます |
| Git設定(その端末用の `user.name` / `user.email` など) | `~/.gitconfig.local` | `programs.git.includes` で読み込まれます |

```bash
vim ~/.zshrc.local
exec $SHELL -l   # .zshrc.local を編集した場合はシェルを読み込み直す
```

いずれも存在すれば読み込まれる仕組みなので、ファイルが無ければ新規作成してください。

**端末固有のCLIパッケージ・GUIアプリを入れたい場合**

パッケージだけは上記の `*.local` ファイル方式が使えません。flake は git 管理下のファイルしか評価対象に含めないため、git管理外のNixファイルでパッケージを追加するオーバーライドは成立しないからです。

そのため、両方の端末で使うものは共通設定として `nix/home.nix`(CLI) / `nix/darwin.nix`(GUI cask) に書き、その端末だけで使うものは以下のコマンドでNixの宣言的管理の外に個別にインストールします。

CLIパッケージ:

```bash
nix profile add nixpkgs#ffmpeg   # インストール
nix profile list                 # インストール済み一覧
nix profile remove ffmpeg        # 削除
nix profile upgrade --all        # 更新
```

インストール後にコマンドが見つからない場合は、シェルを開き直してください(`exec $SHELL -l`)。

GUIアプリ:

```bash
brew install --cask slack     # インストール
brew list --cask              # インストール済み一覧
brew uninstall --cask slack   # 削除
```

`nix/darwin.nix` で `homebrew.onActivation.cleanup = "none"` を指定しているため、手動で入れた cask が `darwin-rebuild switch` で勝手に削除されることはありません。

この方法には以下の制約があります。

- Nixの宣言的管理の外にあるため、`flake.lock` によるバージョン固定の対象外になります。
- 新しい端末をセットアップしても再現されないため、手動で入れ直す必要があります。
- 後から「やはり両方の端末で使う」となった場合は、`nix/home.nix` / `nix/darwin.nix` に移して共通設定として管理してください。

なお `~/.zshrc` / `~/.claude/CLAUDE.md` / `~/.claude/settings.json` / `~/.config/ghostty/config` はNixが生成する読み取り専用のシンボリックリンクなので、直接編集しないでください(編集できない、あるいは次のrebuildで上書きされます)。必ず上表の `*.local` 側に書きます。その端末だけの変更のつもりで `nix/` 配下を編集すると、もう一方の端末にも反映されるので注意してください。

### 適用に失敗した・切り戻したいとき

`darwin-rebuild switch` は世代(generation)を積む形で適用されるため、直前の世代に戻せます。

```bash
darwin-rebuild --list-generations
sudo darwin-rebuild rollback
```

### マシンの追加

`home`(私用端末) / `work`(業務端末) は `flake.nix` の `darwinConfigurations` に定義済みです。3台目以降を追加する場合は、新しいエントリを追加します。

```nix
darwinConfigurations."別のホスト名" = mkDarwinConfig {
  username = "...";
};
```

適用時は設定名を指定して実行します。

```bash
sudo darwin-rebuild switch --flake .#別のホスト名
```

追加する端末のユーザー名を公開したくない場合は、直書きせずに `work` と同じく `workUsername` の方式(実行時の環境から取得し、適用時に `--impure` を付ける)を使ってください。

## 管理対象

管理対象を増減させたときは、このセクションも同時に更新してください([AGENTS.md](./AGENTS.md) のルール)。

### Home Manager ネイティブモジュール (nix/home.nix)

- `programs.zsh` — シェル設定、エイリアス、autosuggestions、completions
- `programs.starship` — プロンプト
- `programs.git` — Git設定、エイリアス、グローバルignore
- `programs.home-manager` — Home Manager 自身の管理

### dotfiles (home.file)

| リポジトリ内のファイル | 配置先 |
|---|---|
| `nix/config/ghostty/config` | `~/.config/ghostty/config` |
| `nix/config/AGENTS.md` | `~/.copilot/copilot-instructions.md` |
| `nix/config/AGENTS.md` + `~/.claude/CLAUDE.local.md` の読み込み指定 | `~/.claude/CLAUDE.md` |
| `nix/config/claude/settings.json` | `~/.claude/settings.json` |

### CLIパッケージ (nix/home.nix の home.packages)

awscli2, bat, gh, ghq, gitui, gnupg, neovim, peco, tree, treemd, nix-claude-code (Claude Code)

### GUIアプリ・フォント (nix/darwin.nix の homebrew.casks)

claude, cmux, figma, font-jetbrains-mono-nerd-font, google-chrome@canary, karabiner-elements, meetingbar, obsidian, raycast, stats, visual-studio-code

`homebrew.onActivation.cleanup = "none"` を指定しているため、この一覧に無い cask を手動で入れても `darwin-rebuild switch` で削除されることはありません(端末固有のGUIアプリはそちらで入れます)。
