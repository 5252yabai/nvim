require("fidget").setup({})

vim.diagnostic.config({
  virtual_text = true,
  jump = { float = true },
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
})
