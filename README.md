# dotfiles

macOSとWSL Ubuntuで使う個人設定ファイル群。

Nix/Home Managerへ段階的に移行しています。macOSは引き続きGNU Stowを使い、WSLではGit、Neovim、共通CLIをHome Managerで管理します。実装状況と今後の作業は[移行計画](docs/nix-migration.md)を参照してください。

## 構成

| ディレクトリ | 内容 |
|---|---|
| `zsh/` | `.zshrc` — Oh My Zsh (agnoster)、pyenv、nvm、ghq+peco 連携、nb ヘルパー関数 |
| `nvim/` | Neovim 設定 — lazy.nvim ベース。LSP、Telescope、Copilot、Git 連携など |
| `wezterm/` | WezTerm ターミナル設定 — 透過・グラデーション背景、カスタムキーバインド |
| `git/` | `.gitconfig` — ghq root、GitHub credential 設定 |
| `zeno/` | zeno.zsh のスニペット・補完設定 |
| `nb/` | nb (ノートブック CLI) の設定 |
| `claude/` | Claude Code の設定 |
| `ghostty/` | Ghostty の設定 |
| `lazygit/` | lazygit の設定 (`gui.language: ja` で UI 日本語化) |
| `homebrew/` | Brewfile — Homebrew でインストールしたパッケージ一覧 |
| `termrain/` | termrain (ターミナル天気/レーダー CLI) の設定 |

## セットアップ

### WSL Ubuntu

WSL用の構成名は`iori@wsl`です。現在のホスト設定は、リポジトリを`/home/iori/clone/dotfiles`へ配置する前提です。

```bash
cd /home/iori/clone/dotfiles
nix flake check path:.
home-manager switch --flake path:.#iori@wsl
```

Gitのユーザー名とメールアドレスはリポジトリで管理せず、`~/.config/git/local`に保存します。GitとNeovimはHome Managerが管理するため、WSLでは対応するStowパッケージを適用しないでください。

### macOS

```bash
# 1. Homebrew のインストール (未導入の場合)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Brewfile からパッケージを一括インストール
brew bundle --file=~/.dotfiles/homebrew/Brewfile

# 3. Stow でシンボリックリンクを作成
cd ~/.dotfiles
stow zsh
stow nvim
stow wezterm
stow git
stow zeno
stow nb
stow claude
stow ghostty
stow lazygit
stow termrain
```

Brewfile を更新するには:

```bash
brew bundle dump --file=~/.dotfiles/homebrew/Brewfile --force
```

## 依存ツール

- [Homebrew](https://brew.sh)
- [Oh My Zsh](https://ohmyz.sh)
- [sheldon](https://github.com/rossmacarthur/sheldon) (zsh プラグインマネージャ)
- [zeno.zsh](https://github.com/yuki-yano/zeno.zsh) (スニペット・補完)
- [Neovim](https://neovim.io)
- [WezTerm](https://wezfurlong.org/wezterm/)
- [ghq](https://github.com/x-motemen/ghq) + [peco](https://github.com/peco/peco)
- [nb](https://xwmx.github.io/nb/)
- [pyenv](https://github.com/pyenv/pyenv) / [nvm](https://github.com/nvm-sh/nvm)
- [Claude Code](https://claude.ai/claude-code)
- [lazygit](https://github.com/jesseduffield/lazygit)
