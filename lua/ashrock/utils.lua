local M = {}

-- Check if ESLint is available (executable or LSP client)
function M.is_eslint_available()
  local eslint_clients = vim.lsp.get_clients({ name = "eslint" })
  local eslintls_clients = vim.lsp.get_clients({ name = "eslintls" })
  
  return vim.fn.executable('eslint') == 1
      or #eslint_clients > 0
      or #eslintls_clients > 0
end

return M
