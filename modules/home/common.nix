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
    programs.git = {
      enable = true;
      includes = [
        { path = "~/.config/git/local"; }
      ];
      settings = {
        ghq.root = "~/src";
        init.defaultBranch = "main";
        credential = {
          "https://github.com" = {
            helper = [ "" "!gh auth git-credential" ];
          };
          "https://gist.github.com" = {
            helper = [ "" "!gh auth git-credential" ];
          };
        };
      };
    };

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
