{ pkgs, ... }:
{
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };
}
