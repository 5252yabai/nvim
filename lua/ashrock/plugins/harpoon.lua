local loaded = false

local function ensure()
  if loaded then return end
  loaded = true
  vim.cmd.packadd("harpoon")
  require("harpoon"):setup()
end

vim.keymap.set("n", "<leader>a", function()
  ensure()
  require("harpoon"):list():add()
end, { desc = "Harpoon add file" })

vim.keymap.set("n", "<C-e>", function()
  ensure()
  local harpoon = require("harpoon")
  local toggle_opts = {
    border = "rounded",
    title_pos = "center",
    ui_width_ratio = 1,
  }
  harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
end, { desc = "Harpoon toggle menu" })

for i = 1, 8 do
  vim.keymap.set("n", "<leader>" .. i, function()
    ensure()
    require("harpoon"):list():select(i)
  end, { desc = "Harpoon file " .. i })
end

vim.keymap.set("n", "<C-S-P>", function()
  ensure()
  require("harpoon"):list():prev()
end, { desc = "Harpoon previous" })

vim.keymap.set("n", "<C-S-N>", function()
  ensure()
  require("harpoon"):list():next()
end, { desc = "Harpoon next" })
