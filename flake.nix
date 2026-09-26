{
  description = "Home Manager configuration for macOS and WSL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      self,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      macosPkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in
    {
      homeManagerModules.common = import ./modules/home/common.nix;
      homeManagerModules.git = import ./modules/home/git.nix;

      homeConfigurations."iori@wsl" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./hosts/wsl-ubuntu.nix ];
      };

      homeConfigurations."iori@macos" = home-manager.lib.homeManagerConfiguration {
        pkgs = macosPkgs;
        modules = [ ./hosts/macos.nix ];
      };
    };
}
