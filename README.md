# dotfiles

macOS 用の個人設定ファイル群。GNU Stow でシンボリックリンクを管理する構成。

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
| `homebrew/` | Brewfile — Homebrew でインストールしたパッケージ一覧 |

## セットアップ

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
