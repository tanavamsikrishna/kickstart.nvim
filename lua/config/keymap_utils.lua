local M = {}

---Capture the current mapping for lhs/mode and return a callable runner.
---@param lhs string
---@param mode? string
---@return fun()
function M.capture_map_runner(lhs, mode)
  local mapping = vim.fn.maparg(lhs, mode or 'n', false, true)

  return function()
    if vim.tbl_isempty(mapping) then return end

    if type(mapping.callback) == 'function' then
      mapping.callback()
      return
    end

    if mapping.rhs and mapping.rhs ~= '' then
      local keys = vim.api.nvim_replace_termcodes(mapping.rhs, true, true, true)
      local feed_mode = mapping.noremap == 1 and 'n' or 'm'
      vim.api.nvim_feedkeys(keys, feed_mode, false)
    end
  end
end

return M
