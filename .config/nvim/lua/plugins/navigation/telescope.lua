-- 2. Telescope (検索プラグイン)
return {
  'nvim-telescope/telescope.nvim',
  tag = 'v0.2.1',                              -- バージョンを指定
  dependencies = { 'nvim-lua/plenary.nvim' }, -- 依存プラグイン
  config = function()
    -- ここでショートカットキーを設定します
    local builtin = require('telescope.builtin')

    -- 「スペース」+ f + f でファイル検索
    vim.keymap.set('n', '<leader>ff', function()
      builtin.find_files({
        hidden = true,
        file_ignore_patterns = { '^%.git/' },
      })
    end, { desc = 'Find Files' })
    -- 「スペース」+ f + g で文字検索 (grep)
    vim.keymap.set('n', '<leader>fg', function()
      builtin.live_grep({
        additional_args = { '--hidden', '--glob', '!.git' },
      })
    end, { desc = 'Live Grep' })

    -- 「スペース」+ f + b で開いているバッファ検索
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })

    -- 「スペース」+ f + h でヘルプ検索
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help Tags' })

    -- 今の単語を検索
    vim.keymap.set('n', '<leader>fw', function()
      builtin.grep_string({
        additional_args = { '--hidden', '--glob', '!.git' },
      })
    end, { desc = 'Find Word' })
  end
}
