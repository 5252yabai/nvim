return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "markdown_oxide" },
        automatic_installation = true
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities
          })
        end,
        ["omnisharp"] = function() end,
        ["ts_ls"] = function()
          require("lspconfig").ts_ls.setup({
            root_dir = require("lspconfig").util.root_pattern({ "package.json", "tsconfig.json" }),
            single_file_support = false,
            settings = {},
          })
        end,
        ["denols"] = function()
          require("lspconfig").denols.setup({
            root_dir = require("lspconfig").util.root_pattern({ "deno.json", "deno.jsonc" }),
            single_file_support = false,
            settings = {},
          })
        end,
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = {
                  globals = { "vim", "it", "describe", "before_each", "after_each" }
                }
              }
            }
          })
        end,
        ["markdown_oxide"] = function()
          local oxide_capabilities = vim.tbl_deep_extend(
            'force',
            capabilities,
            {
              workspace = {
                didChangeWatchedFiles = {
                  dynamicRegistration = true,
                },
              },
            }
          )
          require("lspconfig").markdown_oxide.setup({
            capabilities = oxide_capabilities,
          })
        end,
      })
    end
  }
}
