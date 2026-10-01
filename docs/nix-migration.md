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

現在はGNU Stowでパッケージごとのファイルをホームディレクトリへ配置しているが、WSLの共通CLI・Git・Neovim・Bash・基本的なZsh設定と、macOSの共通CLI・Neovim設定・Zsh・lazygit設定に加え、zeno、nb、termrainの設定配置はHome Managerへ移行済みである。WSLのlazygit、zeno、nb、termrain設定は未移行である。Homebrewのパッケージ一覧は`homebrew/Brewfile`で管理している。

主なパッケージは次のとおり。

追跡対象の共通設定ソースを`.config/nvim/`、`.config/lazygit/config.yml`、`.config/zeno/config.yml`、`.config/termrain/config.example.toml`、`.nbrc`へ集約し、プラグイン一覧を`docs/nvim-plugins.md`へ配置した。対応する旧追跡ソース48ファイルは、新配置の存在を確認して削除した。設定内容とロックファイルは変更せず、引き続きStowで管理するパッケージも変更していない。

Hermesが設定のバイト一致、Lua 40ファイル・YAML・サンプルTOMLの構文、`zsh -n .nbrc`、`nix flake check --no-write-lock-file`、macOS activation packageのビルドを確認した。ユーザー承認済みのswitchによりmacOSの有効世代はgeneration 5となり、新配置へのライブリンクも確認済みである。生成されたソース参照の差分はNeovim、lazygit、zeno、termrainサンプル、`.nbrc`の5項目のみで、termrain実設定の参照は変更していない。切替後のヘッドレスNeovim起動も成功し、従来と同じ51個のプラグイン名と45個の画像フレームへのアクセスを確認した。WSLは`nvimConfigPath`の参照のみ更新し、今回の配置変更の適用・動作確認は行っていない。

ランタイムファイルとGit管理外のローカルファイルは従来パスを維持する。termrainの実設定は`termrain/.config/termrain/config.toml`のまま、内容を読み込まずNix storeにも取り込まない。Neovim画像も`nvim/.config/nvim/amadeus_frames`に残し、`.config/nvim/amadeus_frames`から`../../nvim/.config/nvim/amadeus_frames`へのGit管理外のローカルリンクで参照する。この画像リンクはHome Managerでは管理しない。

| パッケージ | 主な内容 | 移行候補 |
|---|---|---|
| `zsh/` | 旧Stow用`.zshrc`ソース | macOSは`modules/home/zsh/macos.zsh`、WSLはHome Managerで`~/go/bin`をPATHに追加する最小設定 |
| `.config/nvim/` | Neovimとlazy.nvimの設定 | `xdg.configFile`（macOS適用済み、WSLの新参照は未検証） |
| `wezterm/` | WezTerm設定 | 実際にGUIを実行するOS側で管理 |
| `git/` | `.gitconfig` | WSLのみHome Managerで管理。macOSでは対象外 |
| `.config/zeno/config.yml` | zeno.zsh設定 | `xdg.configFile` |
| `.nbrc` | nb設定 | `home.file` |
| `.config/claude/` | Claude Code非認証設定（旧`claude/`も保持） | macOSの`home.file`宣言のみ準備 |
| `.claude/` | プロジェクト用Claude Code skills | 今回の移行対象外 |
| `ghostty/` | Ghostty設定 | 実際にGUIを実行するOS側で管理 |
| `herdr/` | herdr設定 | 内容と利用環境を確認して判断 |
| `.config/opencode/` | OpenCode設定（旧`opencode/`も保持） | macOSの`xdg.configFile`宣言のみ準備 |
| `.config/lazygit/config.yml` | lazygit設定（`lazygit/`にランタイムと`.gitignore`を保持） | `xdg.configFile` |
| `.config/termrain/config.example.toml` | termrainサンプル（`termrain/`にローカル実設定を保持） | `xdg.configFile` |
| `.config/codex/` | Codex設定と`launchd/`のplist（旧`codex/`も保持） | macOSの`home.file`宣言のみ準備 |
| `.config/hermes/` | 共通SOUL、docs、skills（旧`hermes/`も保持） | macOSの`home.file`宣言のみ準備。ローカルYAMLは従来パス |
| `homebrew/` | Formula、Cask、Cargo、uv、npmなど | 共通CLIはNix、GUIとNixに載せにくいものはHomebrew |

