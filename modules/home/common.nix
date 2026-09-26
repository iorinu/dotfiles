{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "iorimacbook";
        email = "iorinu@users.noreply.github.com";
      };
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

  xdg.configFile."nvim".source = ../../nvim/.config/nvim;
}
