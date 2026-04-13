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
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
      mkDarwinConfig = { username }:
        let
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
              "claude-code"
            ];
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
              home-manager.extraSpecialArgs = { inherit username; };
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
