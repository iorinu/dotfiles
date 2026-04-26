return {
	-- 1. Copilot 本体 (Neovim専用の軽量版)
	-- 公式の 'github/copilot' の代わりに入れます
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true, -- 自動で補完を出す
					keymap = {
						accept = "<Tab>",
					},
				},
				panel = { enabled = true },
			})
		end,
	},

	-- 2. Copilot Chat (チャット機能)
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- 上記のプラグインに依存
			{ "nvim-lua/plenary.nvim" },
		},
		build = "make tiktoken", -- チャットの応答速度を上げる
		opts = {
			system_prompt = "回答は全て日本語で行ってください。", -- システムプロンプトの設定",
			window = {
				layout = "float", -- 'vertical' にすると画面分割、'float' だと浮く
				width = 0.5, -- 幅の広さ
			},
		},
		-- キー設定（Ctrl + c でチャットを開閉する設定例）
		keys = {
			{ "<C-c>", "<cmd>CopilotChatToggle<cr>", desc = "Copilot Chat" },
		},
	},
}
