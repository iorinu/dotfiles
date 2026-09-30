# dotfiles

macOSとWSL Ubuntuで使う個人設定ファイル群。

Nix/Home Managerへ段階的に移行しています。WSLではGit、Neovim、共通CLIをHome Managerで管理し、macOSでも`iori@macos`を適用済みです。macOSでは共通CLI、Neovim、lazygit・zeno・termrainの設定、`.nbrc`に加え、ZshをHome Managerへ移行済みです。ZshはmacOSで移行済み、WSLでは未移行です。Git設定・identityは対象外で、その他の設定は引き続きStowが管理します。Homebrewの共通CLIパッケージはまだ削除していないため、Nixとの重複があります。実装状況と今後の作業は[移行計画](docs/nix-migration.md)を参照してください。

## 構成

| ディレクトリ | 内容 |
|---|---|
| `zsh/` | 旧Stow用の`.zshrc`ソース（macOSの有効なエントリポイントは`modules/home/zsh/macos.zsh`。WSLのZshは未移行） |
| `.config/` | 追跡対象の共通設定ソース（Neovim、lazygit・zenoの`config.yml`、termrainの`config.example.toml`） |
| `.nbrc` | nb (ノートブック CLI) の設定ソース |
| `docs/nvim-plugins.md` | Neovimのプラグイン一覧 |
| `nvim/` | 従来パスに保持するGit管理外のローカル画像 |
| `wezterm/` | WezTerm ターミナル設定 — 透過・グラデーション背景、カスタムキーバインド |
| `git/` | `.gitconfig` — ghq root、GitHub credential 設定 |
| `claude/` | Claude Code の設定 |
| `.claude/` | Claude Code の skills |
| `codex/` | Codex の設定・LaunchAgent |
| `ghostty/` | Ghostty の設定 |
| `herdr/` | herdr の設定 |
| `hermes/` | Hermes の共通 SOUL・指示書、docs、skills |
| `opencode/` | OpenCode の設定 |
| `lazygit/` | 従来パスに保持するランタイムファイルと`.gitignore` |
| `homebrew/` | Brewfile — Homebrew でインストールしたパッケージ一覧 |
| `termrain/` | 従来パスに保持するGit管理外`config.toml` |

追跡対象の共通設定ソースを新配置へ集約し、対応する旧追跡ソース48ファイルを削除しました。HermesがmacOSでgeneration 5への適用と新ソースへのライブリンクを確認済みです。設定内容・プラグイン名は変更していません。引き続きStowで管理するパッケージは変更していません。

ランタイムファイルとGit管理外のローカルファイルは従来パスに残しています。画像も移動せず、`.config/nvim/amadeus_frames`から`../../nvim/.config/nvim/amadeus_frames`へのローカルリンクで参照します。このリンクはGit・Home Managerの管理外です。WSLではNixのNeovimソース参照のみ更新し、今回の配置変更の適用は未検証です。

## セットアップ

### WSL Ubuntu

WSL用の構成名は`iori@wsl`です。ユーザー`iori`のホームを`/home/iori`、リポジトリを`/home/iori/clone/dotfiles`とする構成です。この環境ではNix/Home Managerの導入と適用が完了しています。現在Home Managerは共通CLI、Git、Neovim設定に加え、BashとZshのユーザー設定を管理します。Bashを既定シェルとして維持し、Zshもインストール・設定管理しますが、ログインシェルの切り替えは行いません。移行範囲と未移行項目は[移行計画](docs/nix-migration.md)を参照してください。

```bash
cd /home/iori/clone/dotfiles
nix flake check path:.
home-manager switch --flake path:.#iori@wsl
```

この配置変更をpullした後は、上記の手順でHome Managerを再適用してNeovimのリンク先を更新してください。ローカル画像は管理対象外のため、そのホストでも必要に応じて旧画像パスへのリンクを用意してください。今回の変更についてWSL上での適用・動作確認は行っていません。