## 現在の実装状況

`flake.nix`は`x86_64-linux`向けの`homeConfigurations."iori@wsl"`と、`aarch64-darwin`向けの`homeConfigurations."iori@macos"`を宣言する。共通モジュールは共通CLI（`bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`neovim`、`ripgrep`、`zoxide`）と、`dotfiles.nvimConfigPath`から`xdg.configFile."nvim"`へNeovim設定を配置する機能を提供する。Gitは独立モジュールで、WSLのみが従来どおり読み込む（`ghq.root = "~/src"`、既定ブランチ`main`、GitHub/Gistの認証helper、`~/.config/git/local` include）。WSLホスト設定はユーザー`iori`、ホームディレクトリ`/home/iori`、`stateVersion = "24.05"`を維持し、Neovim設定ソースを`/home/iori/clone/dotfiles/.config/nvim`へ更新した（今回の適用は未検証）。macOSホスト設定はユーザー`iori`、ホーム`/Users/iori`、同じstateVersion、Neovim設定ソース`/Users/iori/.dotfiles/.config/nvim`を指定し（generation 5で適用・参照確認済み）、Gitを管理しない。NeovimのVimTeXはmacOSでSkimを指定し、LinuxではVimTeXの既定設定に任せる。

Nixpkgsは`nixos-unstable`を指定し、具体的なリビジョンを`flake.lock`で固定している。WSL側では配置整理前のHome Managerの評価、ビルド、適用まで確認済みである。macOS arm64ではHome Managerの`iori@macos`へのswitchが成功し、generation 5が現在の世代、generation 4、3、2、1が利用可能である。`nix flake check --no-write-lock-file`とmacOS activation packageのビルドも成功するが、既存の`unknown flake output homeManagerModules`警告が出る。Home ManagerはユーザーNix設定で`nix-command`と`flakes`を有効化する。`home-manager`、`bat`、`fd`、`fzf`、`gh`、`ghq`、`jq`、`lazygit`、`nvim`、`rg`、`zoxide`は`~/.nix-profile/bin`から解決される。`~/.config/nvim`はHome Managerのリンクでリポジトリの`.config/nvim`を参照する。切替後もヘッドレス起動に成功し、従来と同じ51個のプラグイン名と45個の画像フレームへのアクセスを確認した。以前の初期起動では23個のプラグインがロードされた。VimTeXの`view_method`は`skim`である。遅延ロードされる個別プラグインの機能は未確認。以前のStowリンクは`~/.config/nvim.stow-backup`に保存されている。

macOSの`~/.config/lazygit`は実ディレクトリで、Home Managerは`xdg.configFile."lazygit/config.yml"`だけを、リポジトリの`.config/lazygit/config.yml`へのout-of-store symlinkとして管理する。Stow時代のディレクトリリンクは`~/.config/lazygit.stow-backup`に保存されている。`state.yml`と`github_pull_requests.json`はHome Manager管理外で、ライブディレクトリ内の個別リンクが元のリポジトリパスを参照している。ネイティブの`lazygit --print-config-dir`は`~/.config/lazygit`を示す。Nix版lazygit v0.65.1は実際の設定を使った一時リポジトリ上で起動し、日本語UIの表示後に`q`で終了した。設定のパーサーと実行時読み込みは確認済みだが、元のstateファイルには触れていない。

macOSではzenoの`config.yml`、`~/.nbrc`、termrainの`config.example.toml`と`config.toml`もHome Managerが個別のout-of-store symlinkとして配置する。zeno、termrainの設定ディレクトリは実ディレクトリ、`.nbrc`はHome Manager管理のリンクであり、追跡対象の3つは新配置のソース、termrainの実設定は従来の`termrain/.config/termrain/config.toml`を参照する。以前のStowリンクは`~/.config/zeno.stow-backup`、`~/.nbrc.stow-backup`、`~/.config/termrain.stow-backup`に保持している。termrainの実設定はGit管理外のローカルファイルで、内容を確認せずNix storeにも取り込んでいない（リンク先パスのみを指定）。nbのノートやデータには触れていない。追跡対象のzeno YAMLとtermrainサンプルTOMLの構文、および`.nbrc`のzsh構文は確認済み。隔離した環境で`.nbrc`の読み込みを`EDITOR=nvim`および`NB_DIR`設定下で確認したが、nbのノート操作は未確認である。zenoのネイティブ動作、termrain実設定の構文やネットワーク・天気機能も未検証である。

Git設定とGit identityはmacOS Home Managerの対象外で、Stow管理を継続する。Homebrewの共通CLIパッケージは削除しておらず、現在はNixと重複している。

### AI設定のPhase A（準備のみ・未適用）

追跡済みの旧ソース14ファイルは残したまま、準備コピー14ファイルを`.config/claude/`、`.config/codex/`、`.config/hermes/`、`.config/opencode/`へ配置した。Codexのplistは`.config/codex/launchd/`に置いた。コピーは修正済みSOULのCodex指示書参照を除き、現在の旧ソースと一致する。Codexの作業ファイルは旧・新の両方に既存のローカル変更を保持している。新パスは旧パスのHEADをベースとしてステージし、ローカル変更はコミットに含めない。コピー先のHermes `SOUL.md`では参照を`~/.dotfiles/.config/codex/AGENTS.md`へ修正した。元のSOULと旧ソースの配置は保持し、ソースは削除していない。

`hosts/macos.nix`には14個の配置先へのパスのみの`mkOutOfStoreSymlink`宣言がある。アプリの参照先は`~/.claude`、`~/.codex`、`~/.hermes`、`~/.config/opencode`、`~/Library/LaunchAgents`のままで、ディレクトリ全体は管理しない。Hermesの`hermes/.hermes/config.yaml`はGit管理対象として従来パスに保持し、`~/.hermes/config.yaml`には絶対パスだけの`home.file`リンクを宣言した。このYAMLはローカルでHermesのネイティブ設定CLIから更新したもので、`mkOutOfStoreSymlink`は実行時にリポジトリの実ファイルを参照する。一方、Git管理されたYAMLはGit-backed FlakeのソーススナップショットとしてNix storeにも含まれる。値は引き続きNixで宣言・生成しない。Hermesの既定モデルは`model.default=gpt-6.1-sol`、`model.provider=openai-codex`、委譲モデルは`delegation.model=gpt-6-luna`、`delegation.provider=openai-codex`。OpenCodeは`openai/gpt-6-luna`を既定モデルとして有効なソースと準備コピーの両方に設定しており、CLIの`--model`指定が優先される。plistは`home.file`リンクのみで、サービス定義・スクリプト・ランタイム保存先は変更しない。認証情報、履歴、ログ、ランタイムデータ、他のプロファイルとプロジェクトの`.claude/skills`は対象外である。

AI所有権の切り替えは一時停止中である。現在もgeneration 5が有効で、AIのライブリンクはStowのまま、旧ソース14ファイルも保持している。切り替え、削除、再起動、macOSの`home-manager switch`は行っていない。再開時は、元ソースとライブリンクの隣に退避するリンクを確保し、承認済みの末端リンクだけを明示的に解除する。事前確認の`stow --no-folding --simulate --verbose=2 --delete claude codex hermes opencode`は、ignore指定があっても無関係な`.nbrc.stow-backup`のUNLINKを計画するため、実際のStow削除は実行しない。切り替え後はAIの対象パスをStowで再適用しない。

WSLのAI設定は未移行であり、WSLのhosts/modulesには今回の宣言を追加していない。将来旧追跡ソースを削除する前に、WSLや他のStow利用者の移行・復元手順を確認する。それらの利用者は稼働中のStow構成を更新する前に新配置へ移行するか、従来のソースを復元する必要がある。

### 2026-09-30 WSLシェル設定の適用

WSL Ubuntu 24.04.4（x86_64）で`nix flake check path:.`、`home-manager build --flake path:.#iori@wsl`、`home-manager switch --flake path:.#iori@wsl`を実行し、成功を確認した。Nix/Home Managerは既に導入済みだったため再インストールしていない。既知の`unknown flake output 'homeManagerModules'`警告は出るが、Flake checkは成功する。

