{ pkgs, username, ... }:

{
  system.stateVersion = 6;
  system.primaryUser = username;

  # Determinate Nixがデーモンを管理するため無効化
  nix.enable = false;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "none";
    };

    casks = [
      "figma"
      "font-jetbrains-mono-nerd-font"
      "cmux"
      "google-chrome@canary"
      "karabiner-elements"
      "meetingbar"
      "raycast"
      "stats"
      "visual-studio-code"
      "claude"
    ];
  };
}
