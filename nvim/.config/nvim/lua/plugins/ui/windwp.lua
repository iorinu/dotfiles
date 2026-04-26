-- lazy.nvimでの導入例
return {
	"windwp/nvim-ts-autotag",
	config = function()
		require("nvim-ts-autotag").setup()
	end,
}
