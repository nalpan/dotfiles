{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    claude-code
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
    ".claude/CLAUDE.md".source = ./config/AGENTS.md;
    ".claude/settings.json".source = ./config/claude/settings.json;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initContent = ''
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
