-- critter.nvim (エディタに住むペット。コードの健康状態で表情/挙動が変わる)
-- 描画は edluffy/hologram.nvim (kitty graphics protocol) を使う。
-- 対応ターミナル: kitty, Ghostty, WezTerm (WezTerm はゴーストが残りやすいので注意)
return {
	"iorinu/critter.nvim",
	-- VimEnter で自動 show するので遅延ロードしない方が確実
	lazy = false,
	dependencies = {
		{
			"edluffy/hologram.nvim",
			config = function()
				-- auto_display はマークダウン画像用なので critter には不要
				require("hologram").setup({ auto_display = false })
			end,
		},
	},
	opts = {
		critter = "crab", -- "mame" | "dog" | "clippy" | "crab" | "snake" | "rubber_duck"
		-- 必要に応じて調整:
		-- base_height       = 4,
		-- walk_strip_cells  = 20,
		-- right_margin_cells= 2,
		-- fps               = 2,
	},
}
