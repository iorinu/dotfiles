{ ... }:
{
  imports = [
    ../modules/home/common.nix
    ../modules/home/git.nix
    ../modules/home/wsl.nix
  ];

  home = {
    username = "iori";
    homeDirectory = "/home/iori";
    stateVersion = "24.05";
  };

  dotfiles.nvimConfigPath = "/home/iori/src/github.com/iorinu/dotfiles/.config/nvim";

  programs.home-manager.enable = true;
}
