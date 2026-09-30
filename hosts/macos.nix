{ config, pkgs, ... }:
{
  imports = [ ../modules/home/common.nix ];

  home = {
    username = "iori";
    homeDirectory = "/Users/iori";
    stateVersion = "24.05";
  };

  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/modules/home/zsh/macos.zsh";

  dotfiles.nvimConfigPath = "/Users/iori/.dotfiles/.config/nvim";

  xdg.configFile."lazygit/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/lazygit/config.yml";

  xdg.configFile."zeno/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/zeno/config.yml";
  home.file.".nbrc".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.nbrc";
  xdg.configFile."termrain/config.example.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/termrain/config.example.toml";
  xdg.configFile."termrain/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/termrain/.config/termrain/config.toml";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.package = pkgs.nix;

  programs.home-manager.enable = true;
}
