return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" }, -- ファイルを開いたときに読み込む
  config = function()
    -- ここに質問のコードを書きます
    require("conform").setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        astro = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end,
}
