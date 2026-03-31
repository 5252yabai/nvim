return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("ashrock.lsp")
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "markdown_oxide" },
        automatic_enable = true,
      })
    end,
  },
}
