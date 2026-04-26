-- MDXファイルタイプの認識
vim.filetype.add({
	extension = {
		mdx = "mdx",
	},
})

-- 行番号を表示
vim.opt.number = true
vim.opt.relativenumber = true -- 相対行番号（ジャンプしやすくなる）

-- クリップボードをOSと共有 (Ctrl+C / Ctrl+V と連携)
vim.opt.clipboard = "unnamedplus"

-- インデント設定 (スペース2個分)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true -- タブをスペースに変換
vim.opt.autoindent = true

-- 検索設定
vim.opt.ignorecase = true -- 大文字小文字を区別しない
vim.opt.smartcase = true -- 大文字が入っているときだけ区別する

-- マウス有効化
vim.opt.mouse = "a"

-- 色の設定（フルカラー対応）
vim.opt.termguicolors = true

--縦横ラインの表示
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

--エラーのアイコンを定義
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- 診断表示の設定
vim.diagnostic.config({
	virtual_text = true, -- 仮想テキストを表示
	signs = true, -- サインを表示
	underline = true, -- 下線を表示
	update_in_insert = false, -- 挿入モードでの更新を無効化
	severity_sort = true, -- 深刻度でソート
})
