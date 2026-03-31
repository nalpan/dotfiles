{ config, pkgs, ... }:

{
  home.username = "Nakata.Kazuhiro";
  home.homeDirectory = "/Users/Nakata.Kazuhiro";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