WSLのHome Manager設定ではGitのユーザー名とメールアドレスを設定せず、`~/.config/git/local`を読み込みます。Bash設定ではUbuntuのシステム設定とLinuxbrew・Cargo・fzf・CUDA・WezTerm連携を維持し、存在確認をしてから読み込みます。既存の`~/.bashrc`、`~/.zshrc`、`~/.bash_aliases`は適用前にバックアップし、Bash/Zshの設定ファイルはHome Manager所有へ切り替えます。GitとNeovimもHome Manager管理のため、WSLでは対応するStowパッケージを適用しないでください。

### macOS

Home Manager構成`iori@macos`は適用済みで、generation 5が現在の世代、generation 4、3、2、1が利用可能です。macOS arm64上で`nix flake check --no-write-lock-file`とmacOS activation packageのビルドが成功しています。既存の`unknown flake output homeManagerModules`警告は出ます。Home ManagerはユーザーNix設定で`nix-command`と`flakes`を管理します。`home-manager`、`bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`nvim`、`rg`、`zoxide`は`~/.nix-profile/bin`から解決されます。`~/.config/nvim`はHome Managerのリンクでリポジトリの`.config/nvim`を参照し、切替後もヘッドレス起動に成功しました（従来と同じ51個のプラグイン名、45個の画像フレームへのアクセスを確認。以前の初期起動では23個をロード。遅延ロードされる個別プラグインの動作は未確認）。VimTeXの`view_method`は`skim`です。NeovimのStowリンクは`~/.config/nvim.stow-backup`に保存されています。`~/.config/lazygit`は実ディレクトリで、Home Manager管理の`config.yml`リンクがリポジトリの`.config/lazygit/config.yml`を参照します。以前のStowディレクトリリンクは`~/.config/lazygit.stow-backup`に保存されています。`state.yml`と`github_pull_requests.json`はHome Managerの管理対象ではなく、ライブディレクトリ内の個別リンクから元のリポジトリパスを参照します。Nix版lazygit v0.65.1で実設定を使った一時リポジトリの起動を確認し、日本語UIが表示され、`q`で終了しました。元の状態ファイルを使わずに設定の読み込みを確認しています。Home Managerはzenoの`config.yml`、`.nbrc`、termrainのサンプル設定と既存のローカル`config.toml`へのリンクも管理します。追跡対象の3つは新配置のソース、termrainの実設定は従来の`termrain/.config/termrain/config.toml`を参照し、以前のStowリンクは`~/.config/zeno.stow-backup`、`~/.nbrc.stow-backup`、`~/.config/termrain.stow-backup`に保存されています。termrainの実設定はGit管理外のローカルファイルで、内容を確認せずNix storeにも取り込んでいません。隔離した環境で`.nbrc`の読み込みを`EDITOR=nvim`および`NB_DIR`設定下で確認しましたが、nbのノート操作は未確認です。zenoのネイティブ動作、termrain実設定の構文やネットワーク機能も未検証です。Git設定・Git identityはHome Managerの対象外で、その他のmacOS設定はStow管理です。Homebrewの共通CLIパッケージは未削除のため、当面Nixと重複しています。

旧世代や保存済みStowリンクへ戻す前には、変更前のGitリビジョンまたは保持したローカルバックアップから旧ソース配置を復元してください。旧リンクは削除済みのソースを参照するため、世代切替やリンク復帰だけでは戻せません。詳しくは[ロールバック](docs/nix-migration.md#ロールバック)を参照してください。

```bash
# 1. Homebrew のインストール (未導入の場合)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Brewfile からパッケージを一括インストール
brew bundle --file=~/.dotfiles/homebrew/Brewfile

# 3. Stow でシンボリックリンクを作成
cd ~/.dotfiles
stow wezterm
stow git
stow claude
stow ghostty
```

このMacではZsh、Neovim、lazygit、zeno、nb、termrainの設定をHome Managerへ移行済みです。`stow zsh`、`stow nvim`、`stow lazygit`、`stow zeno`、`stow nb`、`stow termrain`は実行しないでください。Zshの旧リンクは`~/.zshrc.stow-backup`に保持しています。その他のStow時代のリンクはそれぞれ`~/.config/nvim.stow-backup`、`~/.config/lazygit.stow-backup`、`~/.config/zeno.stow-backup`、`~/.nbrc.stow-backup`、`~/.config/termrain.stow-backup`に保存されています。WSLのZsh設定は未移行です。

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
