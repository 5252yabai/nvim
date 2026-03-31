require("ashrock.lsp.servers")

local keymaps = require("ashrock.lsp.keymaps")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(e)
    keymaps.on_attach(e)
  end,
})
