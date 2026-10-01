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

  # GUI設定はmacOSで使う個別leafのみ管理し、アプリ本体はHomebrewに残す。
  xdg.configFile."ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/ghostty/config";
  xdg.configFile."wezterm/wezterm.lua".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/wezterm/wezterm.lua";
  xdg.configFile."wezterm/keybinds.lua".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/wezterm/keybinds.lua";
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/herdr/config.toml";

  # AI設定は個別leafで配置し、Stowと同じ配置先を同時に所有しない。
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/claude/CLAUDE.md";
  home.file.".claude/runcat-statusline.py".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/claude/runcat-statusline.py";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/claude/settings.json";

  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/codex/AGENTS.md";
  home.file.".codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/codex/config.toml";
  home.file.".codex/runcat-usage.py".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/codex/runcat-usage.py";
  home.file."Library/LaunchAgents/com.iori.codex-runcat-usage.plist".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/codex/launchd/com.iori.codex-runcat-usage.plist";

  home.file.".hermes/SOUL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/hermes/SOUL.md";
  home.file.".hermes/docs/loop-engineering-guide.md".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/hermes/docs/loop-engineering-guide.md";
  home.file.".hermes/skills/software-development/behavior-preserving-refactoring/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/hermes/skills/software-development/behavior-preserving-refactoring/SKILL.md";
  home.file.".hermes/skills/software-development/loop-engineering/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/hermes/skills/software-development/loop-engineering/SKILL.md";
  home.file.".hermes/skills/software-development/requirements-to-docs/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/hermes/skills/software-development/requirements-to-docs/SKILL.md";
  home.file.".hermes/skills/software-development/spec-driven-delivery/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/hermes/skills/software-development/spec-driven-delivery/SKILL.md";
  # Git管理YAMLは実行時にリポジトリを参照し、Flakeのソーススナップショットには含まれる。値はNixで生成しない。
  home.file.".hermes/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/hermes/.hermes/config.yaml";

  xdg.configFile."opencode/opencode.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "/Users/iori/.dotfiles/.config/opencode/opencode.jsonc";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.package = pkgs.nix;

  programs.home-manager.enable = true;
}
