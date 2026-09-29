{ config, pkgs, ... }:
{
  imports = [ ../modules/home/common.nix ];

  home = {
    username = "iori";
    homeDirectory = "/Users/iori";
    stateVersion = "24.05";
  };

  dotfiles.nvimConfigPath = "/Users/iori/.dotfiles/nvim/.config/nvim";

  xdg.configFile."lazygit/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/lazygit/.config/lazygit/config.yml";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.package = pkgs.nix;

  programs.home-manager.enable = true;
}
