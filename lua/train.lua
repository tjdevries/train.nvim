-- TODO:
--  - Add ability to go to the match, and then "pop" back,
--      with all of the matches showing again.

-- Compat... {{{
package.loaded['train'] = nil

vim.fn = vim.fn or setmetatable({}, {
  __index = function(t, key)
    local function _fn(...)
      return vim.api.nvim_call_function(key, {...})
    end
    t[key] = _fn
    return _fn
  end
})
-- }}}

TrainMatchWindows = {}

local train = {}

function train.get_pulse_win_callback(timer, win_id, list_of_hls)
  local index = 0
  return vim.schedule_wrap(function()
    if not vim.api.nvim_win_is_valid(win_id) then
      timer:stop()
      timer:close()
      return
    end

    index = (index + 1) % #list_of_hls

    -- Unfortunate problem with 1 based arrays.
    if index == 0 then
      index = #list_of_hls
    end

    vim.api.nvim_win_set_option(
      win_id,
      'winhl',
      string.format('Normal:%s', list_of_hls[index])
    )
  end)
end

function train.clear_matches()
  for _, win_id in ipairs(TrainMatchWindows) do
    if vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, true)
    end
  end

  -- TODO: Clean this up later
  -- TrainMatchWindows = {}
end

--- Perform a motion and return new position.
function train.perform_motion(motion)
  local feedkey_mode = vim.fn['train#_opt_string']()

  -- TODO: Is there any time I should escape?
  --        How do I know when I should? Or is it just always.
  vim.api.nvim_feedkeys(motion, feedkey_mode, false)

  return vim.fn.getcurpos()
end

--- Make a floating window at the location for the position.
--- It should register it's floating window so we can clear it later.
function train.show_motion(resulting_positions, position, motion, pulse)
  -- TODO:
  --    Check if the windows scroll with you as you scroll.
  -- position  = [bufnum, lnum, col, off, curswant]

  -- Check if any resulting positions start in the same place.
  for _, existing_position in ipairs(resulting_positions) do
    if existing_position== position then
      return
    end

    if existing_position[2] == position[2] 
        and existing_position[3] == position[3] then
      return
    end
  end

  local row = position[2] - 1
  local col = position[3] - 1

  local window_opts = {
    relative = 'win',
    bufpos = {row, col},
    width = string.len(motion),
    height = 1,
    row = 0,
    col = 0,
    focusable = false,
    style = 'minimal',
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, {motion})

  local win_id = vim.api.nvim_open_win(buf, false, window_opts)
  -- TODO: Instead of just using error, you should do random ones
  vim.api.nvim_win_set_option(win_id, 'winhl', 'Normal:Error')

  table.insert(resulting_positions, position)
  table.insert(TrainMatchWindows, win_id)

  if pulse then
    local timer = vim.loop.new_timer()
    timer:start(
      500,
      1000,
      train.get_pulse_win_callback(timer, win_id, {"Error", "Function"})
      )
  end

  return win_id
end

--@param motions (table): List of motions to execute.
function train.show_matches(motions)
  train.clear_matches()

  local original_cursor = vim.fn.getcurpos()
  vim.fn['train#_cache_vim_option']('eventignore', 'all')

  -- Result of executing motions
  -- Names: potential_positions
  local resulting_positions = {}

  for _, motion in ipairs(motions) do
    -- Reset our cursor position
    vim.fn.setpos('.', original_cursor)

    local next_position = train.perform_motion(motion)
    train.show_motion(resulting_positions, next_position, motion, true)
  end

  vim.fn.setpos('.', original_cursor)
  vim.fn['train#_uncache_vim_option']('eventignore')

  -- TODO: Add all the autocmds you can think of here!
  vim.api.nvim_command [[autocmd CursorMoved,VimLeave,ExitPre,InsertEnter <buffer> ++once :lua require('train').clear_matches()]]
end

function TrainExample()
      require('train').show_matches({'w', '$', '0', 'gh', '0', '^'})
end

function OtherExample()
  -- example_win = {
  --    col = 1,
  --    focusable = false,
  --    height = 1,
  --    relative = "win",
  --    row = 17,
  --    style = "minimal",
  --    width = 1,
  --    bufpos = {1, 1} }

  -- motion = 'w'

  -- buf = vim.api.nvim_create_buf(false, true)
  -- vim.api.nvim_buf_set_lines(buf, 0, -1, true, {motion})
  -- vim.api.nvim_open_win(buf, false, example_win)
end

return train
