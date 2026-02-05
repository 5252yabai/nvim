local M = {}

-- Check if ESLint is available (executable or LSP client)
-- Compatible with both Neovim 0.9 (get_active_clients) and 0.10+ (get_clients)
function M.is_eslint_available()
  -- Use get_clients (Neovim 0.10+) with fallback to get_active_clients (0.9)
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  
  local eslint_clients = get_clients({ name = "eslint" })
  local eslintls_clients = get_clients({ name = "eslintls" })
  
  return vim.fn.executable('eslint') == 1
      or #eslint_clients > 0
      or #eslintls_clients > 0
end

return M
