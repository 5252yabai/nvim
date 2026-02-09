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
      local utils = require("ashrock.utils")
      local config = require("ashrock.config")

      -- LSP Attach keymaps
      local autocmd = vim.api.nvim_create_autocmd
      autocmd('LspAttach', {
        callback = function(e)
          local opts = { buffer = e.buf }
          vim.keymap.set("n", "gd", function()
            local current_pos = vim.api.nvim_win_get_cursor(0)
            local current_buf = vim.api.nvim_get_current_buf()
            
            vim.lsp.buf.definition()
            
            vim.defer_fn(function()
              local new_pos = vim.api.nvim_win_get_cursor(0)
              local new_buf = vim.api.nvim_get_current_buf()
              
              -- 같은 위치라면 (이미 definition에 있음) references 표시
              if current_buf == new_buf and 
                 current_pos[1] == new_pos[1] and 
                 current_pos[2] == new_pos[2] then
                vim.lsp.buf.references()
              end
            end, config.lsp_defer_delay)
          end, opts)
          vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
          vim.keymap.set("n", "gh", function() vim.lsp.buf.hover() end, opts)
          vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
          vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
          vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
          vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
          vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
          -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

          if vim.lsp.get_client_by_id(e.data.client_id).server_capabilities.documentFormattingProvider then
            -- ESLint/Prettier 가용성 확인
            local has_eslint = utils.is_eslint_available()
            local has_prettier = vim.fn.executable('prettier') == 1

            -- ESLint나 Prettier가 없는 경우에만 LSP 포맷팅 활성화
            if not (has_eslint or has_prettier) then
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = e.buf,
                callback = function()
                  vim.lsp.buf.format { async = false, id = e.data.client_id }
                end,
              })
            end
          end
          -- vim.api.nvim_create_autocmd("BufWritePre", {
          --   pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
          --   callback = function()
          --     vim.cmd(":Prettier")
          --   end,
          -- })
        end
      })

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities
          })
        end,
        ["omnisharp"] = function() end,
        ["ts_ls"] = function()
          require("lspconfig").ts_ls.setup({
            capabilities = capabilities,
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
