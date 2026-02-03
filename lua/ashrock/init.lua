require("ashrock.set")
require("ashrock.lazy_init")
require("ashrock.remap")
require("ashrock.autosync")
require("ashrock.bufonly")

vim.cmd("colorscheme tokyonight-night")
-- vim.cmd("colorscheme zenbones")

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
      end, 100)
    end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "gh", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    if vim.lsp.get_client_by_id(e.data.client_id).server_capabilities.documentFormattingProvider then
      -- ESLint/Prettier 가용성 확인
      local has_eslint = vim.fn.executable('eslint') == 1 or
          #vim.lsp.get_active_clients({ name = "eslint" }) > 0 or
          #vim.lsp.get_active_clients({ name = "eslintls" }) > 0
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
