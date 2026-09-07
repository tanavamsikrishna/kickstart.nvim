--- Sticky context header showing the enclosing function/class at the top of the window.
--- Currently disabled (`enable = false`). When on, shows at most 5 lines.

local opts = {
  enable = false,
  max_lines = 5,
  multiline_threshold = 1,
}

return {
  'nvim-treesitter/nvim-treesitter-context',
  branch = 'master',
  opts = opts,
}
