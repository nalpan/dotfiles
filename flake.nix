{
  description = "nix-darwin + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-claude-code.url = "github:ryoppippi/nix-claude-code";
  };

  outputs = { nixpkgs, nix-darwin, home-manager, nix-claude-code, ... }:
    let
      mkDarwinConfig = { username }:
        let
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
          };
        in
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username; };
          modules = [
            { nixpkgs.pkgs = pkgs; }
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit username nix-claude-code; };
              home-manager.users.${username} = import ./nix/home.nix;
            }
          ];
        };
      # 端末のユーザー名を公開リポジトリに置かないため、実行時の環境から取得する。
      # sudo実行時はsudoが設定するSUDO_USER、非sudo時はUSERがこの端末のユーザー名になる。
      machineUsername =
        let
          explicit = builtins.getEnv "DOTFILES_USERNAME";
          sudoUser = builtins.getEnv "SUDO_USER";
          currentUser = builtins.getEnv "USER";
        in
        if explicit != "" then explicit
        else if sudoUser != "" then sudoUser
        else if currentUser != "" then currentUser
        else throw ''
          端末のユーザー名を取得できませんでした。
          .#default の適用には --impure が必要です。
          例: sudo darwin-rebuild switch --flake .#default --impure
        '';
    in
    {
      darwinConfigurations = {
        # 端末ごとの差分は local/ 配下で吸収するため、設定は1つに統一している。
        # ユーザー名を実行時の環境から取るので適用には --impure が必要。
        default = mkDarwinConfig { username = machineUsername; };
      };
    };
}
