--- Async linting via nvim-lint on enter, write, and text-change events.
---
--- Per-filetype linters: luacheck, hadolint, jsonlint/json5, eslint_d
--- (js/ts/svelte), yamllint. Python lint comes from the ruff LSP, not here.
--- Only runs in modifiable buffers. Sets `ESLINT_D_PPID` so eslint_d tracks
--- this Neovim process.

return {
  -- Linting
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    vim.env.ESLINT_D_PPID = vim.fn.getpid()

    lint.linters_by_ft = {
      -- markdown = { 'markdownlint' },
      lua = { 'luacheck' },
      dockerfile = { 'hadolint' },
      json5 = { 'json5' },
      json = { 'jsonlint' },
      svelte = { 'eslint_d' },
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      yaml = { 'yamllint' },
    }

    -- Create autocommand which carries out the actual linting
    -- on the specified events.
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({
      'BufEnter',
      'BufWritePost',
      'InsertLeave',
      'FileChangedShellPost',
      'TextChanged',
    }, {
      group = lint_augroup,
      callback = function()
        -- Only run the linter in buffers that you can modify in order to
        -- avoid superfluous noise, notably within the handy LSP pop-ups that
        -- describe the hovered symbol using Markdown.
        if vim.bo.modifiable then lint.try_lint() end
      end,
    })
  end,
}
