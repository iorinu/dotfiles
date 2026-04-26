-- リーダーキー設定（これだけは最初に書く）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 役割ごとに分けたファイルを読み込む
require("config.lazy")    -- Lazyの起動とプラグイン読み込み
require("config.options") -- 基本設定 (行番号など)
require("config.keymaps") -- キー設定

