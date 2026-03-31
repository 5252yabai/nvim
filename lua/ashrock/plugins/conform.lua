local M = {}

local loaded = false

function M.ensure()
  if loaded then return end
  loaded = true
  vim.cmd.packadd("conform.nvim")
  require("conform").setup({
    formatters_by_ft = {
      javascript = { "biome", "prettier", stop_after_first = true },
      javascriptreact = { "biome", "prettier", stop_after_first = true },
      typescript = { "biome", "prettier", stop_after_first = true },
      typescriptreact = { "biome", "prettier", stop_after_first = true },
      json = { "biome", "prettier", stop_after_first = true },
      jsonc = { "biome", "prettier", stop_after_first = true },
    },
    formatters = {
      biome = {
        condition = function(self, ctx)
          return vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.filename, upward = true })[1]
        end,
      },
    },
  })
end

-- BufWritePre autocmd로 lazy load + 자동 포맷
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if not vim.tbl_contains({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, ft) then
      return
    end

    M.ensure()

    -- ESLint가 사용 가능한지 확인하고 먼저 실행
    local utils = require('ashrock.utils')
    local eslint_available = utils.is_eslint_available()

    if eslint_available then
      vim.cmd.EslintFixAll()
    end

    require("conform").format({
      bufnr = args.buf,
      timeout_ms = 500,
      lsp_format = "fallback",
    })
  end,
})

-- ConformInfo user command
vim.api.nvim_create_user_command("ConformInfo", function()
  M.ensure()
  vim.cmd("ConformInfo")
end, {})

return M
