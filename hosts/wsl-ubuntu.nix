{ config, ... }:
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

  # AI設定は個別leafで配置し、認証情報・履歴・ランタイムは管理しない。
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/claude/CLAUDE.md";
  home.file.".claude/runcat-statusline.py".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/claude/runcat-statusline.py";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/claude/settings.json";

  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/codex/AGENTS.md";
  home.file.".codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/codex/config-wsl.toml";

  home.file.".hermes/SOUL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/hermes/SOUL.md";
  home.file.".hermes/docs/loop-engineering-guide.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/hermes/docs/loop-engineering-guide.md";
  home.file.".hermes/skills/software-development/behavior-preserving-refactoring/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/hermes/skills/software-development/behavior-preserving-refactoring/SKILL.md";
  home.file.".hermes/skills/software-development/loop-engineering/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/hermes/skills/software-development/loop-engineering/SKILL.md";
  home.file.".hermes/skills/software-development/requirements-to-docs/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/hermes/skills/software-development/requirements-to-docs/SKILL.md";
  home.file.".hermes/skills/software-development/spec-driven-delivery/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/hermes/skills/software-development/spec-driven-delivery/SKILL.md";
  # Git管理YAMLは実行時にリポジトリを参照し、値はNixで生成しない。
  home.file.".hermes/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/hermes/.hermes/config.yaml";

  xdg.configFile."opencode/opencode.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "/home/iori/src/github.com/iorinu/dotfiles/.config/opencode/opencode.jsonc";

  programs.home-manager.enable = true;
}
