return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- 1. mason 먼저 setup
      require("mason").setup()

      -- 2. lspconfig.setup()으로 각 서버 직접 설정 (cmd/filetypes 자동 포함)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      local utils = require("ashrock.utils")
      local config = require("ashrock.config")

      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json"),
        single_file_support = false,
      })

      lspconfig.denols.setup({
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
        single_file_support = false,
      })

      lspconfig.lua_ls.setup({
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

      lspconfig.markdown_oxide.setup({
        capabilities = vim.tbl_deep_extend('force', capabilities, {
          workspace = {
            didChangeWatchedFiles = { dynamicRegistration = true },
          },
        }),
      })

      -- 3. LspAttach autocmd (키맵, 포맷팅)
      vim.api.nvim_create_autocmd('LspAttach', {
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

          if vim.lsp.get_client_by_id(e.data.client_id).server_capabilities.documentFormattingProvider then
            local has_eslint = utils.is_eslint_available()
            local has_prettier = vim.fn.executable('prettier') == 1

            if not (has_eslint or has_prettier) then
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = e.buf,
                callback = function()
                  vim.lsp.buf.format { async = false, id = e.data.client_id }
                end,
              })
            end
          end
        end
      })

      -- 4. mason-lspconfig: 설치만 담당 (automatic_enable 비활성화)
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "markdown_oxide" },
        automatic_enable = false,
      })
    end
  }
}
