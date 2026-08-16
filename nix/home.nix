{ config, pkgs, username, nix-claude-code, ... }:

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
    ".config/ghostty/config".source = ./config/ghostty/config;
    ".copilot/copilot-instructions.md".source = ./config/AGENTS.md;
    ".claude/CLAUDE.md".text =
      builtins.readFile ./config/AGENTS.md
      + "\n@~/.claude/CLAUDE.local.md\n";
    ".claude/settings.json".source = ./config/claude/settings.json;
  };

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
