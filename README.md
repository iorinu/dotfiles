# dotfiles

macOSとWSL Ubuntuで使う個人設定ファイル群。

Nix/Home Managerへ段階的に移行しています。WSLではGit、Neovim、共通CLI、Bash、ZshをHome Managerで管理し、macOSでも`iori@macos`を適用済みです。macOSでは共通CLI、Neovim、Zsh、lazygit・zeno・termrainの設定、`.nbrc`、AI設定、Ghostty/WezTerm/herdr設定を移行済みです。現在のgenerationは6です。Git設定・identityは対象外です。Homebrewの共通CLIパッケージはまだ削除していないため、Nixとの重複があります。実装状況と今後の作業は[移行計画](docs/nix-migration.md)を参照してください。

## 構成

| ディレクトリ | 内容 |
|---|---|
| `zsh/` | 旧Stow用の`.zshrc`ソース（有効なエントリポイントはmacOSが`modules/home/zsh/macos.zsh`、WSLはHome Manager設定） |
| `.config/` | 共通設定ソース（Neovim、lazygit、zeno、termrain）、AI非認証設定、GUI設定（ghostty、wezterm、herdr） |
| `.nbrc` | nb (ノートブック CLI) の設定ソース |
| `docs/nvim-plugins.md` | Neovimのプラグイン一覧 |
| `nvim/` | 従来パスに保持するGit管理外のローカル画像 |
| `wezterm/` | WezTerm ターミナル設定 — 透過・グラデーション背景、カスタムキーバインド |
| `git/` | `.gitconfig` — ghq root、GitHub credential 設定 |
| `claude/` | 切り替え前のClaude Code設定ソース（保持中） |
| `.claude/` | プロジェクト用Claude Code skills（今回の移行対象外） |
| `codex/` | 切り替え前のCodex設定・LaunchAgentソース（保持中） |
| `ghostty/` | Ghostty の設定 |
| `herdr/` | herdr の設定 |
| `hermes/` | 切り替え前のHermesソースとGit追跡済み`config.yaml`（保持中） |
| `opencode/` | 切り替え前のOpenCode設定ソース（保持中） |
| `lazygit/` | 従来パスに保持するランタイムファイルと`.gitignore` |
| `homebrew/` | Brewfile — Homebrew でインストールしたパッケージ一覧 |
| `termrain/` | 従来パスに保持するGit管理外`config.toml` |

追跡対象の共通設定ソースを新配置へ集約し、対応する旧追跡ソース48ファイルを削除しました。以前の配置整理はgeneration 5で適用し、新ソースへのライブリンクを確認済みです。現在はgeneration 6が有効で、generation 1〜6が利用可能です。設定内容・プラグイン名は変更していません。

ランタイムファイルとGit管理外のローカルファイルは従来パスに残しています。画像も移動せず、`.config/nvim/amadeus_frames`から`../../nvim/.config/nvim/amadeus_frames`へのローカルリンクで参照します。このリンクはGit・Home Managerの管理外です。WSLでは配置整理後のNeovimソース参照宣言を更新済みですが、新配置の適用・動作確認は未検証です。今後のmacOS移行にWSL検証を必須条件とはしません。

AI設定はmacOSでHome Managerへ切り替え済みです。追跡済み旧ソース14ファイルを復元・他Stow利用者向けに保持し、旧Stowリンク18件は同じ親ディレクトリの`.stow-backup-nix-20261001T154203`名で退避しました。AI 15 leaf（14非認証ファイルと従来パスのHermes YAMLリンク）はHome Manager管理です。旧ソースと新配置コピーの差分はSOUL末尾のCodex参照先変更のみです。Hermes YAMLの内容は確認対象外です。プロジェクトの`.claude/skills`も対象外です。

Ghostty、WezTerm、herdrの追跡設定4ファイルは`.config/{ghostty,wezterm,herdr}/`に配置し、macOS構成の個別leafとしてHome Managerへ切り替え済みです。GUIアプリ導入はHomebrewのままで、ディレクトリ全体は管理しません。GUI 4 leafもHome Manager管理で、AIと合わせて現在generation 6です。退避した旧Stowリンク18件のリンク文字列と解決先は維持しています。WezTermは旧親ディレクトリリンクを退避し、同名の実ディレクトリに設定2 leafを配置しました。herdrのログ・socket・session.json等のランタイム、AIの認証情報・ログ・他プロフィールは対象外です。旧ソースは復元・他Stow利用者のため保持します。

AI・GUI設定はHermesのレビューと明示承認後に実適用済みです。移行済みAI/GUIパッケージをStowで再適用しないでください。通常のmacOS更新は`home-manager switch --flake .#iori@macos --no-write-lock-file`を使います。未移行の既存Stowホストでは、再適用前に所有切替手順が必要です。WSLのAI設定は未移行です。旧追跡ソースはWSLや他のStow利用者、復元のため保持します。

## セットアップ

### WSL Ubuntu

WSL用の構成名は`iori@wsl`です。ユーザー`iori`のホームを`/home/iori`、リポジトリをghq管理下の`/home/iori/src/github.com/iorinu/dotfiles`とする構成です。この環境ではNix/Home Managerの導入と適用が完了しています。現在Home Managerは共通CLI、Git、Neovim設定に加え、BashとZshのユーザー設定を管理します。Bashを既定シェルとして維持し、Zshもインストール・設定管理しますが、ログインシェルの切り替えは行いません。移行範囲と未移行項目は[移行計画](docs/nix-migration.md)を参照してください。

