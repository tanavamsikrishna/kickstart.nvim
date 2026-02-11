return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = function()
    local harpoon = require 'harpoon'
    return {
      { '<leader>ja', function() harpoon:list():add() end, desc = 'Add to harpoon' },
      { '<leader>jb', function() harpoon:list():remove() end, desc = 'Delete from harpoon' },
      { '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end },
      { '<C-S-p>', function() harpoon:list():prev() end },
      { '<C-S-n>', function() harpoon:list():next() end },
    }
  end,
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()
  end,
}