- Bash: `programs.bash`で`~/.bashrc`、alias、補完、Linuxbrew・Cargo・fzf・CUDA・WezTerm OSC 7の初期化を管理する。Ubuntuの`/etc/bash.bashrc`経由の標準設定も維持する。
- Zsh: `programs.zsh`で`~/.zshrc`を管理し、NixからZshを導入する。`~/go/bin`をPATHへ追加する。既定ログインシェルは引き続きBashであり、変更していない。
- `~/.profile`はNix installerの初期化を含む既存ファイルのためHome Managerから除外した。Home Manager生成の`.bash_profile`も無効にし、既存`.profile`から`.bashrc`を一度だけ読み込む。
- 適用前の`.bashrc`、`.bash_aliases`、`.zshrc`を`/home/iori/.local/state/dotfiles-backups/20260930T115523/`へ退避した。`.bash_aliases`のaliasはNix設定へ移した。
- `bash -n`、`zsh -n`、Bash login-shellのalias/function確認、Zsh login-shellのGo PATH確認を実施した。

Windows側のPATHがWSLへ混在する状態は別途残っており、PATHの優先順位と不要なWindowsエントリは今後確認する。WSLのlazygit、zeno、nb、termrainおよび`~/.profile`自体はHome Manager未管理である。

Stow設定とHome Manager設定は、`ghq.root`、既定ブランチ、GitHub/Gist向け認証helperの動作を共有している。StowはHomebrewの絶対パスで`gh`を呼び出し、Home ManagerはPATHから`gh`を解決するため、Home Manager設定ではHomebrew固有のパスを避けられる一方、PATH上に`gh`が必要となる。

