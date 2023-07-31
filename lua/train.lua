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

package.loaded["train"] = nil

local Motion = require "train.motion"

local ns = vim.api.nvim_create_namespace "train-nvim"

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

    vim.wo[win_id].winhl = string.format("Normal:%s", list_of_hls[index].higroup)
  end)
end

function train.clear_matches(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

--- Perform a motion and return new position.
--@arg win_id number: The window ID that we're in currently.
--@arg motion Motion: A Motion object.
function train.perform_motion(win_id, motion)
  local feedkey_mode = "mx"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(motion.movement, true, true, true), feedkey_mode, true)

  return vim.api.nvim_win_get_cursor(win_id)
end

--- Make a floating window at the location for the position.
--- It should register it's floating window so we can clear it later.
--@param cursor: result from nvim_win_get_cursor() (row, col)
function train.show_motion(bufnr, resulting_cursors, cursor, motion, pulse)
  -- TODO:
  --    Check if the windows scroll with you as you scroll.

  -- Check if any resulting positions start in the same place.
  for _, existing_cursor in ipairs(resulting_cursors) do
    if existing_cursor == cursor then
      return
    end

    if existing_cursor[1] == cursor[1] and existing_cursor[2] == cursor[2] then
      return
    end
  end

  local row = cursor[1] - 1
  local col = cursor[2]

  vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
    virt_text = { { motion.movement, "Error" } },
    virt_text_pos = "overlay",
  })

  table.insert(resulting_cursors, cursor)
end

--@param motions (table): List of motions to execute.
function train.show_matches(raw_motions)
  local bufnr = vim.api.nvim_get_current_buf()
  local win_id = vim.api.nvim_get_current_win()

  local motions = {}
  for _, v in ipairs(raw_motions) do
    table.insert(motions, Motion:new(v))
  end

  local original_cursor = vim.api.nvim_win_get_cursor(win_id)

  -- Result of executing motions
  -- Names: potential_positions
  local resulting_positions = {}

  -- TODO: Need to make sure we reset the winview
  for _, motion in ipairs(motions) do
    -- Reset our cursor position
    vim.api.nvim_win_set_cursor(win_id, original_cursor)

    local next_position = train.perform_motion(win_id, motion)
    train.show_motion(bufnr, resulting_positions, next_position, motion, true)
  end

  local descriptions = {}
  vim.tbl_map(function(v)
    table.insert(descriptions, v.description)
  end, motions)

  vim.api.nvim_win_set_cursor(win_id, original_cursor)
  vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
    buffer = 0,
    callback = function()
      train.clear_matches(bufnr)
      return true
    end,
  })
end

function train.convert(motions, level)
  local results = {}

  for _, value in pairs(motions) do
    -- table.insert(results, value)
    vim.list_extend(results, value)
  end

  return results
end

--[[

function! s:convert_group(level) abort
  if a:level == 'basic'
    return 1
  endif

  if a:level == 'intermediate'
    return 2
  endif

  if a:level == 'advanced'
    return 3
  endif

  return 4
endfunction

--]]

return train
