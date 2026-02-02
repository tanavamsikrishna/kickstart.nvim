---@return string[] list of all needed parsers. The first one is the "main" parser
local function get_parsers(filetype)
  if filetype == 'svelte' then return { 'svelte', 'html', 'typescript', 'css', 'javascript', 'html_tags' } end
  local parser = vim.treesitter.language.get_lang(filetype) or filetype
  return { parser }
end

return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'main',
  config = function()
    vim.o.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    -- To install the required treesitter parsers on demand
    local ts_manager_group = vim.api.nvim_create_augroup('TreesitterManager', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = ts_manager_group,
      pattern = '*',
      callback = function(args)
        local bufnr = args.buf
        local ft = vim.bo[bufnr].filetype

        -- Ignore special buffers (Telescope, etc.)
        if ft == '' or vim.bo[bufnr].buftype ~= '' then return end

        -- Translate Filetype to Parser Name (e.g., help -> vimdoc)
        local parsers = get_parsers(ft)

        -- Skip list for common non-code or meta-filetypes
        local ignored_langs = { 'gitcommit', 'gitrebase', 'checkhealth', 'log' }
        if #parsers == 1 then
          for _, v in ipairs(ignored_langs) do
            if parsers[1] == v then return end
          end
        end

        -- Performance Check: Size Limit (1MB)
        local max_filesize = 1024 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max_filesize then return end

        -- Performance Check: Long Line Check (Minified files)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 100, false)
        for _, line in ipairs(lines) do
          if #line > 1000 then return end
        end

        -- Start the treesitter
        local async = require 'nvim-treesitter.async'
        local ts = require 'nvim-treesitter'
        async.arun(function()
          local installation_needed = vim.tbl_filter(
            function(parser) return not vim.treesitter.language.add(parser) end,
            parsers
          )
          if #installation_needed > 0 then async.await(ts.install(installation_needed)) end
          vim.tbl_map(vim.treesitter.language.add, installation_needed)
          vim.treesitter.start(bufnr, parsers[1])
        end)
      end,
    })
  end,
}