## 未完了の作業

以下は現在の実装状況に基づく次の作業である。「適用済み」はHome Managerの適用記録を指し、アプリケーションの完全な動作確認まで済んだことを意味しない。

### 検証が残っている項目

| 状態 | 次の作業 | 確認方法 |
|---|---|---|
| macOSのNeovim初期起動確認済み・一部未検証 | Neovimの遅延ロードプラグインの個別機能 | ヘッドレス起動で初期設定の読み込みに成功し、設定済みプラグインディレクトリ51個のうち23個が起動時にロードされることを確認済み。遅延ロードされる各プラグインの機能は未確認のため、個別に実機で確認する。プラグイン管理は引き続きlazy.nvimである |
| WSL CLI・Git・Neovim・Bash・Zsh適用済み | Windows側PATHの整理と未移行アプリ設定 | シェル起動・構文・alias/function・Go PATHは確認済み。WSLで`command -v`と基本動作を追加確認し、Windows側PATHがLinuxコマンドを意図せず優先しないことを確認する |
| macOSは世代1〜5が利用可能・復帰未検証、WSLは要確認 | 両ホストでのロールバック手順 | 現在世代、適用前のFlakeリビジョン、対象ファイルのリンク先と退避先を記録し、世代の確認・復帰方法を導入方式ごとに確認する。generation 1〜5が利用可能であることは確認済みだが、実際の復帰は試していない。配置整理前の世代への復帰には、旧ソース配置の復元も必要である |

### 次に移行する設定・整理

