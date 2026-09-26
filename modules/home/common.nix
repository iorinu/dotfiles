{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.nvimConfigPath = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Absolute path to the writable Neovim configuration";
  };

  config = {
    home.packages = with pkgs; [
      bat
      fd
      fzf
      gh
      ghq
      jq
      lazygit
      neovim
      ripgrep
      zoxide
    ];

    xdg.configFile."nvim" = lib.mkIf (config.dotfiles.nvimConfigPath != null) {
      source = config.lib.file.mkOutOfStoreSymlink config.dotfiles.nvimConfigPath;
    };
  };
}
