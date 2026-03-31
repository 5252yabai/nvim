local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = ok and cmp_nvim_lsp.default_capabilities() or nil

if capabilities then
  vim.lsp.config("*", { capabilities = capabilities })
end

local servers = {
  ts_ls = {
    root_markers = { "package.json", "tsconfig.json" },
    single_file_support = false,
  },
  denols = {
    root_markers = { "deno.json", "deno.jsonc" },
    single_file_support = false,
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
          globals = { "vim", "it", "describe", "before_each", "after_each" },
        },
      },
    },
  },
  markdown_oxide = {
    capabilities = capabilities
      and vim.tbl_deep_extend("force", capabilities, {
        workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
      })
      or nil,
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
end

vim.lsp.enable(vim.tbl_keys(servers))
