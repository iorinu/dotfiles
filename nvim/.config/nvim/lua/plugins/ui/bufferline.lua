return {
	"akinsho/bufferline.nvim",
	version = "*",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- 【重要】タブを常に表示する設定（Neovim自体の設定）
		vim.opt.showtabline = 2

		require("bufferline").setup({
			options = {
				mode = "buffers",

				-- デザイン設定
				separator_style = "slant", -- "slant" | "slope" | "thick" | "thin"
				always_show_bufferline = true,

				-- アイコン設定
				buffer_close_icon = "󰅖",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",

				-- 左端のインジケーター（選択されていることがわかる棒）
				indicator = {
					style = "icon",
					icon = "▎",
				},

				-- NvimTreeが開いているとき、左側をずらしてタイトルを表示
				offsets = {
					{
						filetype = "NvimTree",
						text = "FILE EXPLORER", -- ここでシステム感を出す
						text_align = "center",
						separator = true,
					},
				},

				-- エラーなどをアイコンで表示（HUD風）
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level, diagnostics_dict, context)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,

				color_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
			},

			-- 【見た目の調整】フォントは変えず、色と太さだけでかっこよくする
			highlights = {
				-- 選択中のタブ：真っ白で太字（斜体なし）
				buffer_selected = {
					bold = true,
					italic = false,
					fg = "#ffffff",
					bg = "#1f2335", -- 背景色はテーマに馴染む色（TokyoNight系）
				},
				-- 選択されていないタブ：少し暗くする
				buffer_visible = {
					fg = "#565f89",
					italic = false,
				},
				-- 背景（タブがない部分）
				fill = {
					bg = "#1a1b26",
				},

				-- エラーなどの表示も斜体をなくしてクッキリさせる
				diagnostic_selected = { bold = true, italic = false },
				info_selected = { bold = true, italic = false },
				warning_selected = { bold = true, italic = false },
				hint_selected = { bold = true, italic = false },

				-- セパレーター（仕切り線）を目立たなくして一体感を出す
				separator_selected = {
					fg = "#1f2335",
					bg = "#1f2335",
				},
				indicator_selected = {
					fg = "#7aa2f7", -- インジケーターの色（青系）
					bg = "#1f2335",
				},
			},
		})
	end,

	-- ショートカットキー設定
	keys = {
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
		{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Pin" },
	},
}
