vim.g.mapleader = ' '

vim.opt.termguicolors = true
vim.opt.nu = true
vim.opt.rnu = true
vim.opt.si = true
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.g.netrw_banner = 0
vim.opt.ruler = false
vim.opt.cursorline = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw|oil",
  callback = function()
    vim.opt_local.relativenumber = true
    vim.opt_local.number = true
  end,
})
