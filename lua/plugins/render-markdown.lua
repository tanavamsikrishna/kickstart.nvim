---@param ctx render.md.handler.Context
---@return render.md.Mark[]
local function conceal_escape(ctx)
  local marks = {} ---@type render.md.Mark[]
  local query = vim.treesitter.query.parse('markdown_inline', '(backslash_escape) @escape')
  for _, node in query:iter_captures(ctx.root, ctx.buf) do
    local start_row, start_col, end_row = node:range()
    marks[#marks + 1] = {
      conceal = true,
      start_row = start_row,
      start_col = start_col,
      opts = {
        end_row = end_row,
        end_col = start_col + 1,
        conceal = '',
      },
    }
  end
  return marks
end

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
    '3rd/image.nvim',
  },
  ft = { 'markdown', 'quarto', 'rmd' }, -- lazy-load (optional but good)
  config = function()
    require('render-markdown').setup {
      -- Only render in normal/command/terminal modes → cleaner in insert
      -- (default is already {'n','c','t'}, but explicitly keeping for clarity)
      render_modes = { 'n', 'c', 't' },

      -- Reduce visual noise: disable sign column indicators
      -- (headings/code get no left signs)
      heading = {
        sign = false,
        width = 'block',
        right_pad = 1,
      },

      -- Make code blocks less distracting: no full background unless needed
      code = {
        sign = false,
        width = 'block', -- or 'full' if you prefer; 'block' is narrower/cleaner
      },

      max_file_size = 1.0, -- in MB (default is 10.0)

      -- If you later want images: add { '3rd/image.nvim' } to deps and enable below
      html = { enabled = true }, -- for <img> tags if using image.nvim

      completions = { lsp = { enabled = true } },
      custom_handlers = {
        markdown_inline = { extends = true, parse = conceal_escape },
      },
    }
  end,
}