| 状態 | 対象と次の作業 |
|---|---|
| macOS移行済み・WSL未移行 | macOSではlazygitの`config.yml`をHome Managerで配置し、Nix版アプリで設定読み込みと日本語UIを確認済み。zeno、nb、termrainもHome Manager配置済み。zenoのネイティブ動作、nbのノート操作、termrain実設定の構文・ネットワーク機能は未検証。WSL側はmacOSの前提ではなく、配置先とStow所有状態を確認して別途移行する |
| macOS適用済み・対話シェル未確認、WSL基本Zsh設定適用済み | Home Manager generation 5が現在の世代。`~/.zshrc`はmacOSで`modules/home/zsh/macos.zsh`へのHome Managerリンク。WSLはNix Home Managerが最小の`.zshrc`を生成し、`~/go/bin`をPATHへ追加する。macOS側は新エントリポイントの構文・112個の実行文順序・Nix check/build・Stow unlink simulationを確認済みだが、通常起動とKeychainを含む設定sourceは未確認。WSL側は`zsh -n`とlogin-shellでGo PATHを確認済み |
| macOS Phase A準備済み・切り替え未実施、WSL未移行 | Claude Code、Codex、Hermes、OpenCodeの14ファイルを新配置へコピーし、macOSの個別リンク宣言を準備した。Hermesの検証とユーザー承認後に対象リンクだけを解放・適用・確認する。旧ソースはそれまで保持する |
| 未移行・ホスト所有 | WezTermなどのGUI設定は実際にGUIを動かすOSを特定し、そのOS側の配置方法を決めて確認する |
| 重複あり | HomebrewとNixの共通CLIをFormulaごとに分類し、Nixへ寄せるものとHomebrewに残すものを決めてから重複を整理する |

### 対象ごとに判断する事項

- WSLでsystemdを使うか、WezTermをWindowsとWSLのどちらで実行するかを実機で確認する。WezTermの移行前に実行ホストと設定の所有境界を決める。
- macOSのシステム設定をnix-darwinで管理する範囲と、将来NixOS-WSLへ移行するかを必要性に応じて判断する。現状nix-darwin出力はない。
- Homebrew FormulaをNix、Homebrew、WSLでは不要、要調査に分類する。
- Neovimプラグインは現在lazy.nvimが管理している。Nix管理へ変更するかは未決であり、変更する場合も別途評価する。
- macOSのGit設定は引き続きStow所有とし、Home Managerの対象外とする。Git identity設定をWSLの`~/.config/git/local`方式とどう整合させるかは未決である。

## WSL側での更新

この実装状況は、既定の移行方針（WSL Ubuntuから試し、macOSを先に切り替えない）を変更しない。Nix/Home Managerの導入とFlake機能の有効化が済んだWSL環境で、現在の構成を更新するときはリポジトリのルートで次を実行する。

```sh
nix flake check path:.
home-manager switch --flake path:.#iori@wsl
```

この配置変更をpullした後は、上記の手順でHome Managerを再適用してNeovimの参照先を`.config/nvim`へ切り替える。WSLのNixソース参照は更新済みだが、今回の配置変更の適用・動作確認は行っていない。ローカルのNeovim画像は管理対象外であり、そのホストでも必要に応じて旧画像パスへのリンクを用意する。

Git、Neovim、Bash、ZshはHome Managerへ移行済みなので、WSLでは対応するStowパッケージを再適用しない。WSLのlazygit、zeno、nb、termrain設定は未移行である。設定ファイルを追加で移す際も、受入条件に従って対象ごとにStowとの所有を切り替え、同一パスを両方で管理しない。WSLを最初の試験対象とした後、macOSにもHome Managerを適用済みである。macOSではZsh、Neovim、lazygit、zeno、nb、termrainのStowパッケージを再適用しない。

旧`.zshrc`には、次のようなmacOS固有の記述がある。これをそのまま共通設定としてWSLへ配置してはいけない。macOS用Zshは`modules/home/zsh/`に分割してHome Managerへ適用済み。WSL用にはmacOS設定を流用せず、`~/go/bin`を追加する最小設定をHome Managerで管理している。

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

`flake.nix`は共通モジュールと、`x86_64-linux`向けの`homeConfigurations."iori@wsl"`、`aarch64-darwin`向けの`homeConfigurations."iori@macos"`を公開する。macOS構成は共通CLI、Neovim設定、Zsh、lazygit、zeno、nb、termrainの設定配置を対象にし、Git設定・identityは対象外とする。macOS arm64で`nix flake check --no-write-lock-file`とmacOS activation packageのビルドが成功し、既存の`unknown flake output homeManagerModules`警告が出ることを確認した。配置整理後のHome Managerのswitchはgeneration 5として成功し、generation 4、3、2、1が利用可能である。Neovim設定はヘッドレス起動で読み込みを確認済みだが、遅延ロードされる個別プラグインの機能は未確認。設定済みプラグインディレクトリは51個、以前の初期起動時ロードは23個で、VimTeXの`view_method`は`skim`である。移行した各設定のStow時代のリンクは`.stow-backup`として保持している。Git設定はStow所有を継続し、その他のmacOSライブ設定も引き続きStow管理とする。

