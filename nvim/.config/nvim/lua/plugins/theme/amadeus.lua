-- nvim 起動時に Amadeus 起動シーケンス GIF を流すプラグイン
-- GIF 本体は著作権の都合で dotfiles リポジトリにも含めず、
-- stdpath("config")/amadeus.gif (= ~/.config/nvim/amadeus.gif) に各自で配置する。
-- このパスは dotfiles 側の .gitignore で除外済み。
-- プラグインクローン先 (~/.local/share/nvim/lazy/) に置くと再インストール時に消えるので避ける。
--
-- dashboard-nvim と同じ VimEnter で発火するが、Amadeus はフローティングウィンドウとして
-- dashboard の上に重なり、duration_ms 経過後に自動で閉じる。
return {
  {
    -- 画像をターミナルに表示するための依存。wezterm は kitty backend で動作する。
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "kitty",
      processor = "magick_cli", -- magick CLI を使う (luarocks の magick が不要)
    },
  },
  {
    "iorinu/nvim-Amadeus",
    dependencies = { "3rd/image.nvim" },
    event = "VimEnter",
    opts = {
      autoplay = true,
      duration_ms = 3000,
      width = 80,
      height = 24,
      gif_path = vim.fn.stdpath("config") .. "/amadeus.gif",
    },
  },
}
