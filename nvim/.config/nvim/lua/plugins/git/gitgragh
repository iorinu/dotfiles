  --10. GitGraph (Git履歴表示)
  return{
  'isakbm/gitgraph.nvim',
  dependencies = { 'sindrets/diffview.nvim' }, -- diffviewを入れると幸せになれます
  opts = {
    symbols = {
      merge_commit = 'M',
      commit = '*',
    },
    format = {
      timestamp = '%Y-%m-%d %H:%M',
      fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
    },
    hooks = {
      -- Enterを押したときの動作：Diffviewでそのコミットを開く
      on_select_commit = function(commit)
        vim.notify("Diffview opening commit: " .. commit.hash)
        vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
      end,
      -- 範囲選択してEnterしたときの動作：範囲の差分を見る
      on_select_range_commit = function(from, to)
        vim.notify("Diffview opening range: " .. from.hash .. "..." .. to.hash)
        vim.cmd(":DiffviewOpen " .. from.hash .. ".." .. to.hash)
      end,
    },
  },
  keys = {
    {
      "<leader>gl", -- Space + g + l でグラフを表示
      function()
        require('gitgraph').draw({}, { all = true, max_count = 5000 })
      end,
      desc = "GitGraph - Draw",
    },
  },
  }