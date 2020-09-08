-- TODO:
--  - Add ability to go to the match, and then "pop" back,
--      with all of the matches showing again.
--  - Read all the mappings you have that start w/ a pattern,
--      and show all of them.


-- Plan:
--  1. Just do what we doing already
--  2. Open a floating window.
--      70% of window is current buffer
--      20% is info section
--      cool borders and highlights to give visual cues of where u at
--      Immeidately closes on movement
--  3. Open
--      Same, but doesn't close immediately.
--  4. Full fzf preview
--      Opens fzf preview pane or similar
--      Runs all the movements
--      you can search for them by movement or name
--      you can see where you'd result in your buffer.

-- NOTE: Should check out easymotion and sneak to see what they're up to.

-- Pattern:
--  Pick some movements you want to learn
--  nnoremap <space>l :call train_show#matches(['(', ')', ...])<CR>

package.loaded['train'] = nil

-- Compat... {{{
local log = require('train.log')
local Motion = require('train.motion')
local t_window = require('train.window')

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

-- Leaving the global check because when I re-source this file, we lose the match windows
TrainMatchWindows = TrainMatchWindows or {}

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
      string.format('Normal:%s', list_of_hls[index].higroup)
    )
  end)
end

function train.clear_matches(original_win_id, mode)
  for _, win_id in ipairs(TrainMatchWindows) do
    if vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, true)
    end
  end

  if mode == 'one_shot' then
    if vim.api.nvim_win_is_valid(original_win_id) then
      vim.api.nvim_win_close(original_win_id, true)
    end
  end

  -- TODO: Clean this up later
  -- TrainMatchWindows = {}
end

--- Perform a motion and return new position.
--@arg win_id number: The window ID that we're in currently.
--@arg motion Motion: A Motion object.
function train.perform_motion(win_id, motion)
  local feedkey_mode = vim.fn['train#_opt_string']()

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(motion.movement, true, true, true),
    feedkey_mode,
    true
  )

  return vim.api.nvim_win_get_cursor(win_id)
end

--- Make a floating window at the location for the position.
--- It should register it's floating window so we can clear it later.
--@param cursor: result from nvim_win_get_cursor() (row, col)
function train.show_motion(win_id, resulting_cursors, cursor, motion, pulse)
  log.trace("show_motion | win_id: %s", win_id)
  log.trace("show_motion | win_id: %s", vim.fn.win_getid())

  -- TODO:
  --    Check if the windows scroll with you as you scroll.

  -- Check if any resulting positions start in the same place.
  for _, existing_cursor in ipairs(resulting_cursors) do
    if existing_cursor == cursor then
      return
    end

    if existing_cursor[1] == cursor[1]
        and existing_cursor[2] == cursor[2] then
      return
    end
  end

  local row = cursor[1] - 1
  local col = cursor[2]

  local win_position = vim.api.nvim_win_get_position(win_id)

  local use_buf_position = true
  local window_opts
  if use_buf_position then
    window_opts = {
      relative = 'win',
      win = win_id,
      bufpos = {row, col},
      width = string.len(motion.movement),
      height = 1,
      row = 0,
      col = 0,
      focusable = false,
      style = 'minimal',
    }
  else
    window_opts = {
      relative = 'editor',
      width = string.len(motion.movement),
      height = 1,
      row = win_position[1] + row,
      col = win_position[2] + col,
      focusable = false,
      style = 'minimal',
    }
  end
  log.trace("show_motion | resulting window_opts: %s", vim.inspect(window_opts))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, {motion.movement})

  local new_win_id = vim.api.nvim_open_win(buf, false, window_opts)
  -- TODO: Instead of just using error, you should do random ones
  vim.api.nvim_win_set_option(new_win_id, 'winhl', 'Normal:Error')

  table.insert(resulting_cursors, cursor)
  table.insert(TrainMatchWindows, new_win_id)

  if pulse then
    local timer = vim.loop.new_timer()
    timer:start(
      500,
      500,
      train.get_pulse_win_callback(timer, new_win_id, vim.g.train_highlight_pulses)
      )
  end

  return win_id
end

--@param motions (table): List of motions to execute.
--@param mode (string): Available modes are:
--                          'in_buffer': Don't do anything crazy
--                          'one_shot': Open up a floating window w/ docs.
--                                      One movements quits you out.
function train.show_matches(raw_motions, mode)
  -- vim.cmd [[set nomodifiable]]

  local motions = {}
  for _, v in ipairs(raw_motions) do
    table.insert(motions, Motion:new(v))
  end

  train.clear_matches()

  local win_id = vim.api.nvim_get_current_win()
  if mode == 'one_shot' then
    -- This puts us in the floating window.
    win_id = t_window.oneshot_motions(vim.api.nvim_get_current_buf())
  end

  -- TODO: We should really use the vim.api.nvim_win_get_cursor()
  --        This will make sure we stay in the right window for all the movements
  local original_cursor = vim.api.nvim_win_get_cursor(win_id)
  -- vim.fn['train#_cache_vim_option']('eventignore', 'all')

  -- Result of executing motions
  -- Names: potential_positions
  local resulting_positions = {}

  -- TODO: Need to make sure we reset the winview
  for _, motion in ipairs(motions) do
    -- Reset our cursor position
    vim.api.nvim_win_set_cursor(win_id, original_cursor)

    local next_position = train.perform_motion(win_id, motion)
    train.show_motion(win_id, resulting_positions, next_position, motion, true)
  end

  local descriptions = {}
  vim.tbl_map(function(v) table.insert(descriptions, v.description) end, motions)

  vim.api.nvim_win_set_cursor(win_id, original_cursor)
  -- vim.fn['train#_uncache_vim_option']('eventignore')

  -- TODO: Add all the autocmds you can think of here!
  vim.api.nvim_command(string.format(
    [[autocmd CursorMoved,VimLeave,ExitPre,InsertEnter <buffer> ++once :lua require('train').clear_matches(%s, "%s")]],
    win_id,
    mode
  ))

  -- vim.cmd [[set modifiable]]
end

function TrainExample()
  RELOAD('train')
  require('train').show_matches({'w', '$', '0', '^'})
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
