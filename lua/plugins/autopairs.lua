--- Insert-mode auto-pairing of brackets, quotes, and similar delimiters (nvim-autopairs).
--- Loads on InsertEnter with plugin defaults; no custom rules or keymaps.

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {},
}
