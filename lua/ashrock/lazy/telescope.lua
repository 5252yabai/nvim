return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>pf', function() require('telescope.builtin').find_files() end, desc = 'Telescope find files' },
    { '<leader>ps', function() require('telescope.builtin').live_grep() end },
    { '<C-p>', function() require('telescope.builtin').git_files() end, desc = 'Telescope find git files' },
  },
  config = function()
    require('telescope').setup {
      defaults = {
        -- 긴 경로 중간을 … 으로 잘라내고, 끝부분(파일명)은 항상 보이게
        path_display = { "truncate" },
      },
    }
  end
}
