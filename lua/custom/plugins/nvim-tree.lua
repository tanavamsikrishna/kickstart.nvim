local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5 -- You can change this too

---@type nvim_tree.config
local nvim_tree_config = {
  filters = { dotfiles = true, custom = { '__marimo__', '__pycache__' } },
  git = { enable = false },
  on_attach = function(bufnr)
    local api = require 'nvim-tree.api'
    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    local opts = function(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    vim.keymap.set('n', 'd', api.fs.trash, opts 'Trash')

    -- Removing dangerous/unwanted key mappings
    local keys_to_delete = { 'D', '<Del>', 'bd' }
    for _, key_to_delete in ipairs(keys_to_delete) do
      vim.keymap.del('n', key_to_delete, { buffer = bufnr })
    end
  end,
  view = {
    float = {
      enable = true,
      open_win_config = function()
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * WIDTH_RATIO
        local window_h = screen_h * HEIGHT_RATIO
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
        return {
          border = 'rounded',
          relative = 'editor',
          row = center_y,
          col = center_x,
          width = window_w_int,
          height = window_h_int,
        }
      end,
    },
  },
}

return {
  'nvim-tree/nvim-tree.lua',
  lazy = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  opts = nvim_tree_config,
  keys = {
    { '\\', ':NvimTreeToggle<CR>', desc = 'NvimTree reveal', silent = true },
  },
  config = function(_, opts)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    require('nvim-tree').setup(opts)
  end,
}
