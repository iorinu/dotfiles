-- 日本語の句読点「、。」と論文用の記号「，．」/「, .」を一括変換する自作プラグイン
return {
	"iorinu/kutoten-toggle.nvim",
	-- コマンドが呼ばれたときだけロードする（起動を軽く保つため）
	cmd = { "KutotenZen", "KutotenHan", "KutotenNormal" },
	config = function()
		require("kutoten-toggle").setup()
	end,
}
