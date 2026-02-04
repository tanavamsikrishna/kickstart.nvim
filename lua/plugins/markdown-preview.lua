return {
  'iamcco/markdown-preview.nvim',
  enabled = false,
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = 'zsh -c "cd app && bunx yarn install && cd .. && git checkout ."',
  init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
  ft = { 'markdown' },
}
