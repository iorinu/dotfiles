return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<Space>md", ":RenderMarkdown toggle<CR>", desc = "Toggle Render Markdown" },
	},
	opts = {},
}
