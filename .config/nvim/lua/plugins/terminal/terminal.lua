--6.ToggleTerm (ターミナル機能)
return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- サイズ設定
      size = 20,
      -- ショートカットキー設定 (<leader>t)
      open_mapping = [[<leader>t]],
      -- 開き方: 'float' (浮く), 'horizontal' (下), 'vertical' (右)
      direction = 'float',
      -- 枠のデザイン
      float_opts = {
        border = 'curved',
      },
    })

    -- ターミナルモードから抜けやすくする設定
    -- Escキー2回押しでノーマルモードに戻れるようにする
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], opts)
    end

    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end
}
