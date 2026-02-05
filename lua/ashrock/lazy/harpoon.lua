local config = require("ashrock.config")

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<leader>a",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Harpoon add file",
    },
    {
      "<C-e>",
      function()
        local harpoon = require("harpoon")
        local toggle_opts = {
          border = "rounded",
          title_pos = "center",
          ui_width_ratio = 1,
        }
        harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
      end,
      desc = "Harpoon toggle menu",
    },
    {
      "<leader>1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon file 1",
    },
    {
      "<leader>2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon file 2",
    },
    {
      "<leader>3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon file 3",
    },
    {
      "<leader>4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon file 4",
    },
    {
      "<leader>5",
      function()
        require("harpoon"):list():select(5)
      end,
      desc = "Harpoon file 5",
    },
    {
      "<leader>6",
      function()
        require("harpoon"):list():select(6)
      end,
      desc = "Harpoon file 6",
    },
    {
      "<leader>7",
      function()
        require("harpoon"):list():select(7)
      end,
      desc = "Harpoon file 7",
    },
    {
      "<leader>8",
      function()
        require("harpoon"):list():select(8)
      end,
      desc = "Harpoon file 8",
    },
    {
      "<C-S-P>",
      function()
        require("harpoon"):list():prev()
      end,
      desc = "Harpoon previous",
    },
    {
      "<C-S-N>",
      function()
        require("harpoon"):list():next()
      end,
      desc = "Harpoon next",
    },
  },
  config = function()
    require("harpoon"):setup()
  end,
}
