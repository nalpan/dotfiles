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
    in
    {
      darwinConfigurations."default" = mkDarwinConfig {
        username = "Nakata.Kazuhiro";
      };
    };
}
