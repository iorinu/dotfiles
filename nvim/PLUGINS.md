# Neovim プラグイン一覧

このファイルは、現在の Neovim 設定で使用しているプラグインと、その役割をまとめたものです。

プラグインの定義は `nvim/.config/nvim/lua/plugins/` 以下にカテゴリ別で配置されています。`lua/config/lazy.lua` の `import` によって読み込まれ、バージョンは `nvim/.config/nvim/lazy-lock.json` で固定されています。

## 読み込みと状態

| 状態 | 意味 |
|---|---|
| 有効 | 通常どおり読み込まれるプラグイン |
| 条件付き | ファイルタイプ、コマンド、イベントなどをきっかけに読み込まれるプラグイン |
| 無効 | 設定ファイルには残っているが、現在は使用しないプラグイン |

現在 `lazy-lock.json` に記録されているプラグインは53個です。依存プラグインも含みます。

## フォルダ構成

`lua/plugins/` は、プラグインの見た目ではなく主な役割で分類しています。

| フォルダ | 主な内容 |
|---|---|
| `ai/` | Copilot と Copilot Chat |
| `appearance/` | テーマ、ステータスライン、通知、視覚効果、起動画面 |
| `completion/` | nvim-cmp、LuaSnip、補完ソース |
| `editor/` | 自動括弧、入力方式、句読点変換 |
| `git/` | Git の変更表示、差分、履歴 |
| `language/` | Tree-sitter、フォーマッター、Markdown、Jupyter、LaTeX |
| `lsp/` | LSP、Mason、診断一覧 |
| `navigation/` | Telescope、NvimTree、Bufferline、ファジー移動 |
| `terminal/` | Neovim 内蔵ターミナル |
| `legacy/` | 現在読み込まない旧設定の退避先 |

1つの設定ファイルに複数の関連プラグインをまとめる場合があります。例えば `ai/copilot.lua` は Copilot 本体と Copilot Chat、`language/molten.lua` は Molten と Jupytext を定義しています。

## プラグイン管理

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [folke/lazy.nvim](https://github.com/folke/lazy.nvim) | プラグインマネージャー。プラグインのインストール、更新、遅延読み込みを管理する | 起動時に自動セットアップ。`lua/plugins/` 以下をカテゴリ別に読み込む |

## AI・補完支援

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua) | GitHub Copilot のインラインコード補完 | `InsertEnter` で読み込み。候補を自動表示し、`Tab` で受け入れる。`:Copilot` コマンドにも対応 |
| [CopilotC-Nvim/CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) | Copilot を使ったチャット画面 | `Ctrl-c` で開閉。浮動ウィンドウ表示、幅は画面の50%。回答言語は日本語に指定。`make tiktoken` を実行してビルド |

