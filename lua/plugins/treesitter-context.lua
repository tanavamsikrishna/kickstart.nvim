local opts = {
  enable = true,
  max_lines = 5,
  multiline_threshold = 1,
}

return {
  'nvim-treesitter/nvim-treesitter-context',
  branch = 'master',
  opts = opts,
}
