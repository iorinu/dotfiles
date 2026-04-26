return {
	"keaising/im-select.nvim",
	enabled = false,
	config = function()
		require("im_select").setup({
			-- macOS用: brew install im-select でインストール可能
			default_command = "im-select",

			-- 英数入力モードのID (com.apple.keylayout.ABC など)
			default_im_select = "com.apple.keylayout.ABC",

			-- 挿入モード開始時の復元を無効化
			set_previous_events = {},
		})
	end,
}
