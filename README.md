# dotfiles

macOSとWSL Ubuntuで使う個人設定ファイル群。

Nix/Home Managerへ段階的に移行しています。FlakeにはmacOS向けの`iori@macos`出力を宣言し、共通CLIとNeovimを設定していますが、macOSには適用していません。macOSのライブ設定パスは引き続きGNU Stowが管理し、Git設定はmacOSのHome Manager対象外です。WSLではGit、Neovim、共通CLIをHome Managerで管理します。実装状況と今後の作業は[移行計画](docs/nix-migration.md)を参照してください。

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
| `.claude/` | Claude Code の skills |
| `codex/` | Codex の設定・LaunchAgent |
| `ghostty/` | Ghostty の設定 |
| `herdr/` | herdr の設定 |
| `hermes/` | Hermes の共通 SOUL・指示書、docs、skills |
| `opencode/` | OpenCode の設定 |
| `lazygit/` | lazygit の設定 (`gui.language: ja` で UI 日本語化) |
| `homebrew/` | Brewfile — Homebrew でインストールしたパッケージ一覧 |
| `termrain/` | termrain (ターミナル天気/レーダー CLI) の設定 |

## セットアップ

### WSL Ubuntu

WSL用の構成名は`iori@wsl`です。現在のホスト設定は、ユーザー`iori`のホームを`/home/iori`とし、リポジトリを`/home/iori/clone/dotfiles`へ配置する前提です。NixとHome Managerを導入済みで、Flake機能が使える環境で次を実行してください。これらは導入手順ではなく、既存構成の検証・適用コマンドです。

```bash
cd /home/iori/clone/dotfiles
nix flake check path:.
home-manager switch --flake path:.#iori@wsl
```

WSLのHome Manager設定ではGitのユーザー名とメールアドレスを設定せず、`~/.config/git/local`を読み込みます。なお、macOS向けStowソースのGit設定にはこれらの項目が残っており、別途移行するまでリポジトリ内から完全に除外された状態ではありません。GitとNeovimはWSLでHome Managerが管理するため、WSLでは対応するStowパッケージを適用しないでください。

### macOS

Home Manager構成`iori@macos`は宣言済みです。macOS arm64上のNix 2.35.2で、リポジトリから直接`nix --extra-experimental-features "nix-command flakes" flake check --no-write-lock-file`と`nix --extra-experimental-features "nix-command flakes" build --no-link --no-write-lock-file '.#homeConfigurations."iori@macos".activationPackage'`が成功しました。checkでは既存の`unknown flake output homeManagerModules`警告が出ましたが、checkは成功しています。ビルドは適用しておらず、ライブ設定に変更はありません。ライブ設定パスの所有者は引き続きStowです。Home Managerは共通CLIとNeovim設定を対象とし、Git設定・Git identityは管理しません。

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

このコマンド一覧はmacOS向けの選択した基本構成です。他のパッケージは対象パスと利用環境を個別に確認してから適用してください。

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
