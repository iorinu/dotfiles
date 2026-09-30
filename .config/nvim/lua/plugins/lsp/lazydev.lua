-- lazydev.nvim: Neovim設定のLuaファイルを編集する時だけ
-- Neovimランタイム(vim.*)の型と補完を lua_ls に注入するプラグイン
-- → 通常のLuaプロジェクトには影響を与えず、~/.config/nvim 配下でだけ効く
return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- Luaファイルを開いた時だけロード
		opts = {
			library = {
				-- lazy.nvim のプラグイン型も読み込む（{ "lazy.nvim", words = { "LazyVim" } } 等でさらに絞れる）
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
