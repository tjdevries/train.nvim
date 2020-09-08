local p_float = require('plenary.window.float')

local t_window = {}

-- TODO: Do we even need to see the motions on this side.
t_window.oneshot_motions = function(bufnr)
  local floatwin = p_float.percentage_range_window(
    {0.1, 0.8},
    0.8,
    { bufnr = bufnr }
  )

  local win_id = floatwin.win

  vim.cmd(string.format(
    [[autocmd CursorMoved <buffer> ++once :call nvim_win_close(%s, v:true)]],
    win_id
  ))

  vim.cmd(string.format(
    [[autocmd CursorMoved <buffer> ++once :call nvim_win_close(%s, v:true)]],
    floatwin.border_win_id
  ))

  return win_id
end

return t_window
