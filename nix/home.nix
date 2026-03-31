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
    starship
    tree
    treemd
    zsh-autosuggestions
    zsh-completions
  ];

  home.file = {
    ".zshrc".source = ../. + "/.zshrc";
    ".alias".source = ../. + "/.alias";
    ".peco-src".source = ../. + "/.peco-src";
    ".config/ghostty/config".source = ../. + "/.config/ghostty/config";
    ".copilot/copilot-instructions.md".source = ../AGENTS.md;
    ".claude/CLAUDE.md".source = ../AGENTS.md;
    ".claude/settings.json".source = ../. + "/.claude/settings.json";
  };

  programs.git = {
    enable = true;
    includes = [{ path = "~/.gitconfig.local"; }];
    aliases = {
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
    extraConfig = {
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
