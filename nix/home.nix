{ config, lib, pkgs, username, nix-claude-code, ... }:

let
  merge = import ./lib/merge.nix;

  localRoot = "${config.home.homeDirectory}/dotfiles/local";

  # local/<path> があればそのパスを返す。
  # pure評価では絶対パスの pathExists が false を返すため、--impure なしでも
  # エラーにならず「端末固有設定なし」に degrade する。
  localPath = path:
    let p = "${localRoot}/${path}";
    in if builtins.pathExists p then (/. + p) else null;

  # テキスト設定: ベースの末尾に端末固有設定を追記する
  mergeText = path:
    let l = localPath path;
    in builtins.readFile (./files + "/${path}")
      + lib.optionalString (l != null)
        ("\n# --- 端末固有設定 (local/${path}) ---\n" + builtins.readFile l);

  # JSON設定: ディープマージする(リストは連結)
  mergeJson = path:
    let
      l = localPath path;
      base = builtins.fromJSON (builtins.readFile (./files + "/${path}"));
    in
    if l == null then base
    else merge.deepMerge base (builtins.fromJSON (builtins.readFile l));

  claudeSettingsFile =
    (pkgs.formats.json { }).generate "claude-settings.json"
      (mergeJson ".claude/settings.json");
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    awscli2
    bat
    gnupg
    nix-claude-code.packages.aarch64-darwin.default
    gh
    ghq
    gitui
    neovim
    peco
    tree
    treemd
  ];

  home.file = {
    ".config/ghostty/config".text = mergeText ".config/ghostty/config";
    ".copilot/copilot-instructions.md".source = ./shared/AGENTS.md;
    ".claude/CLAUDE.md".text =
      builtins.readFile ./shared/AGENTS.md
      + "\n@~/.claude/CLAUDE.local.md\n";
  };

  # ~/.claude/settings.json は読み取り専用シンボリックリンクにできない。
  # Claude Code自身が model や theme をこのファイルに書き込むため、
  # 実ファイルとして書き出し、Nixが管理していないキーは既存値を残す。
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    outFile="$HOME/.claude/settings.json"

    run mkdir -p "$HOME/.claude"

    # 以前の世代が張ったシンボリックリンクが残っていれば実ファイルに置き換える
    if [ -L "$outFile" ]; then
      run rm -f "$outFile"
    fi

    existing='{}'
    if [ -f "$outFile" ]; then
      existing="$(cat "$outFile")"
    fi

    merged="$(${pkgs.jq}/bin/jq -n \
      --argjson existing "$existing" \
      --argjson managed "$(cat ${claudeSettingsFile})" \
      '$existing * $managed')"

    # macOSのcoreutilsはプロセス置換(/dev/fd/N)を読めず失敗するため一時ファイルを経由する
    tmpFile="$(${pkgs.coreutils}/bin/mktemp)"
    printf '%s\n' "$merged" > "$tmpFile"
    run ${pkgs.coreutils}/bin/install -m 600 "$tmpFile" "$outFile"
    ${pkgs.coreutils}/bin/rm -f "$tmpFile"
  '';

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initContent = ''
      # Homebrew (Apple Silicon)
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # nixで管理しているパッケージを優先するためHomebrewは末尾に置く
        path=(''${path:#/opt/homebrew/*} /opt/homebrew/bin /opt/homebrew/sbin)
      fi

      # Emacs keybindings
      bindkey -e

      # peco-src: Quick directory change with ghq + peco
      function peco-src () {
        local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
        if [ -n "$selected_dir" ]; then
          BUFFER="cd ''${selected_dir}"
          zle accept-line
        fi
        zle clear-screen
      }
      zle -N peco-src
      bindkey '^]' peco-src

      # ローカル専用の追加設定(gitで管理しない)
      if [ -f "$HOME/.zshrc.local" ]; then
        source "$HOME/.zshrc.local"
      fi
    '';
    shellAliases = {
      g = "git";
      n = "npm";
      y = "yarn";
      ll = "ls -al";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    includes = [{ path = "~/.gitconfig.local"; }];
    signing.format = null;
    settings = {
      alias = {
        fe = "fetch";
        sw = "switch";
        pl = "pull";
        rb = "rebase";
        co = "checkout";
        st = "status";
        pu = "push";
        lo = "log --oneline";
        cm = "commit";
        ad = "add";
        me = "merge";
        br = "branch";
        wt = "worktree";
      };
      push.autoSetupRemote = true;
      core.editor = "vim";
      ghq.root = "~/src";
      pull.autostash = true;
      rebase.autostash = true;
    };
    ignores = [
      "**/.claude/settings.local.json"
      "**/.worktree/"
    ];
  };

  programs.home-manager.enable = true;
}
