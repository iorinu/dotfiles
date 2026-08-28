return {
	"shellRaining/hlchunk.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("hlchunk").setup({
			-- chunk: 今いるブロックを強調する設定
			chunk = {
				enable = true,
				support_filetypes = {
					tex,
					latex,
					plaintext,
					bib,
					-- 必要に応じて他のファイルタイプも追加できます
				},
				-- ここで見た目を調整できます
				style = {
					{ fg = "#806d9c" }, -- カッコの色（紫系）
				},
				-- カッコの文字（これが「カギ括弧」のような見た目を作ります）
				chars = {
					horizontal_line = "─",
					vertical_line = "│",
					left_top = "╭",
					left_bottom = "╰",
					right_arrow = ">",
				},
				-- アニメーションの速度
				duration = 200,
				delay = 100,
			},

			-- indent: 通常のインデント線（indent-blanklineの代わりにもなります）
			indent = {
				enable = true,
				chars = {
					"│",
				},
				style = {
					{ fg = "#383838" }, -- 薄いグレー
				},
			},
		})
	end,
}
