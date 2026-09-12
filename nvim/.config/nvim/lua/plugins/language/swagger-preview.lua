return {
	{
		"vinnymeller/swagger-preview.nvim",
		cmd = { "SwaggerPreview", "SwaggerPreviewStop", "SwaggerPreviewToggle" },
		build = "npm i",
		config = function()
			require("swagger-preview").setup({
				port = 8001,
				host = "127.0.0.1",
			})
		end,
	},
}
