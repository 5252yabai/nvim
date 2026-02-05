local M = {}

M.cache_timeout = 300
M.git_sync_interval = 60000
M.format_timeout = 500
M.lsp_defer_delay = 100
M.harpoon_slots = 8
M.texts_path = vim.fn.expand("~/texts")
M.colorscheme = "tokyonight-night"

return M
