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
      "claude"
      "cmux"
      "figma"
      "font-jetbrains-mono-nerd-font"
      "google-chrome@canary"
      "karabiner-elements"
      "meetingbar"
      "raycast"
      "stats"
      "visual-studio-code"
      "obsidian"
    ];
  };
}