nix-darwin出力はない。Home ManagerのmacOS出力はcheck・activation package build済みで、ライブ環境への適用も完了している。generation 1は利用可能だが、ロールバック自体は検証していない。これはmacOSユーザー環境の移行であり、システム設定や他のStowパッケージを含む移行全体の完了を意味しない。

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

WSLではGit、Neovimに加えBashと基本的なZsh設定もHome Managerへ移行済みである。macOSでは共通CLI、Neovim設定、Zsh、lazygitの`config.yml`に加え、zenoの`config.yml`、nbの`.nbrc`、termrainの追跡対象`config.example.toml`と既存のGit管理外`config.toml`へのリンクをHome Managerで管理している。これら以外の設定は未移行であり、引き続き対象ごとに切り替える。

macOS側の移行はWSL側の残作業を待たずに進める。未移行の設定は一度に全部切り替えず、次の順番を基本とする。

1. Claude Code、Codex、Hermesの非認証設定
2. GUI設定の実行ホストと所有境界の確認（WezTermなど）

WSLのlazygit、zeno、nb、termrain設定は、配置先とStow所有状態を確認したうえで行う別個の後続確認とし、macOS側の移行を止める条件にしない。

各項目で次の手順を繰り返す。

1. 対象が未移行であることを確認し、現在のStowパッケージと配置先を確認する
2. 配置先の所有者、通常ファイル・リンクの別、アプリのランタイムファイルを確認する
3. 既存設定とロールバック用のStowリンクを保持できることを確認し、バックアップ先を記録する
4. Nix側の配置先を定義し、`nix flake check`とビルドを実行する
5. Stowのsimulationで競合を確認する。simulationだけでHome Managerが配置を引き継ぐとは判断しない。macOSのlazygitでは、`stow --no-folding --simulate --verbose=1 --delete lazygit`は`.config/lazygit`の解除を報告した。別途、Stowの親ディレクトリリンクが残った状態でHome Managerのdry-runを実行すると、`config.yml`は同じファイルへのリンクとして既存扱いになりskipされた。親リンクを解除した後のHome Manager dry-runでは、`config.yml`の配置が計画された
6. StowとHome Managerの二重所有を避けるため、切替対象の古いライブStowリンクだけを、ロールバック用リンクを別の場所に保持したうえで、ユーザーの承認を得て解除する。無関係なstateやランタイムファイルは維持する
7. Home Managerを適用し、実体パスと内容、アプリやシェルの動作を確認する
8. 問題がなければロールバック用バックアップを保持する

既存の正規ファイルを、確認なしにNixのリンクで上書きしない。解除は確認と承認の後に切替対象のライブリンクだけに行い、退避物を削除しない。Stowのリンク、通常ファイル、親ディレクトリのリンクを区別して確認する。

### Phase 5: Zshを共通部分とOS固有部分に分ける（macOS適用済み、WSL基本設定適用済み）

macOS用エントリポイントは`common-early`、`macos-environment`、`common-late`、`macos-tools`を順に読み込み、Home Managerの宣言的なsourceには`mkOutOfStoreSymlink`を使う。generation 4へのswitch、Flake check、activation package build、Stow unlink simulationを確認した。Stowの`~/.zshrc`が残る切替前のHome Manager dry-runは想定どおりblockedとなり、Stowリンクを退避して解放した後のdry-runとswitchは成功した。各ファイルとシンボリックリンクのZsh構文、および旧設定と新設定の112個の実行文の順序を確認済み。通常・対話シェル起動と`macos.zsh`のsourceは行っていない。既存の起動処理は`~/.local/bin/env`とKeychainを読むため、通常起動は未検証であり、秘密情報は読み取っていない。

旧Stowソースの`.zshrc`にはmacOS固有のPATHと共通設定が混在していた。macOSの有効なHome Managerエントリポイントは`modules/home/zsh/macos.zsh`で、設定を次のように分割している。WSLでは現時点でGoのPATHのみを設定し、共通設定への切り出しは今後進める。

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

