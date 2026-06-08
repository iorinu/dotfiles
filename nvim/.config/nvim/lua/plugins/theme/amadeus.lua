-- nvim 起動時に Amadeus 起動シーケンスを流すプラグイン。
-- フレーム素材は著作権の都合で dotfiles リポジトリにも含めず、
-- stdpath("config")/amadeus_frames/ (= ~/.config/nvim/amadeus_frames/) に各自で配置する。
-- このパスは dotfiles 側の .gitignore で除外済み。
-- プラグインクローン先 (~/.local/share/nvim/lazy/) に置くと再インストール時に消えるので避ける。
--
-- 起動時の自動再生は現状安定しないので autoplay は false にして手動 (`:Amadeus`) 運用にしている。
-- 安定化したら autoplay = true に戻す予定。
-- 追跡: https://github.com/iorinu/nvim-Amadeus/issues/1
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
    -- autoplay を切ったので VimEnter で先読みする必要はない。`:Amadeus` 実行時にロードする。
    cmd = { "Amadeus", "AmadeusStop" },
    opts = {
      autoplay = false,
      fps = 15,
      width = 120,
      height = 34,
      frames_dir = vim.fn.stdpath("config") .. "/amadeus_frames",
    },
  },
}
