local function goyo_enter()
  vim.fn.system('tmux set status off')
  vim.opt_local.linebreak = true
end

local function goyo_leave()
  vim.fn.system('tmux set status on')
  vim.opt_local.linebreak = false
end

vim.api.nvim_create_autocmd("User", {
  pattern = "GoyoEnter",
  callback = goyo_enter,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "GoyoLeave",
  callback = goyo_leave,
})
