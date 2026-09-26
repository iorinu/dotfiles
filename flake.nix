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
    in
    {
      homeManagerModules.common = import ./modules/home/common.nix;

      homeConfigurations."iori@wsl" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./hosts/wsl-ubuntu.nix ];
      };
    };
}
