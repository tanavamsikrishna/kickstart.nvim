return {
  -- Linting
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    -- lint.linters.taplo = {
    --   name = 'taplo',
    --   cmd = 'taplo',
    --   stdin = true,
    --   args = { 'check', '--colors', 'never', '--default-schema-catalogs', '-' },
    --   stream = 'stderr',
    --   ignore_exitcode = false, -- set this to true if the linter exits with a code != 0 and that's considered normal.
    --   -- parser = your_parse_function,
    -- }

    lint.linters_by_ft = {
      -- markdown = { 'markdownlint' },
      lua = { 'luacheck' },
      dockerfile = { 'hadolint' },
      json5 = { 'json5' },
      json = { 'jsonlint' },
      python = { 'ruff' },
    }

    -- Create autocommand which carries out the actual linting
    -- on the specified events.
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Only run the linter in buffers that you can modify in order to
        -- avoid superfluous noise, notably within the handy LSP pop-ups that
        -- describe the hovered symbol using Markdown.
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
