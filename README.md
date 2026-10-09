# dotfiles

macOSとWSL Ubuntuで使う個人設定ファイル群。

Nix/Home Managerへ段階的に移行しています。WSLではGit、Neovim、共通CLI、Bash、Zsh、AI設定をHome Managerで管理し、macOSでも`iori@macos`を適用済みです。macOSでは共通CLI、Neovim、Zsh、lazygit・zeno・termrainの設定、`.nbrc`、AI設定、Ghostty/WezTerm/herdr設定を移行済みです。Git設定・identityは対象外です。Homebrewの重複CLI 9種（`bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`neovim`、`zoxide`）は削除済みで、`ripgrep`はNix版をユーザーPATHに、Homebrew版をHomebrew `opencode`の依存として維持しています。実装状況と検証範囲は[移行計画](docs/nix-migration.md)を参照してください。

今回の受入範囲では、通常のZsh起動/Keychain、ZLE UI、残りのNeovimプラグイン/LSP/AI、GUI操作、実ノート・天気/ネットワークなどの追加実環境検証と実際のrollbackは必須ではなく、未検証の制限として記録しています。Neovimのプラグイン管理はlazy.nvimを継続し、macOSシステム設定をNix/nix-darwinで管理する予定はありません。HomebrewのFormula整理などは未決で、実施承認されていません。詳細は[移行計画](docs/nix-migration.md)を参照してください。

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

追跡対象の共通設定ソースを新配置へ集約し、対応する旧追跡ソース48ファイルを削除しました。以前の配置整理はgeneration 5で適用し、新ソースへのライブリンクを確認済みです。2026-10-08の承認済み更新適用後、generation 7が有効で、generation 1〜7が利用可能です。設定内容・プラグイン名は変更していません。

ランタイムファイルとGit管理外のローカルファイルは従来パスに残しています。画像も移動せず、`.config/nvim/amadeus_frames`から`../../nvim/.config/nvim/amadeus_frames`へのローカルリンクで参照します。このリンクはGit・Home Managerの管理外です。WSLでは配置整理後のNeovimソース参照宣言を更新済みですが、新配置の適用・動作確認は未検証です。今後のmacOS移行にWSL検証を必須条件とはしません。

AI設定はmacOSでHome Managerへ切り替え済みです。追跡済み旧ソース14ファイルを復元・他Stow利用者向けに保持し、旧Stowリンク18件は同じ親ディレクトリの`.stow-backup-nix-20261001T154203`名で退避しました。AI 15 leaf（14非認証ファイルと従来パスのHermes YAMLリンク）はHome Manager管理です。旧ソースと新配置コピーの差分はSOUL末尾のCodex参照先変更のみです。Hermes YAMLの内容は確認対象外です。プロジェクトの`.claude/skills`も対象外です。

Ghostty、WezTerm、herdrの追跡設定4ファイルは`.config/{ghostty,wezterm,herdr}/`に配置し、macOS構成の個別leafとしてHome Managerへ切り替え済みです。GUIアプリ導入はHomebrewのままで、ディレクトリ全体は管理しません。GUI 4 leafもHome Manager管理で、AIと合わせてgeneration 7が有効です。退避した旧Stowリンク18件のリンク文字列と解決先は維持しています。WezTermは旧親ディレクトリリンクを退避し、同名の実ディレクトリに設定2 leafを配置しました。herdrのログ・socket・session.json等のランタイム、AIの認証情報・ログ・他プロフィールは対象外です。旧ソースは復元・他Stow利用者のため保持します。

AI設定はmacOSとWSLの両方でHome Managerへ移行済みです。macOS専用のCodex LaunchAgent、ChatGPT Desktop連携、RunCat定期処理はWSLへ移植していません。認証情報、履歴、ログ、ランタイムデータは管理対象外です。移行済みAI/GUIパッケージをStowで再適用しないでください。

## セットアップ

### WSL Ubuntu

WSL用の構成名は`iori@wsl`です。ユーザー`iori`のホームを`/home/iori`、リポジトリをghq管理下の`/home/iori/src/github.com/iorinu/dotfiles`とする構成です。この環境ではNix/Home Managerの導入と適用が完了しています。現在Home Managerは共通CLI、Git、Neovim設定に加え、BashとZshのユーザー設定を管理します。Bashを既定シェルとして維持し、Zshもインストール・設定管理しますが、ログインシェルの切り替えは行いません。移行範囲と未移行項目は[移行計画](docs/nix-migration.md)を参照してください。

```bash
cd /home/iori/src/github.com/iorinu/dotfiles
nix flake check path:.
home-manager switch --flake path:.#iori@wsl
```

Neovimの配置整理後の参照宣言は更新済みですが、WSLでの新配置適用・動作確認は未検証です。ローカル画像は管理対象外のため、そのホストでも必要に応じて旧画像パスへのリンクを用意してください。

WSLのHome Manager設定ではGitのユーザー名とメールアドレスを設定せず、`~/.config/git/local`を読み込みます。Bash設定ではUbuntuのシステム設定とLinuxbrew・Cargo・fzf・CUDA・WezTerm連携を維持し、存在確認をしてから読み込みます。既存の`~/.bashrc`、`~/.zshrc`、`~/.bash_aliases`は適用前にバックアップし、Bash/Zshの設定ファイルはHome Manager所有へ切り替えます。Git、Neovim、AI設定もHome Manager管理のため、WSLでは対応するStowパッケージを適用しないでください。

### macOS

Home Manager構成`iori@macos`は適用済みで、generation 7が現在の世代、generation 1〜7が利用可能です。macOS arm64上で`home-manager switch --flake '.#iori@macos' --no-write-lock-file`が2026-10-08に成功しました。CLIと設定の限定検証、適用内容および検証上の制限は[2026-10-08更新記録](docs/nix-migration.md#2026-10-08-更新適用と検証記録)を参照してください。以前の検証は[2026-10-07検証記録](docs/nix-migration.md#2026-10-07-検証と復旧記録)に記録しています。

現在のgeneration 7から2026-10-08の更新前へ戻す場合に保持している世代はgeneration 6です。AI/GUI切替前のgeneration 5へ戻す手順とは別で、いずれも実切り戻しには別途明示承認が必要です。世代切替だけでは旧Stowリンクやout-of-storeの現在のZshソースは戻りません。詳しくは[ロールバック](docs/nix-migration.md#ロールバック)、[2026-10-08更新記録](docs/nix-migration.md#2026-10-08-更新適用と検証記録)、[2026-10-07検証記録](docs/nix-migration.md#2026-10-07-検証と復旧記録)を参照してください。

```bash
# 1. Homebrew のインストール (未導入の場合)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Brewfile からパッケージを一括インストール
brew bundle --file=~/.dotfiles/homebrew/Brewfile

