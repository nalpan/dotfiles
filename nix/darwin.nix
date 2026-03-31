{ pkgs, ... }:

{
  system.stateVersion = 6;

  # Determinate Nixがデーモンを管理するため無効化
  nix.enable = false;

  users.users."Nakata.Kazuhiro" = {
    name = "Nakata.Kazuhiro";
    home = "/Users/Nakata.Kazuhiro";
  };
}
