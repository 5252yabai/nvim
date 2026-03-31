local M = {}
local config = require("ashrock.config")

function M.on_attach(e)
  local opts = { buffer = e.buf }

  vim.keymap.set("n", "gd", function()
    local cur_pos = vim.api.nvim_win_get_cursor(0)
    local cur_buf = vim.api.nvim_get_current_buf()
    vim.lsp.buf.definition()
    vim.defer_fn(function()
      local new_pos = vim.api.nvim_win_get_cursor(0)
      local new_buf = vim.api.nvim_get_current_buf()
      if cur_buf == new_buf and cur_pos[1] == new_pos[1] and cur_pos[2] == new_pos[2] then
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
end

return M
