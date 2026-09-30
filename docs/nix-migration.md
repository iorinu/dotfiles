# macOS と WSL Ubuntu の Nix 移行計画

## 概要

このリポジトリの設定を、macOSと実験用のWSL Ubuntuから同じソースで管理できるようにするための移行計画を記録する。

最初からすべてをNixへ置き換えず、次の構成を目標に段階的に移行する。

- macOSのユーザー環境: Home Manager
- macOSのシステム設定: 必要になった段階でnix-darwin
- WSL Ubuntuのユーザー環境: Home Manager
- macOSのGUIアプリ: Homebrewを継続利用
- Windows側のGUIアプリ: Windows側で管理
- 共通設定とホスト固有設定: 1つのNix Flakeで管理
- 認証情報、履歴、キャッシュ、生成ファイル: 管理対象外

ここでいう「一元管理」は、両方のOSを同じ内容にすることではない。共通部分の正本を1つにし、OS固有の差分を同じリポジトリ内で明示することを指す。

## 現在の構成

現在はGNU Stowでパッケージごとのファイルをホームディレクトリへ配置している。Homebrewのパッケージ一覧は`homebrew/Brewfile`で管理している。

主なパッケージは次のとおり。

| パッケージ | 主な内容 | 移行候補 |
|---|---|---|
| `zsh/` | `.zshrc` | 共通部分をHome Manager、OS固有部分をホスト設定 |
| `nvim/` | Neovimとlazy.nvimの設定 | `home.file`または`xdg.configFile`から開始 |
| `wezterm/` | WezTerm設定 | 実際にGUIを実行するOS側で管理 |
| `git/` | `.gitconfig` | WSLのみHome Managerで管理。macOSでは対象外 |
| `zeno/` | zeno.zsh設定 | `xdg.configFile` |
| `nb/` | nb設定 | `xdg.configFile` |
| `claude/` | Claude Code設定 | 非認証設定だけを`home.file` |
| `.claude/` | Claude Codeのskills | 内容と配置先を確認して移行対象を判断 |
| `ghostty/` | Ghostty設定 | 実際にGUIを実行するOS側で管理 |
| `herdr/` | herdr設定 | 内容と利用環境を確認して判断 |
| `opencode/` | OpenCode設定 | 非認証設定を確認して移行対象を判断 |
| `lazygit/` | lazygit設定 | `xdg.configFile` |
| `termrain/` | termrain設定 | `xdg.configFile` |
| `codex/` | Codex設定とLaunchAgent | 設定はHome Manager、LaunchAgentはmacOS専用 |
| `hermes/` | 追跡対象の共通SOUL・指示書、docs、skills | Home Managerで配置 |
| `homebrew/` | Formula、Cask、Cargo、uv、npmなど | 共通CLIはNix、GUIとNixに載せにくいものはHomebrew |

## 現在の実装状況

`flake.nix`は`x86_64-linux`向けの`homeConfigurations."iori@wsl"`と、`aarch64-darwin`向けの`homeConfigurations."iori@macos"`を宣言する。共通モジュールは共通CLI（`bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`neovim`、`ripgrep`、`zoxide`）と、`dotfiles.nvimConfigPath`から`xdg.configFile."nvim"`へNeovim設定を配置する機能を提供する。Gitは独立モジュールで、WSLのみが従来どおり読み込む（`ghq.root = "~/src"`、既定ブランチ`main`、GitHub/Gistの認証helper、`~/.config/git/local` include）。WSLホスト設定はユーザー`iori`、ホームディレクトリ`/home/iori`、`stateVersion = "24.05"`、Neovim設定ソース`/home/iori/clone/dotfiles/nvim/.config/nvim`を維持する。macOSホスト設定はユーザー`iori`、ホーム`/Users/iori`、同じstateVersion、Neovim設定ソース`/Users/iori/.dotfiles/nvim/.config/nvim`を指定し、Gitを管理しない。NeovimのVimTeXはmacOSでSkimを指定し、LinuxではVimTeXの既定設定に任せる。

Nixpkgsは`nixos-unstable`を指定し、具体的なリビジョンを`flake.lock`で固定している。WSL側ではHome Managerの評価、ビルド、適用まで確認済みである。macOS arm64ではHome Managerの`iori@macos`へのswitchが成功し、`home-manager generations`ではgeneration 1が現在の世代として報告される。`nix flake check --no-write-lock-file`も実験機能フラグなしで成功するが、既存の`unknown flake output homeManagerModules`警告が出る。Home ManagerはユーザーNix設定で`nix-command`と`flakes`を有効化する。`home-manager`、`bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`nvim`、`rg`、`zoxide`は`~/.nix-profile/bin`から解決される。`~/.config/nvim`はHome Managerのリンクとなり、リポジトリのNeovim設定を参照する。以前のStowリンクは`~/.config/nvim.stow-backup`に保存されている。`nvim --version`はNVIM v0.12.5を示すが、設定の完全な起動確認は未実施である。Git設定とGit identityはmacOS Home Managerの対象外で、その他のmacOS設定は引き続きStowが管理する。Homebrewの共通CLIパッケージは削除しておらず、現在はNixと重複している。

