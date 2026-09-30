return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown", "mdx" },
  keys = {
    { "<Space>md", ":RenderMarkdown toggle<CR>", desc = "Toggle Render Markdown" },
  },
  opts = {
    -- デフォルトでは装飾レンダリングをオフにする（.ipynb 編集時などに邪魔なため）
    -- 必要なときは <Space>md でトグル
    enabled = false,
    render_modes = true,
  },
}
