-- Basic editor commands
vim.cmd("command W w")
vim.cmd("command Q q")

-- Movement and selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])

-- Quickfix navigation
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz")

-- Git related
vim.keymap.set("n", "gh", "<cmd>diffget //2<CR>")
vim.keymap.set("n", "gl", "<cmd>diffget //3<CR>")
vim.keymap.set("n", "<leader>gs", function()
  vim.cmd.Git()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>o", true, false, true), "n", true)
end)

-- Code formatting function
local function format_code()
  -- ESLint가 사용 가능한지 확인
  local eslint_available = vim.fn.executable('eslint') == 1 or
                          #vim.lsp.get_active_clients({ name = "eslint" }) > 0 or
                          #vim.lsp.get_active_clients({ name = "eslintls" }) > 0

  if eslint_available then
    vim.cmd.EslintFixAll()
  end

  -- conform.nvim을 사용하여 포매팅 (Biome 또는 Prettier)
  require("conform").format({
    lsp_fallback = true,
    async = true,
    timeout_ms = 500,
  })
end

-- Manual formatting shortcut
vim.keymap.set('n', '<leader>pr', format_code)

-- Diagnostic
vim.keymap.set("n", "<leader>e", function()
  vim.diagnostic.setqflist()
end)

-- File operations
vim.keymap.set('n', '<leader>fn', function()
  vim.fn.setreg('+', vim.fn.expand('%:t'))
end, { noremap = true, silent = true })

-- Random file opener
local function OpenRandomFileInDir()
  local output = vim.fn.system('ls -p | grep -v /')
  local files = vim.split(output, '\n')
  if #files == 0 then
    print("No files in directory.")
    return
  end
  math.randomseed(os.time())
  local idx = math.random(#files)
  local file = files[idx]
  vim.cmd('edit ' .. file)
end
vim.keymap.set('n', '<leader>r', OpenRandomFileInDir)

-- Oil Project View
vim.keymap.set({ "n" }, "-", "<CMD>Oil<CR>", { noremap = true, silent = true, buffer = false })

vim.keymap.set("n", "<leader>.", vim.lsp.buf.code_action, { desc = "Quick fix / Code actions" })
