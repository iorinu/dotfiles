{
  description = "Shared Home Manager modules for this dotfiles repository";

  outputs = { self }:
    {
      homeManagerModules.common = import ./modules/home/common.nix;
    };
}
