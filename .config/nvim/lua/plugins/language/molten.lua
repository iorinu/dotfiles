-- molten.nvim: Neovim から Jupyter カーネルを操作するプラグイン
--
-- 前提（別途、自分でインストールが必要）:
--   1. Python 側の依存
--        pynvim           : Neovim と Python を橋渡しする公式ライブラリ
--        jupyter_client   : Jupyter カーネルとの通信用
--        ipykernel        : Python カーネル本体（他言語ならそのカーネルを別途）
--      例: uv tool install または venv 内で `uv add --dev pynvim jupyter_client ipykernel`
--   2. Neovim 側で使う Python ホストの指定（下の g:python3_host_prog）
--      → pynvim を入れた Python の絶対パスに合わせて調整してください
--
-- .ipynb を編集するために jupytext.nvim を併用します。
-- 　.ipynb を開くと自動で Python バッファに変換して編集でき、
-- 　保存時に .ipynb 側へ書き戻してくれます（jupytext CLI が別途必要）。
--   pip 相当: `uv tool install jupytext`

return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- メジャーバージョン固定（破壊的変更を避けるため）
		dependencies = {
			"GCBallesteros/jupytext.nvim", -- .ipynb <-> .py の相互変換
		},
		build = ":UpdateRemotePlugins", -- Python リモートプラグインの登録（必須）
		ft = { "python", "markdown" }, -- 対象ファイルタイプでのみ遅延ロード
		init = function()
			-- Neovim が使う Python のパス。pynvim を入れた環境を指定する。
			-- 専用 venv: ~/.venvs/neovim (pynvim, jupyter_client, ipykernel インストール済み)
			vim.g.python3_host_prog = vim.fn.expand("~/.venvs/neovim/bin/python")

			-- 画像は使わない設定なので image provider は none
			vim.g.molten_image_provider = "none"

			-- 出力ウィンドウを最小限のスタイルに
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_output_win_style = "minimal"

			-- 仮想テキストで出力の一部を行末に表示（軽量で見やすい）
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true

			-- 出力を自動でウィンドウ表示（true にすると常に飛び出してくるので false 推奨）
			vim.g.molten_auto_open_output = false

			-- カーソル移動時に出力ウィンドウを自動で開閉
			vim.g.molten_wrap_output = true
		end,
		config = function()
			-- キーマップ（<leader> = Space）
			-- ここでは Molten の主要操作を <leader>m プレフィックスにまとめる
			local map = vim.keymap.set

			-- カーネル起動・停止
			map("n", "<leader>mi", ":MoltenInit<CR>", { silent = true, desc = "Molten: カーネル初期化" })
			map("n", "<leader>md", ":MoltenDeinit<CR>", { silent = true, desc = "Molten: カーネル停止" })

			-- セル実行系
			-- 現在の行/オペレータ範囲を評価
			map("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { silent = true, desc = "Molten: 範囲評価(オペレータ)" })
			map("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { silent = true, desc = "Molten: 現在行を評価" })
			map("n", "<leader>mr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "Molten: セル再評価" })
			-- ビジュアル選択範囲を評価
			map("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true, desc = "Molten: 選択範囲を評価" })

			-- 出力の表示・非表示
			map("n", "<leader>mo", ":noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "Molten: 出力ウィンドウへ" })
			map("n", "<leader>mh", ":MoltenHideOutput<CR>", { silent = true, desc = "Molten: 出力を隠す" })

			-- 実行結果を .ipynb に書き戻す（jupytext 経由だと出力が保存されないため必要）
			map("n", "<leader>mx", ":MoltenExportOutput<CR>", { silent = true, desc = "Molten: 出力を .ipynb に書き出し" })
		end,
	},
	{
		"GCBallesteros/jupytext.nvim",
		lazy = false, -- .ipynb を開いた瞬間に効かせたいので即ロード
		config = function()
			require("jupytext").setup({
				-- .ipynb を開いたときのデフォルト形式
				-- "py:percent" は # %% でセルを区切る Python 形式。
				-- Markdown 中間ファイル (.md) が生成されず、Python のまま編集できる
				style = "py:percent",
				output_extension = "py",
				force_ft = "python",
			})

			-- <leader>j : 現在の .py を .ipynb に変換して開く
			-- なぜ vim.system か: 非同期でエディタをブロックせず、終了時にコールバックで通知できる
			vim.keymap.set("n", "<leader>j", function()
				local src = vim.api.nvim_buf_get_name(0)
				if src == "" or not src:match("%.py$") then
					vim.notify("jupytext: .py ファイルで実行してください", vim.log.levels.WARN)
					return
				end
				-- 未保存の変更があれば先に保存（変換対象はディスク上のファイル）
				if vim.bo.modified then
					vim.cmd("write")
				end
				local out = src:gsub("%.py$", ".ipynb")
				-- --set-kernel python3: 生成 .ipynb に kernelspec を埋め込む
				--   これが無いと jupytext.nvim 側の read_from_ipynb が kernelspec 不在で落ちる
				vim.system(
					{ "jupytext", "--to", "notebook", "--set-kernel", "python3", "-o", out, src },
					{ text = true },
					vim.schedule_wrap(function(res)
						if res.code ~= 0 then
							vim.notify("jupytext 変換失敗:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
							return
						end
						vim.notify("jupytext: " .. out .. " を生成")
						vim.cmd("edit " .. vim.fn.fnameescape(out))
					end)
				)
			end, { silent = true, desc = "jupytext: .py -> .ipynb 変換して開く" })
		end,
	},
}
