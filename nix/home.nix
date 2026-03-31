{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    gh
    ghq
    gitui
    neovim
    peco
    tree
    treemd
  ];

  home.file = {
    ".copilot/copilot-instructions.md".source = ../AGENTS.md;
    ".claude/CLAUDE.md".source = ../AGENTS.md;
    ".claude/settings.json".text = builtins.toJSON {
      permissions = {
        allow = [
          "Bash(git:*)" "Bash(gh:*)" "Bash(ls:*)" "Bash(cat:*)"
          "Bash(head:*)" "Bash(tail:*)" "Bash(wc:*)" "Bash(file:*)"
          "Bash(tree:*)" "Bash(stat:*)" "Bash(find:*)" "Bash(grep:*)"
          "Bash(rg:*)" "Bash(which:*)" "Bash(where:*)" "Bash(go:*)"
          "Bash(make:*)" "Bash(npm:*)" "Bash(yarn:*)" "Bash(pnpm:*)"
          "Bash(docker:*)" "Bash(docker-compose:*)" "Bash(cargo:*)"
          "Bash(sort:*)" "Bash(uniq:*)" "Bash(diff:*)" "Bash(jq:*)"
          "Bash(sed:*)" "Bash(awk:*)" "Bash(echo:*)" "Bash(printf:*)"
          "Bash(env:*)" "Bash(printenv:*)" "Bash(pwd:*)" "Bash(date:*)"
          "Bash(uname:*)" "Bash(ps:*)" "Bash(curl:*)" "Bash(mkdir:*)"
        ];
        deny = [
          "Bash(git rebase:*)" "Bash(git reset:*)"
          "Bash(git push --force:*)" "Bash(git push -f:*)"
          "Bash(git push --force-with-lease:*)"
        ];
        defaultMode = "acceptEdits";
      };
      model = "opus[1m]";
      hooks = {
        Stop = [{
          matcher = "";
          hooks = [{
            type = "command";
            command = "osascript -e 'display notification \"Claude Codeが入力を待っています\" with title \"Claude Code\" sound name \"Glass\"'";
          }];
        }];
        Notification = [{
          matcher = "";
          hooks = [{
            type = "command";
            command = "osascript -e 'display notification \"Claude Codeが入力を待っています\" with title \"Claude Code\" sound name \"Glass\"'";
          }];
        }];
      };
      language = "Japanese";
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      theme = "Dracula";
      font-family = "Moralerspace Neon HW Regular";
      font-size = 14;
      font-feature = "-dlig";
      macos-titlebar-style = "tabs";
      window-padding-x = 12;
      window-padding-y = 12;
      background-opacity = 0.90;
    };
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
