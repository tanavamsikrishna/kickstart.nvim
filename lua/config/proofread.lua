local M = {}

local session_id = 0

--- Opens a side-by-side diff to preview changes.
--- @param original_buf number The buffer where text originated.
--- @param s_row number Start row (0-indexed).
--- @param e_row number End row (0-indexed).
--- @param original_lines string[] The original text lines.
--- @param replacement_lines string[] The suggested text lines.
local function show_diff(original_buf, s_row, e_row, original_lines, replacement_lines)
  session_id = session_id + 1

  -- Create scratch buffers for the diff view
  local buf_orig = vim.api.nvim_create_buf(false, true)
  local buf_new = vim.api.nvim_create_buf(false, true)

  -- Ensure buffers are wiped when closed
  vim.bo[buf_orig].bufhidden = 'wipe'
  vim.bo[buf_new].bufhidden = 'wipe'

  vim.api.nvim_buf_set_lines(buf_orig, 0, -1, false, original_lines)
  vim.api.nvim_buf_set_lines(buf_new, 0, -1, false, replacement_lines)

  -- Set unique names to avoid collisions
  vim.api.nvim_buf_set_name(buf_orig, 'Original://' .. session_id)
  vim.api.nvim_buf_set_name(buf_new, 'Suggested://' .. session_id)

  -- Open side-by-side in a new tab to avoid messing with current layout
  vim.cmd 'tabnew'
  vim.api.nvim_win_set_buf(0, buf_orig)
  vim.cmd 'diffthis'

  vim.cmd 'split'
  vim.api.nvim_win_set_buf(0, buf_new)
  vim.cmd 'diffthis'

  -- Set some helpful buffer-local status information
  vim.b[buf_new].proofread_instructions = 'Press <CR> to Apply, <Esc> to Cancel'

  -- Map <CR> to apply and <Esc>/q to cancel in the new buffer
  local function close_diff() vim.cmd 'tabclose' end

  local function apply_changes()
    vim.api.nvim_buf_set_lines(original_buf, s_row, e_row + 1, false, replacement_lines)
    close_diff()
    vim.notify 'Proofread changes applied'
  end

  vim.keymap.set('n', '<CR>', apply_changes, { buffer = buf_new, desc = 'Apply proofread changes' })
  vim.keymap.set('n', '<Esc>', close_diff, { buffer = buf_new, desc = 'Cancel proofread' })
  vim.keymap.set('n', 'q', close_diff, { buffer = buf_new, desc = 'Cancel proofread' })

  -- Also map for the original buffer in the diff view
  vim.keymap.set('n', '<Esc>', close_diff, { buffer = buf_orig, desc = 'Cancel proofread' })
  vim.keymap.set('n', 'q', close_diff, { buffer = buf_orig, desc = 'Cancel proofread' })
end

--- Proofread the selected text or the current line.
--- @param opts table Command options (line1, line2, range)
function M.proofread(opts)
  local original_buf = vim.api.nvim_get_current_buf()
  local s_row = opts.line1 - 1
  local e_row = opts.line2 - 1

  local original_lines = vim.api.nvim_buf_get_lines(original_buf, s_row, e_row + 1, false)
  local text = table.concat(original_lines, '\n')

  if text == '' then
    return
  end

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
      if progress_handle then
        progress_handle:finish()
      end

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
        local replacement_lines = vim.split(replacement, '\n', { plain = true })
        if #replacement_lines > 1 and replacement_lines[#replacement_lines] == '' then
          table.remove(replacement_lines)
        end

        show_diff(original_buf, s_row, e_row, original_lines, replacement_lines)
      end
    end)
  end)
end

vim.api.nvim_create_user_command(
  'Proofread',
  function(opts) M.proofread(opts) end,
  { range = true, desc = 'Proofread selected text and show diff before applying' }
)

return M
