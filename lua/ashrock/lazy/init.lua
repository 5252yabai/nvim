return {
  {
    "eoh-bse/minintro.nvim",
    opts = { color = '#4169E1'},
    config = true,
    lazy = false
  },
  "andreasvc/vim-256noir",
  "nvim-lua/plenary.nvim",
  'tpope/vim-fugitive',
  'prettier/vim-prettier',
  {
  "zenbones-theme/zenbones.nvim",
  dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
  },
  { 'windwp/nvim-ts-autotag', config = true },
  "theprimeagen/vim-be-good",
  "sainnhe/gruvbox-material",
  "yorumicolors/yorumi.nvim",
  "rebelot/kanagawa.nvim",
  "folke/tokyonight.nvim",
  "scottmckendry/cyberdream.nvim",
  { 'glacambre/firenvim',     build = ":call firenvim#install(0)" },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      keymaps = {
        ["<C-p>"] = false,
      },
      watch_for_changes = true,
    },
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
}
