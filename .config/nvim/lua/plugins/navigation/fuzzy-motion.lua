-- Enterで起動し、入力した文字列にファジーに一致する単語へ移動する
return {
	"yuki-yano/fuzzy-motion.vim",
	init = function()
		vim.g.fuzzy_motion_matchers = { "fzf", "kensaku" }
	end,
	cmd = "FuzzyMotion",
	dependencies = {
		"vim-denops/denops.vim",
		"lambdalisue/kensaku.vim",
	},
	keys = {
		{
			"<CR>",
			"<cmd>FuzzyMotion<CR>",
			mode = "n",
			desc = "Fuzzy motion",
		},
	},
}
