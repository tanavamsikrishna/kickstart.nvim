--- Fold toggle: `za`, or create a manual fold spanning the Treesitter node.

vim.opt.foldmethod = 'manual'
vim.opt.foldlevel = 99

local viewoptions = require 'config.viewoptions'

local function smart_toggle_fold()
  -- 1. Try standard fold toggle first (pcall required to avoid "No fold found" error)
  local ok = pcall(function() vim.cmd 'normal! za' end)
  if ok then return end

  -- 2. Native Treesitter Parser Check (Blow up if TS is broken)
  local _ = vim.treesitter.get_parser(0)

  -- 3. Native Node Check
  local node = vim.treesitter.get_node()
  if not node then
    return vim.notify('No Treesitter node found at cursor', vim.log.levels.WARN)
  end

  -- 4. Traverse up the tree
  while node do
    local start_row, _, end_row, _ = node:range()

    if end_row > start_row then
      local range = string.format('%d,%dfold', start_row + 1, end_row + 1)

      -- Create fold (Will error if fails)
      vim.cmd(range)
      vim.cmd 'normal! zc'

      -- Persist only when a view file can be written. Other mkview failures
      -- still surface (read-only or invalid buffer).
      if viewoptions.should_persist(vim.api.nvim_buf_get_name(0)) then
        vim.cmd 'mkview!'
      end
      return
    end

    node = node:parent()
  end

  vim.notify('No foldable block found here', vim.log.levels.INFO)
end

vim.keymap.set(
  'n',
  'za',
  smart_toggle_fold,
  { desc = 'Toggle fold or create TS fold manually' }
)
