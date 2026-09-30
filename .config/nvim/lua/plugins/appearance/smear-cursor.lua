-- カーソル移動に残像（smear）アニメーションを付ける
return {
	"sphamba/smear-cursor.nvim",
	opts = {
		-- 行内移動や隣の行への移動でも残像を表示する
		smear_between_neighbor_lines = true,
		-- バッファやウィンドウの切り替えでも残像を表示する
		smear_between_buffers = true,
		-- スクロール時もバッファ位置に合わせて残像を描画する
		scroll_buffer_space = true,
		-- Insert mode でも残像を表示する
		smear_insert_mode = true,
	},
}
