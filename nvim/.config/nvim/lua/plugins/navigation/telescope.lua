  -- 2. Telescope (検索プラグイン)
  return{
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',  -- バージョンを指定
    dependencies = { 'nvim-lua/plenary.nvim' }, -- 依存プラグイン
    config = function()
      -- ここでショートカットキーを設定します
      local builtin = require('telescope.builtin')
      
      -- 「スペース」+ f + f でファイル検索
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      
      -- 「スペース」+ f + g で文字検索 (grep)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      
      -- 「スペース」+ f + b で開いているバッファ検索
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      
      -- 「スペース」+ f + h でヘルプ検索
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end
  }