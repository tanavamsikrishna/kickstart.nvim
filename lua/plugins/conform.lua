--- Buffer formatting via conform.nvim: format-on-save and `<localleader>f`.
---
--- Filetype → formatter map lives in this file. Falls back to LSP format when no
--- formatter is configured. Skips when `vim.g.disable_autoformat` or
--- `vim.b.disable_autoformat` is set (Marimo `.py` notebooks set the buffer flag
--- automatically). CSS/JS/TS use `vim.g.frontend_file_formatter` or `biome-check`.
--- Nushell uses `nu-formatter.sh` from PATH. Markdown mdformat wraps at 80.

-- Disable formatting for Marimo notebooks
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

--- Frontend file formatter override.
--- Set `vim.g.frontend_file_formatter` to a formatter name (e.g. 'prettierd')
--- to use it for css, javascript, and typescript files.
--- Defaults to 'biome-check' when unset or nil.
local function frontend_formatter()
  return { vim.g.frontend_file_formatter or 'biome-check' }
end

---@module 'conform'
---@type conform.setupOpts
local opts = {
  notify_on_error = true,
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    return { lsp_format = 'fallback' }
  end,
  formatters = {
    nu_formatter = {
      command = 'nu-formatter.sh',
    },
    json5 = {
      command = 'json5',
      args = { '--space', '2' },
    },
    dockerfmt = {
      command = 'dockerfmt',
    },
    mdformat = {
      command = 'mdformat',
      args = { '--number', '--wrap', '80', '-' },
    },
  },
  formatters_by_ft = {
    css = frontend_formatter,
    dockerfile = { 'dockerfmt' },
    fish = { 'fish_indent' },
    html = { 'prettierd' },
    javascript = frontend_formatter,
    json = { 'biome-check' },
    json5 = { 'json5' },
    lisp = { 'cljfmt' },
    lua = { 'stylua' },
    markdown = { 'mdformat' },
    nu = { 'nu_formatter' },
    python = { 'ruff_fix', 'ruff_organize_imports', 'ruff_format' },
    toml = { 'tombi' },
    typescript = frontend_formatter,
    xml = { 'xmllint' },
    yaml = { 'yamlfmt' },
  },
  stop_after_first = true,
}

---@module 'lazy'
---@type LazyPluginSpec
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = opts,
  keys = {
    {
      '<localleader>f',
      function() require('conform').format { async = true, lsp_format = 'fallback' } end,
      desc = 'Format current buffer',
    },
  },
}
