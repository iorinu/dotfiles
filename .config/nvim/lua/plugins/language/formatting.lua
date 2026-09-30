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
        -- python: import 順の整理 → コード整形 の順に走らせる
        python = { "ruff_organize_imports", "ruff_format" },
        -- go: goimports が gofmt を包含 + 未使用/不足importの自動調整までやる
        go = { "goimports" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end,
}
