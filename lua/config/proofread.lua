local M = {}

local session_id = 0

local diff_fn = vim.text.diff

--- Opens an inline diff to preview changes.
--- @param original_buf number The buffer where text originated.
--- @param s_row number Start row (0-indexed).
--- @param e_row number End row (0-indexed).
--- @param original_lines string[] The original text lines.
--- @param replacement_lines string[] The suggested text lines.
local function show_diff(original_buf, s_row, e_row, original_lines, replacement_lines)
  session_id = session_id + 1

  local orig_text = table.concat(original_lines, '\n') .. '\n'
  local new_text = table.concat(replacement_lines, '\n') .. '\n'

  -- Generate unified diff string with alignment
  local diff = diff_fn(orig_text, new_text, { ctxlen = 3, linematch = 60 })
  if not diff or diff == '' then
    vim.notify('Proofread: No changes suggested', vim.log.levels.INFO)
    return
  end

  -- Create scratch buffer for the inline diff view
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'diff'
  vim.api.nvim_buf_set_name(buf, 'Proofread Preview://' .. session_id)

  ---@cast diff string
  local diff_lines = vim.split(diff:gsub('\n$', ''), '\n', { plain = true })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, diff_lines)

  -- Add character-level highlights for adjacent deletions/additions
  local ns = vim.api.nvim_create_namespace 'proofread_diff'

  -- Define custom intense red/green highlights for the fine-grained diffs
  vim.api.nvim_set_hl(0, 'ProofreadDiffDelete', { bg = '#8A1F1F', fg = '#FFFFFF', default = true })
  vim.api.nvim_set_hl(0, 'ProofreadDiffAdd', { bg = '#1F6B33', fg = '#FFFFFF', default = true })

  for i = 1, #diff_lines - 1 do
    local line1 = diff_lines[i]
    local line2 = diff_lines[i + 1]
    if line1:sub(1, 1) == '-' and line2:sub(1, 1) == '+' then
      local s1 = line1:sub(2)
      local s2 = line2:sub(2)

      -- Split into bytes (one per line) to let vim.diff perform exact character-level diffing
      local s1_nl = s1:gsub('.', '%1\n')
      local s2_nl = s2:gsub('.', '%1\n')

      local indices = diff_fn(s1_nl, s2_nl, { result_type = 'indices', algorithm = 'minimal' })
      if type(indices) == 'table' then
        for _, hunk in ipairs(indices) do
          local start_a, count_a, start_b, count_b = hunk[1], hunk[2], hunk[3], hunk[4]

          -- start_a exactly matches the 0-indexed column in the line
          -- because of the prepended '-' or '+'
          if count_a > 0 then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, start_a, {
              end_col = start_a + count_a,
              hl_group = 'ProofreadDiffDelete',
            })
          end
          if count_b > 0 then
            vim.api.nvim_buf_set_extmark(buf, ns, i, start_b, {
              end_col = start_b + count_b,
              hl_group = 'ProofreadDiffAdd',
            })
          end
        end
      end
    end
  end

  -- Open in a new tab using sbuffer to avoid creating a leaked [No Name] buffer
  vim.cmd('tab sbuffer ' .. buf)

  vim.b[buf].proofread_instructions = 'Press <CR> to Apply, <Esc> to Cancel'

  local function close_diff() vim.cmd 'tabclose' end

  local function apply_changes()
    if vim.api.nvim_buf_is_valid(original_buf) then
      vim.api.nvim_buf_set_lines(original_buf, s_row, e_row + 1, false, replacement_lines)
      vim.notify 'Proofread changes applied'
    end
    close_diff()
  end

  vim.keymap.set('n', '<CR>', apply_changes, { buffer = buf, desc = 'Apply proofread changes' })
  vim.keymap.set('n', '<Esc>', close_diff, { buffer = buf, desc = 'Cancel proofread' })
  vim.keymap.set('n', 'q', close_diff, { buffer = buf, desc = 'Cancel proofread' })
end

--- Proofread the selected text or the current line.
--- @param opts table Command options (line1, line2, range)
function M.proofread(opts)
  local original_buf = vim.api.nvim_get_current_buf()
  local s_row = opts.line1 - 1
  local e_row = opts.line2 - 1

  local original_lines = vim.api.nvim_buf_get_lines(original_buf, s_row, e_row + 1, false)
  local text = table.concat(original_lines, '\n')

  if text == '' then return end

  -- Try to use fidget for a progress spinner if available
  local progress_handle
  local has_fidget, fidget_progress = pcall(require, 'fidget.progress')
  if has_fidget then
    progress_handle = fidget_progress.handle.create {
      title = 'Proofread',
      message = 'Requesting corrections...',
      lsp_client = { name = 'LLM' },
    }
  else
    vim.notify('Proofread: Requesting corrections...', vim.log.levels.INFO)
  end

  vim.system({ 'proofread' }, { stdin = text }, function(obj)
    vim.schedule(function()
      if progress_handle then progress_handle:finish() end

      if obj.code ~= 0 then
        vim.notify('Proofread failed: ' .. (obj.stderr or 'unknown error'), vim.log.levels.ERROR)
        return
      end

      if not obj.stdout or obj.stdout == '' then
        vim.notify('Proofread returned empty output', vim.log.levels.WARN)
        return
      end

      local ok, decoded = pcall(vim.json.decode, obj.stdout)
      if not ok then
        vim.notify('Failed to parse proofread output: ' .. obj.stdout, vim.log.levels.ERROR)
        return
      end

      local replacement = decoded.text
      if replacement then
        local replacement_lines = vim.split(replacement:gsub('\n$', ''), '\n', { plain = true })
        show_diff(original_buf, s_row, e_row, original_lines, replacement_lines)
      end
    end)
  end)
end

vim.api.nvim_create_user_command('Proofread', M.proofread, {
  range = true,
  desc = 'Proofread selected text and show diff before applying',
})

return M
