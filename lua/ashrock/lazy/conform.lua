return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      javascript = { "biome", "prettier", stop_after_first = true },
      javascriptreact = { "biome", "prettier", stop_after_first = true },
      typescript = { "biome", "prettier", stop_after_first = true },
      typescriptreact = { "biome", "prettier", stop_after_first = true },
      json = { "biome", "prettier", stop_after_first = true },
      jsonc = { "biome", "prettier", stop_after_first = true },
    },
    -- Biome 포매터 설정
    formatters = {
      biome = {
        condition = function(self, ctx)
          -- biome.json 또는 biome.jsonc 파일이 있는지 확인
          return vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.filename, upward = true })[1]
        end,
      },
    },
    -- 저장 시 자동 포매팅 (conform 권장 방식)
    format_on_save = function(bufnr)
      -- JS/TS 파일만 자동 포매팅
      local ft = vim.bo[bufnr].filetype
      if not vim.tbl_contains({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, ft) then
        return
      end

      -- ESLint가 사용 가능한지 확인하고 먼저 실행
      local utils = require('ashrock.utils')
      local eslint_available = utils.is_eslint_available()

      if eslint_available then
        vim.cmd.EslintFixAll()
      end

      return {
        timeout_ms = 500,
        lsp_format = "fallback",
      }
    end,
  },
}
