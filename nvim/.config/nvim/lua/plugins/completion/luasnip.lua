return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*", -- 最新版を指定
		build = "make install_jsregexp", -- 正規表現などのためにビルドが必要（任意ですが推奨）
		dependencies = {
			"rafamadriz/friendly-snippets", -- ここにスニペット集を依存関係として入れる
			"saadparwaiz1/cmp_luasnip", -- nvim-cmpとの連携用
		},
		config = function()
			local ls = require("luasnip")

			-- VSCode形式のスニペット（friendly-snippets）を読み込む魔法のコマンド
			require("luasnip.loaders.from_vscode").lazy_load()

			-- (重要) キーマッピングの設定
			-- スニペット展開中に次の入力箇所(プレースホルダ)へジャンプする設定
			-- ここでは Ctrl + k で「次へ」、Ctrl + j で「戻る」にしています
			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end, { silent = true })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, { silent = true })
		end,
	},
}
