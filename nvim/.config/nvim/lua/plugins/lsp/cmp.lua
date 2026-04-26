-- nvim-cmpの設定ファイル
return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter", -- 入力モードになったら読み込む
	dependencies = {
		"hrsh7th/cmp-nvim-lsp", -- LSPからの候補を出す
		"hrsh7th/cmp-buffer", -- 開いているファイル内の単語を出す
		"hrsh7th/cmp-path", -- ファイルパスを出す
		"L3MON4D3/LuaSnip", -- スニペットエンジン（必須）
		"saadparwaiz1/cmp_luasnip",
		"onsails/lspkind.nvim", -- 補完リストにアイコンを表示
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")

		-- LSP補完ソースを有効化（lazy.nvimがafter/pluginを実行しないため手動で呼ぶ）
		require("cmp_nvim_lsp").setup()

		cmp.setup({
			-- スニペットエンジンの設定
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},

			-- 補完ウィンドウの見た目
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},

			-- アイコンを表示する設定
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol",
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},

			-- キー設定
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- 前の候補へ (Ctrl+k)
				["<C-j>"] = cmp.mapping.select_next_item(), -- 次の候補へ (Ctrl+j)
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- 手動で補完を出す
				["<C-e>"] = cmp.mapping.abort(), -- 補完を閉じる
				["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enterで確定
			}),

			-- 補完のソース（優先順位順）
			sources = cmp.config.sources({
				{ name = "nvim_lsp" }, -- LSP (変数や関数)
				{ name = "luasnip" }, -- スニペット
				{ name = "buffer" }, -- バッファ内の単語
				{ name = "path" }, -- ファイルパス
			}),
		})
	end,
}
