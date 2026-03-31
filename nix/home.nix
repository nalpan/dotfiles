{ config, pkgs, ... }:

{
  home.username = "Nakata.Kazuhiro";
  home.homeDirectory = "/Users/Nakata.Kazuhiro";
  home.stateVersion = "24.11";

  home.file = {
    ".zshrc".source = ../. + "/.zshrc";
    ".alias".source = ../. + "/.alias";
    ".peco-src".source = ../. + "/.peco-src";
    ".gitconfig".source = ../. + "/.gitconfig";
    ".config/git/ignore".source = ../. + "/.config/git/ignore";
    ".config/ghostty/config".source = ../. + "/.config/ghostty/config";
    ".copilot/copilot-instructions.md".source = ../AGENTS.md;
    ".claude/CLAUDE.md".source = ../AGENTS.md;
    ".claude/settings.json".source = ../. + "/.claude/settings.json";
  };

  programs.home-manager.enable = true;
}
