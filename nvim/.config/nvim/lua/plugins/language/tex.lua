return {
	"lervag/vimtex",
	lazy = false, -- ファイルを開いたときに読み込むため lazy load はしない方が無難
	init = function()
		-- VimTeXの設定は init 関数内（プラグイン読み込み前）に書くことが推奨されています

		-- ビューワーの設定 (macOS用: Skim)
		-- Skimは https://skim-app.sourceforge.io/ からインストール
		vim.g.vimtex_view_method = "skim"

		-- コンパイラの設定 (latexmkを使用)
		vim.g.vimtex_compiler_method = "latexmk"

		-- デフォルトのエンジンをlualatexに変更
		vim.g.vimtex_compiler_latexmk_engines = {
			["_"] = "-lualatex",
		}

		-- ビルドごとの自動クリーンアップ（お好みで）
		-- vim.g.vimtex_compiler_latexmk = {
		--    options = {
		--      '-shell-escape',
		--      '-verbose',
		--      '-file-line-error',
		--      '-synctex=1',
		--      '-interaction=nonstopmode',
		--    },
		-- }
	end,
}
