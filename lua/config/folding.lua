vim.opt.foldmethod = 'manual'
vim.opt.foldlevel = 99

local function smart_toggle_fold()
  -- 1. Try standard fold toggle first (pcall required to avoid "No fold found" error)
  local ok = pcall(function() vim.cmd 'normal! za' end)
  if ok then return end

  -- 2. Native Treesitter Parser Check (Blow up if TS is broken)
  local _ = vim.treesitter.get_parser(0)

  -- 3. Native Node Check
  local node = vim.treesitter.get_node()
  if not node then return vim.notify('No Treesitter node found at cursor', vim.log.levels.WARN) end

  -- 4. Traverse up the tree
  while node do
    local start_row, _, end_row, _ = node:range()

    if end_row > start_row then
      local range = string.format('%d,%dfold', start_row + 1, end_row + 1)

      -- Create fold (Will error if fails)
      vim.cmd(range)
      vim.cmd 'normal! zc'

      -- Force Save (Will error if file is read-only/invalid)
      vim.cmd 'mkview!'
      return
    end

    node = node:parent()
  end

  vim.notify('No foldable block found here', vim.log.levels.INFO)
end

vim.keymap.set('n', 'za', smart_toggle_fold, { desc = 'Toggle fold or create TS fold manually' })
