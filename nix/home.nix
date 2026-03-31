{ config, pkgs, ... }:

{
  home.username = "Nakata.Kazuhiro";
  home.homeDirectory = "/Users/Nakata.Kazuhiro";
  home.stateVersion = "24.11";

  home.file = {
    ".zshrc".source = ../. + "/.zshrc";
    ".gitconfig".source = ../. + "/.gitconfig";
    ".config/git/ignore".source = ../. + "/.config/git/ignore";
    ".config/ghostty/config".source = ../. + "/.config/ghostty/config";
  };

  programs.home-manager.enable = true;
}
