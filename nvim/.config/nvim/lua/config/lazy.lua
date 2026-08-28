-- Lazy.nvim を自動ダウンロードするコード
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ここが一番重要！
-- 「lua/plugins 以下の各カテゴリを読み込め」という指示です
require("lazy").setup({
	spec = {
		{ import = "plugins.ai" },
		{ import = "plugins.appearance" },
		{ import = "plugins.completion" },
		{ import = "plugins.editor" },
		{ import = "plugins.git" },
		{ import = "plugins.language" },
		{ import = "plugins.lsp" },
		{ import = "plugins.navigation" },
		{ import = "plugins.terminal" },
	},
})
