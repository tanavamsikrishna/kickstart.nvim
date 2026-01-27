-- This file contains any temporary code used for debugging purposes

-- 1. Save the original notify function to avoid infinite loops
local original_notify = vim.notify

-- 2. Define your custom notify function
vim.notify = function(msg, level, opts)
  -- Define a log path (e.g., in Neovim's standard data directory)
  local log_path = string.format('%s/debug.log', vim.fn.stdpath 'cache')

  -- Format the log entry
  local datetime = os.date '%Y-%m-%d %H:%M:%S'
  local log_level = level or 'info'
  local log_msg = string.format('[%s] [%s] %s\n', datetime, log_level, msg)

  -- Append to the log file
  local fd = io.open(log_path, 'a')
  if fd then
    fd:write(log_msg)
    fd:close()
  end

  -- 3. Call the original notify function to show the message in the UI
  original_notify(msg, level, opts)
end