# 3. Git設定だけStowで配置（移行済みパッケージは再適用しない）
cd ~/.dotfiles
stow git
```

このMacではAI・GUIを含む移行済みパッケージをStowで再適用しないでください。設定だけを変更した場合は、既存の`flake.lock`を使ってHome Managerを適用します。入力パッケージも更新する場合は、[macOSでの更新手順](docs/nix-migration.md#macosでの更新)を参照してください。未移行Stowホストでは、再適用前に所有切替手順を行ってください。旧Stowリンクの復元記録（19 leafのHome Manager管理対象と18 linkの退避先）は`/Users/iori/.local/state/dotfiles-backups/nix-ai-gui-20261001T154203/`のmanifestを参照してください。Zshの旧リンクは`~/.zshrc.stow-backup`に保持しています。その他のStow時代のリンクはそれぞれ`~/.config/nvim.stow-backup`、`~/.config/lazygit.stow-backup`、`~/.config/zeno.stow-backup`、`~/.nbrc.stow-backup`、`~/.config/termrain.stow-backup`に保存されています。

このコマンド一覧はmacOS向けの選択した基本構成です。他のパッケージは対象パスと利用環境を個別に確認してから適用してください。

Brewfile を更新するには:

```bash
brew bundle dump --file=~/.dotfiles/homebrew/Brewfile --force
```

## 更新

設定だけの変更は、ロック済みの構成をHome Managerで適用します。Nixパッケージ、HomebrewのFormula/Cask、Neovimプラグインを更新する手順は[macOSでの更新](docs/nix-migration.md#macosでの更新)を参照してください。

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
