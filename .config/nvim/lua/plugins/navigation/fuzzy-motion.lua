-- Enterで起動し、入力した文字列にファジーに一致する単語へ移動する
return {
	"yuki-yano/fuzzy-motion.vim",
	cmd = "FuzzyMotion",
	dependencies = {
		"vim-denops/denops.vim",
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
