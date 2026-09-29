{ ... }:
{
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
}
