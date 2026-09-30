return {
  "kdheepak/lazygit.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    -- 設定は特に必要ありませんが、見た目を整えるならここに書きます
  end,
  keys = {
    -- スペース + g + g でGit画面を開く設定
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
}
