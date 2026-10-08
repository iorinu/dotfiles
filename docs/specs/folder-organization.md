# フォルダー構成の整理案

> **計画のみ。** この文書は分類と将来案を記録するもので、移動・削除・リンク変更・設定適用の承認ではない。

## 目的と前提

現行の共有設定、Home Manager宣言、旧Stowソース、実際に使うGit設定、ローカルデータ、文書を区別する。旧StowソースはWSLや他の利用者が使っている可能性があり、未使用とは確認できていない。Git管理状況だけでは利用実態を証明できない。

## 分類と方針

| 分類 | 現在のパス | 方針 |
|---|---|---|
| 共有設定 | `.config/`, `.nbrc` | 現行の共有設定として維持。移行済みの配置先はHome Managerが所有する。 |
| Home Manager宣言 | `hosts/`, `modules/home/`, `flake.nix`, `flake.lock` | macOS・WSLの宣言として維持。`homebrew/Brewfile`も現行管理として維持する。 |
| 実際のStow Git設定 | `git/.gitconfig` | `~/.gitconfig`からの相対リンク先。現行利用中のため維持し、旧ソース候補に含めない。 |
| 文書 | `docs/nix-migration.md`, `docs/nvim-plugins.md` | 既存記録を維持。本案は`docs/specs/`に置く。 |
| 旧Stowソース候補 | 下記一覧 | 移動候補にすぎない。利用者・参照元・秘密情報の確認と別途承認の後に扱う。 |
| ローカル／実行時データ | 下記保護対象 | 配置整理の対象外として維持する。 |

`.claude/skills`はプロジェクトスキルであり、旧Stowソースの`claude/.claude`とは別物。移動しない。

Neovimプラグイン管理はlazy.nvimを継続し、macOSシステム設定とnix-darwin導入は対象外。追加の普段環境検証と実切り戻しは計画の完了条件としない（未検証の制限は保持）。

## 旧Stowソース候補と仮の移動先

候補はすべてGit追跡対象のみで、調査時点では無視・未追跡ファイルはなかった。ただし、これは他環境での未使用を示さない。

| 現在のパス | 仮の移動先 |
|---|---|
| `claude/.claude/{CLAUDE.md,runcat-statusline.py,settings.json}` | `legacy/stow/claude/` |
| `codex/.codex/{AGENTS.md,config.toml,runcat-usage.py}`、`codex/Library/LaunchAgents/com.iori.codex-runcat-usage.plist` | `legacy/stow/codex/` |
| `ghostty/.config/ghostty/config` | `legacy/stow/ghostty/` |
| `herdr/.config/herdr/config.toml` | `legacy/stow/herdr/` |
| `opencode/.config/opencode/opencode.jsonc` | `legacy/stow/opencode/` |
| `wezterm/.config/wezterm/{wezterm.lua,keybinds.lua}` | `legacy/stow/wezterm/` |
| `zsh/.zshrc` | `legacy/stow/zsh/` |

`legacy/stow/`は提案上の配置先であり、現時点では存在しない。移動前に秘密情報の有無を値を表示・記録せず確認し、スクリプトや設定からの参照を調査する。旧ソースは復旧や他環境での利用のため保持し、削除しない。

## 保護対象と参照関係

- 両ホストはHome Manager管理のライブリンク`~/.hermes/config.yaml`を宣言し、そのアウト・オブ・ストアのソースは`hermes/.hermes/config.yaml`。ライブリンクはHome Manager管理下にあり、旧パスのソースは維持する。YAMLの内容は読まない。その他の追跡済みHermesソース6件も、当面`hermes/`全体を維持する。
- `nvim/`にはGit無視の画像フレーム45件がある。`.config/nvim/amadeus_frames`は`../../nvim/.config/nvim/amadeus_frames`を指すローカル相対リンクで、参照先も含めて維持する。
- `lazygit/`は追跡済み`.config/lazygit/.gitignore`と無視対象の実行時ファイル2件を含む。維持する。
- `termrain/`にはmacOSで使う無視対象の`config.toml`がある。維持する。
- `nb/`と`zeno/`はGitメタデータ上、追跡・無視・未追跡ファイルがないが、ディレクトリやリンクの不存在・削除可能性までは確認していない。維持する。
- `default.tar.gz`は無視対象で内容不明。開かず、移動・削除しない。
- `.config/codex/config.toml`には今回と無関係なステージ済み・未ステージ変更がある。触れない。
- `README.md`と`docs/nix-migration.md`には既存の未コミットの判断がある。変更しない。

## 提案する見取り図

```text
（現行） .config/  .nbrc  hosts/  modules/  homebrew/  git/
         flake.nix  flake.lock  docs/
（提案） legacy/stow/{claude,codex,ghostty,herdr,opencode,wezterm,zsh}/
（保護） hermes/  nvim/  lazygit/  termrain/  nb/  zeno/
（維持） claude/ codex/ ghostty/ herdr/ opencode/ wezterm/ zsh/ は
         方針決定と承認までは現位置。git/も現位置。
```

ツリーの`legacy/stow/`だけが仮の新設案。保護対象と現行パスは移動案ではない。

## 未決定：旧パスの互換性

実行時には、次のどちらかを別途選び、影響先を確認する必要がある。

**A. 旧ルート名をリンクとして残す** — 既存参照やバックアップの参照先を保ちやすい。一方、旧名はルートに残るため、ルート項目の整理効果は限定される。

**B. 旧ルート名を残さない** — 参照元とライブ／バックアップリンクの更新、および復旧用の対応表が必要。Home Manager管理対象への変更には、別途適用承認が必要。

どちらも未承認であり、本案では選択しない。確認済みのバックアップ参照は、`.config/wezterm.stow-backup-nix-20261001T154203` → `../.dotfiles/wezterm/.config/wezterm`、`.zshrc.stow-backup` → `.dotfiles/zsh/.zshrc`、`.config/nvim.stow-backup` → `../.dotfiles/nvim/.config/nvim`。これらを暗黙に変更しない。

現行世代は7、前世代6も保持されている。アウト・オブ・ストアのリンクがあるため、ソースのパス移動は過去世代からの参照を壊しうる。世代ロールバックだけでは移動したソースパスは復元されない。

## 承認後に検討する手順

1. 現状メタデータと厳密な対象許可リストを記録し、既存Git indexと無関係な変更を保護する。
2. 候補ごとに他環境の利用、参照元、秘密情報の不存在を確認する。秘密の値は表示・記録しない。
3. A/Bを決め、変更する参照、移動元・先、逆操作の方法を明記する。
4. 移動、リンク変更、ライブソース変更には個別の承認を得る。承認後の移動作業はOpenCodeで行い、Hermesにレビューを依頼する。
5. READMEや参照文書の更新は承認された場合のみ行う。参照変更があれば、必要最小限の非適用Flake check／`--no-link --no-write-lock-file`ビルドとリンクメタデータ確認を行う。移行済みパッケージにStowを再適用しない。

通常のStow再適用、Home Managerの適用、システム管理、Neovimプラグイン管理の変更はこの整理案に含めない。コミット・pushも自動では行わない。

## この計画の受け入れ条件

- 現行設定、Home Manager宣言、実Stow設定、旧候補、ローカルデータ、文書の分類が明確。
- 影響する参照と保護対象が明記され、未決定の移行方針が勝手に確定されていない。
- この計画段階では何も移動せず、保護データに触れていない。
