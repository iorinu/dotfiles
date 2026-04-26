return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate", -- インストール時にパーサーを更新する
		event = { "BufReadPost", "BufReadPost" }, -- 遅延読み込み
		config = function()
			local configs = require("nvim-treesitter.config")

			configs.setup({
				-- 自動でインストールする言語のリスト
				-- あなたの関心分野に合わせて C++, Python, Lua を入れています
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query", -- 必須
					"python",
					"cpp",
					"bash",
					"markdown", -- よく使うもの
					"latex",
					"astro",
					"css",
					"html",
					"javascript",
					"json",
					"typescript",
					"tsx",
					"markdown",
					"markdown_inline",
					"mdx",
				},

				-- 同期インストール（false推奨）
				sync_install = false,

				-- ハイライトを有効にする (これがメイン機能)
				highlight = { enable = true },

				-- インデントを有効にする
				indent = { enable = true },
			})
		end,
	},
}
