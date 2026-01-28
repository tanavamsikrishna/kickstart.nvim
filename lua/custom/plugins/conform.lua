return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
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
      javascript = { 'prettierd', 'prettier' },
      json = { 'prettierd' },
      json5 = { 'json5' },
      lua = { 'stylua' },
      nu = { 'topiary_nushell' },
      python = { 'ruff_organize_imports', 'ruff_format' },
      toml = { 'taplo' },
      yaml = { 'yamlfmt' },
    },
    stop_after_first = true,
  },
}
