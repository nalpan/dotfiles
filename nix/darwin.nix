{ pkgs, ... }:

{
  system.stateVersion = 6;
  system.primaryUser = "Nakata.Kazuhiro";

  # Determinate Nixがデーモンを管理するため無効化
  nix.enable = false;

  users.users."Nakata.Kazuhiro" = {
    name = "Nakata.Kazuhiro";
    home = "/Users/Nakata.Kazuhiro";
  };

  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "none";
    };

    casks = [
      "figma"
      "font-jetbrains-mono-nerd-font"
      "ghostty"
      "google-chrome@canary"
      "karabiner-elements"
      "meetingbar"
      "raycast"
      "stats"
      "visual-studio-code"
    ];
  };
}
