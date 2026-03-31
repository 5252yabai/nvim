local loaded = false

local function ensure()
  if loaded then return end
  loaded = true
  vim.cmd.packadd("telescope.nvim")
  require("telescope").setup({
    defaults = {
      path_display = { "truncate" },
    },
  })
end

vim.keymap.set("n", "<leader>pf", function()
  ensure()
  require("telescope.builtin").find_files()
end, { desc = "Telescope find files" })

vim.keymap.set("n", "<leader>ps", function()
  ensure()
  require("telescope.builtin").live_grep()
end, { desc = "Telescope live grep" })

vim.keymap.set("n", "<C-p>", function()
  ensure()
  require("telescope.builtin").git_files()
end, { desc = "Telescope find git files" })
