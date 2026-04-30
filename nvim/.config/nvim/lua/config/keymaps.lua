-- 記述ルール: vim.keymap.set("モード", "押すキー", "実行するコマンド")

-- "jk" を素早く押すと、Esc (ノーマルモードに戻る) 扱いにする
-- （これに慣れると小指が楽になります）
vim.keymap.set("i", "jk", "<Esc>")

-- 検索のハイライトを消す (Esc を押したとき)
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ファイル保存 (スペース + w)
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })

-- Neovim終了 (スペース + q)
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

vim.keymap.set("n", "<leader>bg", function()
	-- 現在のNormalハイライト（背景色）を取得
	local hl = vim.api.nvim_get_hl(0, { name = "Normal" })

	-- 背景色が設定されていない（すでに透明）なら、テーマを再適用して元に戻す
	if not hl.bg then
		vim.cmd("colorscheme " .. vim.g.colors_name)
		print("Transparency: OFF") -- 画面下にメッセージを表示
	else
		-- 背景色があるなら、透明（NONE）に設定する
		vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" }) -- ポップアップも透明化
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", ctermbg = "NONE" }) -- 枠線も透明化
		print("Transparency: ON")
	end
end, { desc = "Toggle Background Transparency" })

-- ¥キーでバックスラッシュを入力する (日本語キーボード対応)
vim.keymap.set({'i', 'c', 't'}, '¥', '\\', { noremap = true })