Stow設定とHome Manager設定は、`ghq.root`、既定ブランチ、GitHub/Gist向け認証helperの動作を共有している。StowはHomebrewの絶対パスで`gh`を呼び出し、Home ManagerはPATHから`gh`を解決するため、Home Manager設定ではHomebrew固有のパスを避けられる一方、PATH上に`gh`が必要となる。

### 2026-09-30 WSL実環境での管理状況

このリポジトリをWSL Ubuntu 24.04.4（x86_64、ユーザー`iori`）で実際に検証し、`nix flake check path:.`、`home-manager build --flake path:.#iori@wsl`、`home-manager switch --flake path:.#iori@wsl`が成功した。Nix/Home Managerは作業開始時点ですでに導入済みだったため、再インストールはしていない。Flake checkでは既知の`unknown flake output 'homeManagerModules'`警告が出るが、check自体は成功する。

WSLのHome Manager管理範囲:

- 共通CLI: `bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`neovim`、`ripgrep`、`zoxide`
- 設定: `~/.config/nvim`（リポジトリのNeovim設定へのリンク）、Git設定（identityは含めず`~/.config/git/local`をinclude）
- Bash: `~/.bashrc`をHome Managerの`programs.bash`で管理。Ubuntuの`/etc/bash.bashrc`、bash-completion、Linuxbrew、Cargo、fzf、CUDA、WezTerm OSC 7を維持し、外部ツールは存在確認後に読み込む。既存の主要aliasとvenv aliasも宣言する。
- Zsh: Home Managerの`programs.zsh`で`~/.zshrc`を管理し、ZshをNixで導入。`~/go/bin`をPATHへ追加する。既定ログインシェルは引き続きBashであり、切り替えていない。

適用前の`~/.bashrc`、`~/.zshrc`、`~/.bash_aliases`は、`/home/iori/.local/state/dotfiles-backups/20260930T115523/`へ保存した。`.bash_aliases`の内容はBashの宣言設定へ移し、元ファイルは稼働設定として使用しない。`~/.profile`はNix installerの初期化を含むためそのまま残し、Home Managerから除外した。Home Manager生成の`.bash_profile`も無効にして、Bashが既存`.profile`を読み、その中から`.bashrc`を一度だけ読み込むようにしている。

未移行・対象外:

- `~/.profile`（Nix installerの初期化を含む既存ファイル）
- `~/.bash_aliases`のファイル自体（内容はNix設定に転記後、旧ファイルはバックアップ）
- システム設定、Windows側設定、認証情報・履歴・キャッシュ・ランタイムデータ
- macOSのその他Stow設定とHomebrewパッケージ整理

Home Managerの適用後は既存シェルには設定が遡及しないため、新しい対話シェルを起動して確認する。Home Manager世代と、Bash/Zsh設定リンク、代表的なコマンドの解決先を実環境で検証する。

## WSL側での更新

この実装状況は、既定の移行方針（WSL Ubuntuから試し、macOSを先に切り替えない）を変更しない。Nix/Home Managerの導入とFlake機能の有効化が済んだWSL環境で、現在の構成を更新するときはリポジトリのルートで次を実行する。

```sh
nix flake check path:.
home-manager switch --flake path:.#iori@wsl
```

GitとNeovimはHome Managerへ移行済みなので、WSLでは対応するStowパッケージを再適用しない。設定ファイルを追加で移す際も、受入条件に従って対象ごとにStowとの所有を切り替え、同一パスを両方で管理しない。移行方針どおりWSLを最初の試験対象とした後、macOSにもHome Managerを適用済みである。macOSではNeovimのStowパッケージを再適用しない。

現在の`.zshrc`には、次のようなmacOS固有の記述がある。これをそのまま共通設定としてWSLへ配置してはいけない。

- `/opt/homebrew/bin/brew`
- `/Library/TeX/texbin`
- `/Applications/Android Studio.app/...`
- `$HOME/Library/Android/sdk`
- `~/Library`を前提にしたパス
- macOSのLaunchAgentやGUIアプリを前提にした処理

## Nixで管理する範囲

### 共通で管理するもの

macOSとWSL Ubuntuの両方に存在し、同じ動作を期待するものを共通モジュールへ置く。

- Zshの共通alias、関数、環境変数
- Neovim設定
- lazygit、zeno、nbなどの設定
- `ripgrep`、`fd`、`fzf`、`bat`、`jq`、`zoxide`などのCLI
- Rust、Python、Nodeなどの開発ツールの基本セット
- Claude Code、Codex、Hermesの非認証設定

### macOSだけで管理するもの

- macOSのシステム設定
- Homebrew FormulaとCaskのうちmacOSでしか使わないもの
- MacTeX、Skim、Docker Desktop、Google ChromeなどのGUIアプリ
- Android Studioのパス
- macOS用のLaunchAgent
- macOS側で実行されるWezTerm設定

macOSのシステム設定まで宣言的に管理する必要が出たら、nix-darwinを追加する。最初の段階では、Home ManagerとHomebrewを併用する。

### WSL Ubuntuだけで管理するもの

- Linux用のCLIと開発ツール
- WSL内のPATH設定
- WSL内のユーザーサービス
- Linux側の設定ファイル
- WSL固有の環境変数

既存のUbuntuを使い続ける場合、NixはUbuntuの中にインストールする。これはUbuntuをNixOSへ置き換える作業ではない。

### Nixの管理対象にしないもの

次のものは、Nixのファイル配置対象に含めない。

- APIキー、アクセストークン、パスワード
- `auth.json`などの認証ファイル
- セッション履歴、SQLiteデータベース、キャッシュ
- アプリが実行中に生成するJSONやログ
- パッケージマネージャーの作業ディレクトリ
- WSLの`/mnt/c`配下にあるWindows側の設定

## 目標ディレクトリ構成

最初は次のようなFlake構成を想定する。名前は実装時に確定する。

```text
flake.nix
flake.lock
hosts/
  macbook.nix
  wsl-ubuntu.nix