## Git

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git の変更箇所を行番号欄に表示する。追加、変更、削除、ステージ状態などを確認できる | デフォルト設定を使用 |
| [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) | Git の差分やファイルの変更履歴を見やすく表示する | `<Space>gh` で現在ファイルの履歴、`<Space>gc` で Diffview を閉じる |
| [isakbm/gitgraph.nvim](https://github.com/isakbm/gitgraph.nvim) | ブランチを含む Git のコミット履歴をグラフ表示する | `<Space>gl` で最大5000件の全履歴を表示。コミット選択時は Diffview で差分を開く |
| [kdheepak/lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) | Neovim から LazyGit を開く | `<Space>gg` で起動 |

## ファイル検索・移動

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | ファイル、文字列、バッファ、ヘルプなどを検索する | `<Space>ff` ファイル検索、`<Space>fg` 文字列検索、`<Space>fb` バッファ検索、`<Space>fh` ヘルプ検索。バージョンは `0.1.8` に固定 |
| [yuki-yano/fuzzy-motion.vim](https://github.com/yuki-yano/fuzzy-motion.vim) | 画面内の単語をインクリメンタルなファジー検索で選び、カーソルを移動する | Normal modeで`Enter`を押すと起動。小文字で検索文字列を入力し、大文字のラベルまたは`Enter`で移動 |
| [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Neovim プラグイン向けの共通ユーティリティライブラリ | Telescope、LazyGit、CopilotChat などの依存プラグイン |
| [vim-denops/denops.vim](https://github.com/vim-denops/denops.vim) | Vim/Neovim上でDeno製プラグインを動かすための基盤 | fuzzy-motion.vimの依存プラグイン |

## LSP・コード補完

### LSP 基盤

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Language Server Protocol の設定を簡単にする | Lua、Python、TypeScript、HTML、CSS、Bash、LaTeX、YAML、TOML、Astro、Tailwind CSS、JSON、MDX、Markdown、Go などを設定。Rust は `rustup` の nightly 版を使用 |
| [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) | LSP、フォーマッターなどの外部ツールをインストール・管理する | LSP 設定時にセットアップ |
| [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Mason と nvim-lspconfig を連携する | 指定した LSP サーバーを自動インストール。Rust、MDX、Marksman は個別設定を使用 |
| [folke/lazydev.nvim](https://github.com/folke/lazydev.nvim) | Neovim の Lua API（`vim.*`）の型情報と補完を提供する | Lua ファイルを開いたときだけ読み込む。Neovim 設定の Lua ファイルを編集するときに使用 |

### 補完エンジンと補完ソース

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | 入力中のコード補完を表示・確定する本体 | `InsertEnter` で読み込み。`Ctrl-k`/`Ctrl-j` で候補移動、`Ctrl-Space` で手動表示、`Enter` で確定。補完ウィンドウは枠付き |
| [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | LSP が返す補完候補を nvim-cmp に渡す | LSP の capabilities にも使用 |
| [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer) | 現在開いているバッファ内の単語を補完候補にする | nvim-cmp の補完ソース |
| [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path) | ファイルパスを補完候補にする | nvim-cmp の補完ソース |
| [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) | LuaSnip のスニペット候補を nvim-cmp に渡す | nvim-cmp と LuaSnip の連携用 |
| [onsails/lspkind.nvim](https://github.com/onsails/lspkind.nvim) | 補完候補の種類をアイコンで表示する | nvim-cmp の候補表示に使用 |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) | スニペットを展開し、プレースホルダー間を移動する | `Ctrl-k` で展開・次の位置へ、`Ctrl-j` で前の位置へ移動 |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | VS Code 形式の汎用スニペット集 | LuaSnip から遅延読み込み |

## 診断・コード構造

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [folke/trouble.nvim](https://github.com/folke/trouble.nvim) | LSP の診断、参照、クイックフィックスなどを一覧表示する | `<Space>xx` で全体の診断、`<Space>xX` で現在バッファの診断。開いたときにフォーカスする |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Tree-sitter による構文ハイライト、インデント、コード解析を提供する | C、C++、Lua、Python、Rust 以外の各種言語などを対象にパーサーを自動インストール。インストール時に `:TSUpdate` を実行 |
| [nvim-treesitter/nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | スクロールしても現在の関数やブロックの先頭を画面上部に表示する | 最大3行を表示 |
| [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | HTML、JSX などのタグを自動で閉じたり、対応する開始・終了タグを同時に変更したりする | Tree-sitter と連携して動作 |

## UI・表示

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | 開いているバッファをタブのように上部へ表示する | 常に表示。`Shift-h`/`Shift-l` で前後のバッファ、`<Space>bd` で削除、`<Space>bp` でピン留め。LSP 診断数も表示 |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | 画面下部のステータスラインを表示する | TokyoNight テーマと区切り文字を使用 |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | ファイルタイプに応じたコードフォーマッターを実行する | 保存時に最大500ms待って整形。JavaScript、TypeScript、CSS、HTML、Astro は Prettier、Python は Ruff、Go は goimports を使用。LSP フォールバックあり |
| [folke/noice.nvim](https://github.com/folke/noice.nvim) | コマンドライン、メッセージ、通知、LSP の進捗表示を置き換える | コマンドラインは中央ポップアップではなく、画面下端の `cmdline` 表示。通知は nvim-notify を使用 |
| [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | ファイルツリーを表示する | `<Space>e` でファイルツリーにフォーカス。ファイル種別と Git 状態のアイコンを表示 |
| [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Markdown と MDX を編集中に装飾表示する | 初期状態では無効。`<Space>md` で表示を切り替える |
| [sphamba/smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | カーソル移動をアニメーションさせ、移動元に残像を表示する | 行内・行間移動、バッファ切り替え、スクロール、Insert mode で残像を表示 |
| [shellRaining/hlchunk.nvim](https://github.com/shellRaining/hlchunk.nvim) | 現在いるコードブロックの範囲とインデントを視覚化する | chunk とインデント線を表示。chunk のアニメーション時間は200ms、遅延は100ms |
| [emmanueltouzery/key-menu.nvim](https://github.com/emmanueltouzery/key-menu.nvim) | キーを押したあとに続けて使えるキーをポップアップ表示する | `<Space>` を押すと候補を表示。`<Space>b` を Buffer グループとして表示。待ち時間は300ms |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim) | リーダーキーなどのキーマップ候補を表示する | `<Space>` のキーマップ表示を有効化。待ち時間は300ms |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Neovim 内にターミナルを開く | `<Space>t` でフローティングターミナルを開閉。ターミナルモードで `Esc` を2回押すとノーマルモードへ戻る |

## テーマ・起動画面・画像表示

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | カラースキームを提供する | 起動時に `tokyonight` を適用 |
| [nvimdev/dashboard-nvim](https://github.com/nvimdev/dashboard-nvim) | Neovim 起動時のスタート画面を表示する | `VimEnter` で読み込み。基本設定はデフォルト |
| [3rd/image.nvim](https://github.com/3rd/image.nvim) | ターミナル上に画像を表示する | kitty backend と ImageMagick CLI を使用。nvim-Amadeus の依存 |
| [iorinu/nvim-Amadeus](https://github.com/iorinu/nvim-Amadeus) | 起動シーケンスのフレームアニメーションを表示する | 自動再生は無効。`:Amadeus` で開始、`:AmadeusStop` で停止。フレームは `~/.config/nvim/amadeus_frames` に別途配置 |

## Markdown・Jupyter・LaTeX

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [benlubas/molten-nvim](https://github.com/benlubas/molten-nvim) | Neovim から Jupyter カーネルを起動し、コードセルを実行する | Python と Markdown で読み込み。`<Space>m` 配下にカーネル初期化、セル実行、出力表示などを設定 |
| [GCBallesteros/jupytext.nvim](https://github.com/GCBallesteros/jupytext.nvim) | `.ipynb` とテキスト形式を相互変換する | `.ipynb` を Python の `py:percent` 形式で編集。`<Space>j` で現在の `.py` を `.ipynb` に変換して開く |
| [lervag/vimtex](https://github.com/lervag/vimtex) | LaTeX の編集、コンパイル、PDF プレビューを支援する | `latexmk` と `lualatex` でビルド。macOS の PDF ビューアーは Skim |

## OpenAPI・Swagger

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [vinnymeller/swagger-preview.nvim](https://github.com/vinnymeller/swagger-preview.nvim) | OpenAPI・Swagger ファイルを Swagger UI でブラウザにライブプレビューする | `:SwaggerPreview` で起動、`:SwaggerPreviewStop` で停止。保存時にプレビューを更新。`swagger-ui-watcher` が必要 |

### Molten の外部依存

Molten を使うには、Neovim 側のプラグインだけでなく、Python 環境に `pynvim`、`jupyter_client`、`ipykernel` が必要です。現在の設定では `~/.venvs/neovim/bin/python` を Python ホストとして指定しています。

Jupytext の変換には `jupytext` CLI も必要です。

## 入力・編集支援

| プラグイン | 役割 | 現在の設定 |
|---|---|---|
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | 括弧や引用符を自動入力する | `InsertEnter` で読み込み。Tree-sitter と連携し、nvim-cmp の補完確定時にも括弧を追加 |
| [iorinu/kutoten-toggle.nvim](https://github.com/iorinu/kutoten-toggle.nvim) | 日本語の句読点と論文向けの記号を一括変換する | `:KutotenZen`、`:KutotenHan`、`:KutotenNormal` の実行時だけ読み込み |
| [keaising/im-select.nvim](https://github.com/keaising/im-select.nvim) | Insert mode と日本語入力・英数入力を連携する | **無効**。macOS の `im-select` を使う設定は残っているが、現在は読み込まない |

## 無効化中の UI プラグイン

| プラグイン | 役割 | 現在の状態 |
|---|---|---|
| [iorinu/critter.nvim](https://github.com/iorinu/critter.nvim) | Neovim 内に小さなペットを表示する | **無効**。依存する [edluffy/hologram.nvim](https://github.com/edluffy/hologram.nvim) も現在は使用しない。WezTerm ではゴーストが残りやすいという注意書きがある |

## アイコン・UI 基盤の依存プラグイン

| プラグイン | 役割 | 主な利用先 |
|---|---|---|
| [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | ファイル種別や診断のアイコンを提供する | NvimTree、Bufferline、Lualine、Trouble、Dashboard、Render Markdown など |
| [MunifTanjim/nui.nvim](https://github.com/MunifTanjim/nui.nvim) | ポップアップやメニューなどの UI コンポーネントを提供する | Noice |
| [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify) | 通知を浮動ウィンドウで表示する | Noice の通知ビュー |

## 補足

- `nvim/.config/nvim/legacy/gitgragh` は、`gitgraph.lua` と同じ GitGraph 定義を持つ旧ファイルです。プラグイン読み込み対象の `lua/plugins/` 外へ移してあり、この一覧では `isakbm/gitgraph.nvim` を1回だけ記載しています。
- `lazy-lock.json` のエントリは、プラグイン本体だけでなく依存プラグインも含みます。
- プラグインのロード条件やキー設定を変更した場合は、このファイルの該当箇所も更新します。
