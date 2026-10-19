return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate", -- インストール時にパーサーを更新する
		lazy = false,
		config = function()
			local treesitter = require("nvim-treesitter")

			treesitter.setup({})
			treesitter.install({
				-- 利用するパーサーを非同期でインストールする
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query", -- 必須
				"python",
				"cpp",
				"bash",
				"markdown", -- よく使うもの
				"markdown_inline",
				"latex",
				"astro",
				"css",
				"html",
				"javascript",
				"json",
				"typescript",
				"tsx",
				"go",
				"gomod",
				"gosum",
			})

			vim.treesitter.language.register("markdown", "mdx")
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local filetype = vim.bo[args.buf].filetype
					local lang = vim.treesitter.language.get_lang(filetype)
					if not lang then
						return
					end

					-- 未導入または未知のパーサーでは何もしない
					local ok, available = pcall(vim.treesitter.language.add, lang)
					if not ok or not available then
						return
					end

					vim.treesitter.start(args.buf)
					if vim.treesitter.query.get(lang, "indents") then
						vim.bo[args.buf].indentexpr = 'v:lua.require"nvim-treesitter".indentexpr()'
					end
				end,
			})
		end,
	},
}
