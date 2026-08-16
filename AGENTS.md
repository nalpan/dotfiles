# このリポジトリでの作業指示

- 指示があるまで `git push` をしないこと。

## 業務端末の情報をコミットしない

このリポジトリは **公開リポジトリ**(`github:nalpan/dotfiles`)である。以下をコミットしないこと。

- 業務端末のユーザー名
- 社内ホスト名・社内URL・社内IPアドレス
- 業務用メールアドレス

端末固有の識別子が必要になった場合は、次のいずれかで外部から与えること。

- 評価時に必要なもの(Nixの値) — `flake.nix` の `workUsername` と同じく実行時の環境から取得する
- 評価時に不要なもの(シェル設定・Git設定など) — `~/.zshrc.local` / `~/.gitconfig.local` などのローカルオーバーライドに置く

## READMEの「管理対象」を最新に保つ

以下を変更したら、**同じコミット内で** `README.md` の「管理対象」セクションも更新すること。追加・削除・リネームのいずれも対象。

| 変更した箇所 | 更新するREADMEの項目 |
|---|---|
| `nix/home.nix` の `home.packages` | 「CLIパッケージ」 |
| `nix/home.nix` の `home.file` | 「dotfiles (home.file)」の表 |
| `nix/home.nix` の `programs.*` | 「Home Manager ネイティブモジュール」 |
| `nix/darwin.nix` の `homebrew.casks` | 「GUIアプリ・フォント」 |

READMEの記載はNixファイル上の識別子(パッケージ名・cask名・属性名)をそのまま使い、目視で突き合わせられる状態を保つこと。
