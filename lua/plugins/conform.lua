vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.py',
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 5, false)
    for _, line in ipairs(lines) do
      if line:match 'app = marimo.App' then
        vim.b.disable_autoformat = true
        break
      end
    end
  end,
})

---@module 'conform'
---@type conform.setupOpts
local opts = {
  notify_on_error = true,
  format_on_save = function(bufnr)
    if vim.b[bufnr].disable_autoformat then return end
    return { lsp_format = 'fallback' }
  end,
  formatters = {
    topiary_nushell = {
      command = os.getenv 'SCRIPTS_FOLDER' .. '/bin/format.nu',
    },
    json5 = {
      command = 'json5',
      args = { '--space', '2' },
    },
    dockerfmt = {
      command = 'dockerfmt',
    },
  },
  formatters_by_ft = {
    css = { 'prettierd' },
    dockerfile = { 'dockerfmt' },
    fish = { 'fish_indent' },
    html = { 'prettierd' },
    javascript = { 'prettierd' },
    typescript = { 'prettierd' },
    json = { 'prettierd' },
    json5 = { 'json5' },
    lua = { 'stylua' },
    nu = { 'topiary_nushell' },
    python = { 'ruff_organize_imports', 'ruff_format' },
    toml = { 'tombi' },
    yaml = { 'yamlfmt' },
  },
  stop_after_first = true,
}

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = opts,
}
