--ファイルのタイムラインを表示するプラグイン  
return {
  "sindrets/diffview.nvim",
  keys = {
    -- スペース + g + h で現在のファイルの変更履歴（ヒストリー）を見る
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
    -- スペース + g + c で閉じる
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
  },
}
