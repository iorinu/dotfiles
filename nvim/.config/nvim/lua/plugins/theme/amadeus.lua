-- nvim 起動時に Amadeus 起動シーケンスを流すプラグイン。
-- フレーム素材は著作権の都合で dotfiles リポジトリにも含めず、
-- stdpath("config")/amadeus_frames/ (= ~/.config/nvim/amadeus_frames/) に各自で配置する。
-- このパスは dotfiles 側の .gitignore で除外済み。
-- プラグインクローン先 (~/.local/share/nvim/lazy/) に置くと再インストール時に消えるので避ける。
--
-- dashboard-nvim と同じ VimEnter で発火するが、Amadeus はフローティングウィンドウとして
-- dashboard の上に重なり、全フレーム再生後に自動で閉じる。
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
      fps = 15,
      width = 120,
      height = 34,
      frames_dir = vim.fn.stdpath("config") .. "/amadeus_frames",
    },
  },
}