当初の移行では既定の順序どおりWSLで共通部分を試した後、macOSへ同じFlakeを適用した。今後のmacOS側の移行はWSLの残作業を待たずに進める。macOSではHome Managerの適用とHomebrewの適用を分けて扱う。Home Managerの対象CLIとNeovim設定はNixから解決され、Neovimの初期設定読み込みはヘッドレス起動で確認済みである。遅延ロードされる個別プラグインの機能確認とHomebrew側の重複パッケージ整理は引き続き残る。

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

移行しないパッケージについては、引き続きGNU Stowのsimulationを実行する。macOSではZsh、Neovim、lazygit、zeno、nb、termrainがHome Managerの管理下に移ったため、これらの`stow`適用やStow simulationを実行しない。WSL側は未移行のため、同環境でStow適用状態を別途確認する。

```text
stow --no-folding --simulate --verbose=1 <package>
```

移行したパッケージについては、Stowを再適用しない。macOSではZsh、Neovim、lazygit、zeno、nb、termrainが該当する。移行後にStowを実行する必要がある場合は、対象パスの所有者を先に確認する。

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

現在はHome Manager generation 5が有効で、generation 4、3、2、1が利用可能である。Zshを含む移行済み設定のStowリンクは`.stow-backup`として保存されている。旧世代へのロールバックやStowへの復帰は実施しておらず、実際の復帰手順は未検証である。

AI所有権の切り替えは未実施で、旧ソースとStowのライブリンクを保持している。後続の切り替えから戻すには、元ソースとライブリンクと同じ親ディレクトリに退避した旧リンクの両方を保持する必要がある。generation 1〜5はAIリンクを管理していなかったため、旧世代へ戻すだけではAIリンクは復元できない。AIのHome Manager所有を解除したうえで、保持した元ソースと旧リンクを復元する。

配置整理前のHome Manager世代と保存済みStowリンクは、削除済みの旧ソースパスを参照する。世代やリンクを戻す前に、変更前のGitリビジョンまたは保持したローカルバックアップから対象の旧ソース配置を復元する必要がある。out-of-store symlinkのため、世代切替だけでは旧ソースは復元されない。この注意点は、配置整理前のWSL世代へ戻す場合にも当てはまる。画像・ランタイムファイル・ローカル実設定は復元作業でも上書きしない。

### Stowへの一時復帰

移行した設定に問題があり、Nixの復旧に時間がかかる場合は、旧ソース配置を上記の方法で復元してから、次の順序で一時的にStowへ戻す。

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
2. 実験用PCでWezTermをWindowsとWSLのどちらから起動するか（設定の所有境界を決める）
3. macOSのシステム設定までnix-darwinで管理するか
4. HomebrewのFormulaをどこまでNixへ移すか
5. 現在lazy.nvimが管理するNeovimプラグインを、引き続きlazy.nvimに任せるかNix管理へ変更するか
6. macOSとWSLで同じZsh設定をどこまで共有するか
7. NixOS-WSLへの移行を将来行うか
8. macOSのGit設定はStow所有、Home Manager対象外とする。Git identity設定をWSLの`~/.config/git/local`方式とどう整合させるか

未決事項の判断を移行の一律の前提条件にはしない。対象ごとに検証が済むまでは対応するStow構成を残す。WSL UbuntuへのNix導入、共通CLI、Git、Neovimの設定配置と、macOSのHome Manager適用（共通CLI・Neovim・Zsh・lazygit・zeno・nb・termrain設定）は実施済みである。macOSのZshはHome Managerで適用済みだが、WSLのZshは未移行である。通常の対話シェル起動は未検証で、既存起動処理が読む`~/.local/bin/env`とKeychainを含む動作確認は残っている。macOSのNeovimは設定読み込みをヘッドレス起動で確認したが、遅延ロードされる個別プラグインの機能は未確認である。zenoのネイティブ動作、nbのノート操作、termrain実設定の構文・ネットワーク機能は未検証である。ロールバック証跡、HomebrewとNixで重複する共通CLIの整理、その他の設定移行も残っており、移行全体は完了していない。
