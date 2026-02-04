return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons', '3rd/image.nvim' },
  ft = { 'markdown', 'quarto', 'rmd' }, -- lazy-load (optional but good)
  config = function()
    require('render-markdown').setup {
      -- Only render in normal/command/terminal modes → cleaner in insert
      -- (default is already {'n','c','t'}, but explicitly keeping for clarity)
      render_modes = { 'n', 'c', 't' },

      -- Reduce visual noise: disable sign column indicators (headings/code get no left signs)
      heading = {
        sign = false,
        width = 'block',
        right_pad = 1,
      },

      -- Make code blocks less distracting: no full background unless needed
      code = {
        sign = false,
        width = 'block', -- or 'full' if you prefer; 'block' is narrower/cleaner
        border = 'thin', -- subtle border instead of default 'hide' or full
        left_pad = 1,
        right_pad = 1,
      },

      max_file_size = 1.5, -- in MB (default is 10.0)

      -- If you later want images: add { '3rd/image.nvim' } to deps and enable below
      html = { enabled = true }, -- for <img> tags if using image.nvim
    }
  end,
}
