local M = {}

-- Check if EslintFixAll command is actually registered (requires eslint LSP client attached)
function M.is_eslint_available()
  return vim.fn.exists(':EslintFixAll') == 2
end

return M
