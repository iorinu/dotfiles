# dotfiles

macOSとWSL Ubuntuで使う個人設定ファイル群。

Nix/Home Managerへ段階的に移行しています。WSLではGit、Neovim、共通CLIをHome Managerで管理し、macOSでも`iori@macos`を適用済みです。macOSでは共通CLI、Neovim設定、lazygitの`config.yml`をHome Managerが管理し、Git設定・identityは対象外、その他の設定は引き続きStowが管理します。Homebrewの共通CLIパッケージはまだ削除していないため、Nixとの重複があります。実装状況と今後の作業は[移行計画](docs/nix-migration.md)を参照してください。

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

Home Manager構成`iori@macos`は適用済みで、`home-manager generations`ではgeneration 2が現在の世代、generation 1が利用可能です。macOS arm64上で`nix flake check --no-write-lock-file`とmacOS activation packageのビルドが成功しています。既存の`unknown flake output homeManagerModules`警告は出ます。Home ManagerはユーザーNix設定で`nix-command`と`flakes`を管理します。`home-manager`、`bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`nvim`、`rg`、`zoxide`は`~/.nix-profile/bin`から解決されます。`~/.config/nvim`はHome ManagerのリンクでリポジトリのNeovim設定を参照し、ヘッドレス起動で設定読み込みを確認済みです（設定済みプラグインディレクトリ51個、起動時ロード23個。遅延ロードされる個別プラグインの動作は未確認）。VimTeXの`view_method`は`skim`です。NeovimのStowリンクは`~/.config/nvim.stow-backup`に保存されています。`~/.config/lazygit`は実ディレクトリで、Home Manager管理の`config.yml`リンクがリポジトリの設定を参照します。以前のStowディレクトリリンクは`~/.config/lazygit.stow-backup`に保存されています。`state.yml`と`github_pull_requests.json`はHome Managerの管理対象ではなく、ライブディレクトリ内の個別リンクから元のリポジトリパスを参照します。Nix版lazygit v0.65.1で実設定を使った一時リポジトリの起動を確認し、日本語UIが表示され、`q`で終了しました。元の状態ファイルを使わずに設定の読み込みを確認しています。Git設定・Git identityはHome Managerの対象外で、その他のmacOS設定はStow管理です。Homebrewの共通CLIパッケージは未削除のため、当面Nixと重複しています。

```bash
# 1. Homebrew のインストール (未導入の場合)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Brewfile からパッケージを一括インストール
brew bundle --file=~/.dotfiles/homebrew/Brewfile

# 3. Stow でシンボリックリンクを作成
cd ~/.dotfiles
stow zsh
stow wezterm
stow git
stow zeno
stow nb
stow claude
stow ghostty
stow termrain
```

このMacではNeovim設定とlazygitの設定をHome Managerへ移行済みです。`stow nvim`と`stow lazygit`は実行しないでください。Stow時代のリンクはそれぞれ`~/.config/nvim.stow-backup`、`~/.config/lazygit.stow-backup`に保存されています。WSLのlazygit設定は未移行です。

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
