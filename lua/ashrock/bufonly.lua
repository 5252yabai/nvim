local function close_other_bufs()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and buf ~= current_buf then
      vim.cmd.bdelete(buf)
    end
  end
end

vim.api.nvim_create_user_command('BufOnly', close_other_bufs, {})
