return {
	"emmanueltouzery/key-menu.nvim",
	event = "VeryLazy",
	config = function()
		-- ポップアップが出るまでの待ち時間 (ms)
		vim.o.timeoutlen = 300

		-- <Space> (leader) を押したらヒント表示
		require("key-menu").set("n", "<Space>")

		-- グループの説明
		require("key-menu").set("n", "<Space>b", { desc = "Buffer" })
	end,
}