modules/
  home/
    common.nix
    macos.nix
    wsl.nix
  darwin/
    default.nix
  homebrew/
    macos.nix
```

役割は次のとおり。

- `flake.nix`: 入力、Home Manager、macOS用とWSL用の出力を定義する
- `flake.lock`: Nixpkgsなどの入力バージョンを固定する
- `modules/home/common.nix`: OSに依存しないユーザー設定とパッケージ
- `modules/home/macos.nix`: macOSのユーザー設定
- `modules/home/wsl.nix`: WSL Ubuntuのユーザー設定
- `modules/darwin/default.nix`: 将来のnix-darwin設定
- `modules/homebrew/macos.nix`: macOSで残すHomebrewの管理
- `hosts/*.nix`: ホストごとの組み合わせと差分

設定ファイルをそのまま配置するものは、次のどちらかを使う。

- `home.file`: ホーム直下のファイルや任意の相対パス
- `xdg.configFile`: `~/.config`配下の設定

GitやZshなど、Home Managerに適切なモジュールがあるものは、ファイルの直接配置よりもモジュールを優先する。ただし、既存設定を壊さずに移行する最初の段階では、`home.file`や`xdg.configFile`で動作を再現してから、必要なものだけモジュール化する。

## 移行方針

### 方針1: WSLを最初の試験対象にする

普段使うmacOSを最初に切り替えず、現在うまく整っていないWSL Ubuntuから始める。WSL側で問題が起きても、macOSの作業環境には影響しにくい。

### 方針2: 既存のUbuntuを残す

最初の移行ではNixOS-WSLへ移行しない。Ubuntu、WSL、Windowsとの連携を残したまま、WSL内のユーザー環境だけをNixで管理する。

NixOS-WSLは、Linux側のシステム設定まで完全に宣言管理したくなった段階で別途検討する。ディストリビューションの移行を、Home Manager導入と同時に行わない。

### 方針3: StowとNixで同じパスを同時に管理しない

例えば`~/.config/nvim`をHome Managerに移したら、NeovimについてはStowを適用しない。両方が同じパスを所有すると、リンクの競合や適用順序による上書きが起きる。

移行途中は、次のどちらかの状態にする。

```text
Stowが管理する
または
Home Managerが管理する
```

### 方針4: まずファイル配置、次に宣言的なモジュール化

最初からすべての設定をNixの属性へ書き換えない。次の2段階に分ける。

1. 既存設定をHome Managerから正しい場所へ配置する
2. 動作確認後、GitやZshなどをHome Managerのモジュールへ移す

この順番なら、Nix化による変更と設定内容の変更を分離できる。

## 段階的な移行手順

### Phase 0: 現在の状態を記録する

移行前に、macOSとWSL Ubuntuで次の情報を記録する。認証情報や個人情報の値は記録しない。

- OSとアーキテクチャ
- 使用しているシェル
- `command -v`で確認できる主要コマンドのパス
- Neovimがヘッドレス起動できるか
- Git、Zsh、lazygit、Neovimの設定ファイルの実体とリンク先
- WSLでsystemdを使うかどうか
- WezTermをmacOS、Windows、WSLのどこで実行しているか
- Homebrewのうち、macOS専用のFormulaとCask

この時点ではStowの適用状態を変更しない。

### Phase 1: WSL UbuntuへNixを導入する

WSL側の記録では、公式インストーラーによるNix 2.35.2のシングルユーザー構成を導入し、`nix-command`と`flakes`を有効にしてHome Managerを利用している。これはWSLの導入記録であり、このmacOSホストでの検証結果やFlakeが固定するNixのバージョンではない。systemd連携の有無は引き続き確認する。

リポジトリは、可能ならWSLのLinuxファイルシステム側に配置する。`/mnt/c`配下を正本にすると、ファイルアクセスや権限、改行コード、シンボリックリンクの扱いで問題が起きやすい。

この段階で確認すること:

- `nix`がWSL内で実行できる
- `nix flake`を利用できる
- Home Managerをユーザー単位で適用できる
- 既存のUbuntuのシェルやパッケージを壊していない
- Windows側のPATHが意図せず大量に混ざっていない

### Phase 2: Flakeの骨格を作る（実装済み・macOS適用済み）

`flake.nix`は共通モジュールと、`x86_64-linux`向けの`homeConfigurations."iori@wsl"`、`aarch64-darwin`向けの`homeConfigurations."iori@macos"`を公開する。macOS構成は共通CLIとNeovim設定を対象にし、Git設定・identityは対象外とする。macOS arm64で`nix flake check --no-write-lock-file`が実験機能フラグなしで成功し、既存の`unknown flake output homeManagerModules`警告が出ることを確認した。さらにHome Managerのswitchが成功し、現在の世代はgeneration 1である。Neovim設定のリンク先はリポジトリ内の設定で、Stow時代のリンクは`~/.config/nvim.stow-backup`に保持している。Gitとその他のmacOSライブ設定はHome Managerへ移しておらず、引き続きGitは対象外、その他はStow管理である。

nix-darwin出力はない。Home ManagerのmacOS出力はcheck済みで、ライブ環境への適用も完了している。これはmacOSユーザー環境の移行であり、システム設定や他のStowパッケージを含む移行全体の完了を意味しない。

最初のFlakeでは、パッケージ数を絞る。

```text
common:
  zsh
  neovim
  ripgrep
  fd
  fzf
  jq
  bat
  zoxide

macOS only:
  HomebrewとGUIアプリ

WSL only:
  git
  Linux用の開発ツール
```

Git設定はWSL専用であり、共通モジュールやmacOS構成には含めない。

HomebrewのFormulaをすべてNixへ機械的に置き換えない。Formulaごとに、次のいずれかへ分類する。

- Nixで管理する
- macOSのHomebrewに残す
- WSLでは不要にする
- Nixで配布できるか確認してから判断する

### Phase 3: WSLで共通CLIを移行する（一部実装済み）

共通モジュールでは、次のCLIをWSL向けに宣言している。WSL側の記録では、Home Managerの評価、ビルド、適用まで確認済みである。この適用実績はWSLでの記録であり、ここでのmacOS環境からWSL上の実行時動作を再検証したものではない。

現在宣言しているパッケージ:

- `ripgrep`
- `fd`
- `fzf`
- `bat`
- `gh`
- `ghq`
- `jq`
- `lazygit`
- `neovim`
- `zoxide`

実行時の確認はWSL環境で別途行う。Python、Node、Rustのグローバルな実行環境は現在の共通モジュールでは宣言しておらず、今後必要性を確認して対象にする。プロジェクトごとの依存関係は各プロジェクトの`pyproject.toml`、`package.json`、`Cargo.toml`、ロックファイルを正本とし、Home Managerのグローバルパッケージに過剰に詰め込まない。

### Phase 4: 設定ファイルを1つずつ移行する（一部実装済み）

WSLではGit、Neovimに加え、BashとZshのユーザー設定もHome Managerへ移行した。その他の設定とmacOS側は未移行であり、引き続き対象ごとに切り替える。

未移行の設定は一度に全部切り替えず、次の順番を基本とする。

1. lazygit設定
2. zeno、nb、termrain
3. Zsh
4. Claude Code、Codex、Hermes
5. WezTerm

各項目で次の手順を繰り返す。

1. 対象が未移行であることを確認し、現在のStowパッケージと配置先を確認する
2. Nix側の配置先を定義する
3. `nix flake check`とビルドを実行する
4. 既存の配置先をバックアップする
5. Home Managerを適用する
6. 実体パスと内容を確認する
7. アプリやシェルで動作確認する
8. 問題がなければ、その項目だけStowの管理対象から外す

既存の正規ファイルを、確認なしにNixのリンクで上書きしない。Stowのリンク、通常ファイル、親ディレクトリのリンクを区別して確認する。

### Phase 5: Zshを共通部分とOS固有部分に分ける（WSLの基本設定を実装済み）

リポジトリのmacOS向け`.zshrc`にはmacOS固有のPATHと共通設定が混在している。WSLではそのファイルを流用せず、GoのPATHだけを持つ最小のZsh設定をHome Managerで生成している。共通化は今後、機能ごとにOS差を確認して進める。

```text
common:
  XDG_CONFIG_HOME
  ghq、peco、fzf、zoxideの設定
  共通aliasと関数
  zeno、sheldonの共通設定

macOS:
  Homebrewの初期化
  MacTeX
  Android Studio
  macOS専用のPATH

WSL:
  Linux用のPATH
  WSL固有の環境変数
  Linux側で必要な補完やサービス
```

Home Managerの`programs.zsh`を使う場合も、共通設定とOS固有設定を同じ文字列に埋め込まず、モジュールを分ける。シェルの起動時間とエラーをmacOS、WSLの両方で確認する。

### Phase 6: macOSへ同じFlakeを適用する（適用済み・確認継続）

既定の順序どおりWSLで共通部分を試した後、macOSへ同じFlakeを適用した。macOSではHome Managerの適用とHomebrewの適用を分けて扱う。現在はHome Managerの世代1が有効であり、Home Managerの対象CLIとNeovim設定はNixから解決される。Neovimの設定起動確認やHomebrew側の重複パッケージ整理などは引き続き残る。

```text
Home Manager:
  ユーザー設定、共通CLI、設定ファイル

Homebrew:
  GUIアプリ、Cask、Nixに載せないFormula

nix-darwin:
  必要になったmacOSシステム設定
```

macOSのHomebrew CaskをWSL用の設定へ持ち込まない。Homebrewの共通CLIパッケージはまだ削除していないため、Nixとの重複を整理する。`homebrew/Brewfile`は、最終的にmacOS専用のマニフェストとして残すか、nix-darwinのHomebrew設定へ移す。

### Phase 7: 残ったStowパッケージを整理する

すべての対象がHome Managerで安定した後に、不要になったStowパッケージを整理する。Stowからの削除は、対象が本当にHome Managerへ移ったことを確認してから行う。

残してよいStowパッケージの例:

- 頻繁に直接編集する設定
- Nix化するメリットが小さい設定
- Windows側へ配置する必要がある設定のソース
- アプリの形式に合わせてそのまま保持したい設定

## macOS、WSL、Windowsの境界

### WSL UbuntuはLinux側だけを管理する

Home ManagerをWSL内で適用しても、Windows本体の設定は変更されない。次のものは別の管理対象である。

- Windows Terminal
- Windows側のWezTerm
- Windows側にインストールしたGUIアプリ
- Windowsの環境変数
- Windows側のDocker Desktop
- WSLディストリビューションそのもの

### WezTermの扱いを先に決める

WezTermをWindows側で実行してWSLへ接続する場合、設定ファイルの所有者はWindows側になる。WSL内のHome ManagerだけでWindows側の設定を管理しようとしない。

候補は次のいずれかである。

- Windows側の設定ファイルを別の配置処理で管理する
- リポジトリにソースを置き、macOSとWindowsで別々に配置する
- WezTerm設定を共通部分とホスト固有部分に分ける

どれを採用するかは、実験用PCでWezTermをどのOSから起動しているかを確認してから決める。

### systemdはWSLで個別に確認する

WSL内でsystemdを使う場合、Ubuntu側のWSL設定、起動方法、ユーザーサービスの有無を確認する。macOSのLaunchAgentとLinuxのsystemd user serviceは同じものとして扱わない。

現在のCodex用LaunchAgentはmacOS専用であり、WSLへ移植しない。WSLで同じ定期処理が必要になった場合は、Linux側のサービスとして別に設計する。

## 検証方針

Nixの評価が成功しただけでは、アプリが実際に設定を読み込んだことを確認できない。次の検証を分けて行う。

### Flakeと設定の検証

```text
nix flake check
```

ホストごとにビルドを行い、macOS用とWSL用の両方が評価できることを確認する。実際の出力名はFlakeの定義に合わせる。

```text
home-manager build --flake .#<wsl-user>
home-manager build --flake .#<mac-user>
```

macOSでnix-darwinを導入した後は、切り替え前のビルドを先に実行する。

```text
darwin-rebuild build --flake .#<mac-host>
```

上記のホスト名は例であり、実装時に定義した出力名へ置き換える。

### 配置先の検証

各ファイルについて、次を確認する。

- 期待したパスに存在する
- Nix storeまたはリポジトリの意図したソースへ解決される
- StowとHome Managerが同じパスを所有していない
- 認証ファイルやランタイムデータを参照していない
- 設定ファイルの内容が移行前と意図どおり一致する

### アプリケーションの検証

- `zsh -n`でZsh設定の構文を確認する
- 新しい対話シェルを起動し、エラーがないことを確認する
- Neovimをヘッドレス起動し、設定とプラグインの読み込みエラーがないことを確認する
- lazygit、nb、termrainなどを実際に起動する
- Claude Code、Codex、Hermesは認証状態や履歴を変更せず、設定の読み込みだけを確認する
- WezTermは実際にGUIを起動するOS側で確認する
- WSLではWindows側のPATHが不要なコマンドを優先していないか確認する

### 既存Stow構成の検証

移行しないパッケージについては、引き続きGNU Stowのsimulationを実行する。macOSではNeovim設定がHome Managerの管理下に移ったため、`stow nvim`やNeovimパッケージのStow simulationを実行しない。

```text
stow --no-folding --simulate --verbose=1 <package>
```

移行したパッケージについては、Stowを再適用しない。移行後にStowを実行する必要がある場合は、対象パスの所有者を先に確認する。

### 最終確認

```text
git diff --check
git status --short
```

Nixが生成するロックファイルや設定差分を確認し、意図しないパッケージ更新、認証情報、キャッシュ、生成ファイルが含まれていないことを確認する。

## ロールバック

### WSLでのロールバック

Home Managerの世代を確認し、問題が起きる前の世代を再度有効化する。世代の確認と有効化に使うコマンドは、Home Managerの導入方法に合わせて確定する。

Nixの適用前には、次を記録する。

- 適用前のFlakeリビジョン
- Home Managerの現在の世代
- 移行対象のファイルの実体とリンク先
- 移行前に退避した設定ファイルの場所

### macOSでのロールバック

nix-darwinを導入した場合は、適用前の世代へ戻せることを確認する。Home Managerのユーザー設定とnix-darwinのシステム設定は別の世代として扱い、どちらを戻す必要があるかを切り分ける。

### Stowへの一時復帰

移行した設定に問題があり、Nixの復旧に時間がかかる場合は、次の順序で一時的にStowへ戻す。

1. Home Managerの対象設定を無効にする
2. Home Managerが配置したリンクやファイルを確認する
3. 退避した元ファイルを必要に応じて戻す
4. Stowのsimulationで計画を確認する
5. Stowを適用する
6. シェルやアプリの動作を確認する

NixとStowを同時に適用して解決しようとしない。

## 受入条件

移行したホストごとに、次を満たしたら対象を移行済みとする。

- [ ] 同じFlakeからmacOS用とWSL用の構成を評価できる
- [ ] 共通CLIが両方の環境で同じ宣言からインストールされる
- [ ] 共通設定が両方の環境で意図したパスに配置される
- [ ] macOS固有のPATHやLaunchAgentがWSLへ流れ込まない
- [ ] WSL固有の設定がmacOSへ流れ込まない
- [ ] Windows側の設定をWSLのHome Managerが誤って所有していない
- [ ] StowとHome Managerが同じパスを管理していない
- [ ] Neovim、Zsh、Git、lazygitなどの基本動作を確認できる
- [ ] Home Managerまたはnix-darwinの世代から前の状態へ戻せる
- [ ] Gitに認証情報、履歴、キャッシュ、生成ファイルが入っていない
- [ ] `nix flake check`、対象のビルド、アプリケーション確認が完了している
- [ ] `git diff --check`が成功し、意図しない変更が残っていない

## 未決事項

次の事項は、実機の状態を確認してから決める。

1. WSL内でsystemdを使用するか
2. 実験用PCでWezTermをWindowsとWSLのどちらから起動するか
3. macOSのシステム設定までnix-darwinで管理するか
4. HomebrewのFormulaをどこまでNixへ移すか
5. Neovimのプラグインをlazy.nvimのまま使うか、Nixでも管理するか
6. macOSとWSLで同じZsh設定をどこまで共有するか
7. NixOS-WSLへの移行を将来行うか
8. macOS/Stow用`git/.gitconfig`に残るGitのユーザー名・メールアドレス設定を、WSLの`~/.config/git/local`方式とどう整合させるか

これらが決まるまでは、移行対象の設定が検証済みになるまで既存のStow構成を削除しない。WSL UbuntuへのNix導入、共通CLI、Git、Neovimの設定配置と、macOSのHome Manager適用（共通CLI・Neovim）は実施済みである。残る作業はmacOS Neovim設定の起動確認、HomebrewとNixで重複する共通CLIの整理、他のパッケージの移行、および上記の未決事項の確認であり、移行全体は完了していない。