```bash
cd /home/iori/src/github.com/iorinu/dotfiles
nix flake check path:.
home-manager switch --flake path:.#iori@wsl
```

Neovimの配置整理後の参照宣言は更新済みですが、WSLでの新配置適用・動作確認は未検証です。ローカル画像は管理対象外のため、そのホストでも必要に応じて旧画像パスへのリンクを用意してください。

WSLのHome Manager設定ではGitのユーザー名とメールアドレスを設定せず、`~/.config/git/local`を読み込みます。Bash設定ではUbuntuのシステム設定とLinuxbrew・Cargo・fzf・CUDA・WezTerm連携を維持し、存在確認をしてから読み込みます。既存の`~/.bashrc`、`~/.zshrc`、`~/.bash_aliases`は適用前にバックアップし、Bash/Zshの設定ファイルはHome Manager所有へ切り替えます。GitとNeovimもHome Manager管理のため、WSLでは対応するStowパッケージを適用しないでください。

### macOS

Home Manager構成`iori@macos`は適用済みで、generation 6が現在の世代、generation 1〜6が利用可能です。macOS arm64上で`nix flake check --no-write-lock-file`とmacOS activation packageのビルドが成功しています。既存の`unknown flake output homeManagerModules`警告は出ます。Home ManagerはユーザーNix設定で`nix-command`と`flakes`を管理します。`home-manager`、`bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`nvim`、`rg`、`zoxide`は`~/.nix-profile/bin`から解決されます。`~/.config/nvim`はHome Managerのリンクでリポジトリの`.config/nvim`を参照し、以前の配置整理後はヘッドレス起動に成功しました（従来と同じ51個のプラグイン名、45個の画像フレームへのアクセスを確認。以前の初期起動では23個をロード。遅延ロードされる個別プラグインの動作は未確認）。VimTeXの`view_method`は`skim`です。NeovimのStowリンクは`~/.config/nvim.stow-backup`に保存されています。`~/.config/lazygit`は実ディレクトリで、Home Manager管理の`config.yml`リンクがリポジトリの`.config/lazygit/config.yml`を参照します。以前のStowディレクトリリンクは`~/.config/lazygit.stow-backup`に保存されています。`state.yml`と`github_pull_requests.json`はHome Managerの管理対象ではなく、ライブディレクトリ内の個別リンクから元のリポジトリパスを参照します。Nix版lazygit v0.65.1で実設定を使った一時リポジトリの起動を確認し、日本語UIが表示され、`q`で終了しました。元の状態ファイルを使わずに設定の読み込みを確認しています。Home Managerはzenoの`config.yml`、`.nbrc`、termrainのサンプル設定と既存のローカル`config.toml`へのリンクも管理します。追跡対象の3つは新配置のソース、termrainの実設定は従来の`termrain/.config/termrain/config.toml`を参照し、以前のStowリンクは`~/.config/zeno.stow-backup`、`~/.nbrc.stow-backup`、`~/.config/termrain.stow-backup`に保存されています。termrainの実設定はGit管理外のローカルファイルで、内容を確認せずNix storeにも取り込んでいません。隔離した環境で`.nbrc`の読み込みを`EDITOR=nvim`および`NB_DIR`設定下で確認しましたが、nbのノート操作は未確認です。zenoのネイティブ動作、termrain実設定の構文やネットワーク機能も未検証です。Git設定・Git identityはHome Managerの対象外で、Homebrewの共通CLIパッケージは未削除のためNixと重複しています。

配置整理前の世代や共通設定の旧Stowリンクに戻す場合は、変更前のGitリビジョンまたは保持したローカルバックアップから旧ソース配置を復元してください。今回移行したAI・GUIの旧ソースは残しており、generation 5への切り戻しと18リンクの復元手順を記録しています。復帰操作自体は未検証です。詳しくは[ロールバック](docs/nix-migration.md#ロールバック)を参照してください。

```bash
# 1. Homebrew のインストール (未導入の場合)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Brewfile からパッケージを一括インストール
brew bundle --file=~/.dotfiles/homebrew/Brewfile

# 3. Git設定だけStowで配置（移行済みパッケージは再適用しない）
cd ~/.dotfiles
stow git
```

このMacではAI・GUIを含む移行済みパッケージをStowで再適用しないでください。通常の更新には`home-manager switch --flake .#iori@macos --no-write-lock-file`を使います。未移行Stowホストでは、再適用前に所有切替手順を行ってください。旧Stowリンクの復元記録（19 leafのHome Manager管理対象と18 linkの退避先）は`/Users/iori/.local/state/dotfiles-backups/nix-ai-gui-20261001T154203/`のmanifestを参照してください。Zshの旧リンクは`~/.zshrc.stow-backup`に保持しています。その他のStow時代のリンクはそれぞれ`~/.config/nvim.stow-backup`、`~/.config/lazygit.stow-backup`、`~/.config/zeno.stow-backup`、`~/.nbrc.stow-backup`、`~/.config/termrain.stow-backup`に保存されています。

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
