vim.pack.add({
  -- Dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/rktjmp/lush.nvim",

  -- Colorschemes (eager - startup 시 필요)
  "https://github.com/zenbones-theme/zenbones.nvim",
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/andreasvc/vim-256noir",
  "https://github.com/sainnhe/gruvbox-material",
  "https://github.com/yorumicolors/yorumi.nvim",
  "https://github.com/rebelot/kanagawa.nvim",
  "https://github.com/scottmckendry/cyberdream.nvim",

  -- UI
  "https://github.com/eoh-bse/minintro.nvim",
  "https://github.com/echasnovski/mini.icons",

  -- Core tools (eager)
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/prettier/vim-prettier",
  "https://github.com/mbbill/undotree",
  "https://github.com/junegunn/goyo.vim",
  "https://github.com/j-hui/fidget.nvim",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/theprimeagen/vim-be-good",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/glacambre/firenvim",

  -- LSP
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/williamboman/mason-lspconfig.nvim",

  -- Completion (eager)
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-cmdline",

  -- Treesitter
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },

  -- Deferred (lazy load)
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.8", load = false },
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2", load = false },
  { src = "https://github.com/stevearc/conform.nvim", load = false },
})

-- Build steps via PackChanged autocmd
vim.api.nvim_create_autocmd("User", {
  pattern = "PackChanged",
  callback = function()
    -- firenvim 설치 후 빌드
    vim.cmd(":call firenvim#install(0)")
  end,
})

-- Eager plugin configs
require("ashrock.plugins.minintro")
require("ashrock.plugins.autotag")
require("ashrock.plugins.oil")
require("ashrock.plugins.treesitter")
require("ashrock.plugins.diagnostics")
require("ashrock.plugins.completion")
require("ashrock.plugins.undotree")
require("ashrock.plugins.goyo")

-- LSP (mason → lsp → mason-lspconfig 순서)
require("mason").setup()
require("ashrock.lsp")
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "markdown_oxide" },
  automatic_enable = true,
})

-- Deferred plugin configs (lazy load shims)
require("ashrock.plugins.telescope")
require("ashrock.plugins.harpoon")
require("ashrock.plugins.conform")
