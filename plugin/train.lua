-- Substitution to move help text to nice movements thing
-- :s/\(\S*\)\s*\(.*\)/local movements["\1"] = mk_move("\1", "\2")

local function mk_move(move, desc)
  return {
    movement = move,
    description = desc,
  }
end

local movements = {}

movements["("] = mk_move("(", "[count] |sentence|s backward.  |exclusive| motion.")
movements[")"] = mk_move(")", "[count] |sentence|s forward.  |exclusive| motion.")
movements["{"] = mk_move("{", "[count] |paragraph|s backward.  |exclusive| motion.")
movements["}"] = mk_move("}", "[count] |paragraph|s forward.  |exclusive| motion.")

movements["]]"] = mk_move(
  "]]",
  "[count] |section|s forward or to the next '{' in the first column.  When used after an operator, then also stops below a '}' in the first column.  |exclusive|"
)
movements["[["] = mk_move("[[", "[count] |section|s backward or to the previous '{' in the first column.  |exclusive|")
movements["]["] = mk_move("][", "[count] |section|s forward or to the next '}' in the first column.  |exclusive|")
movements["[]"] = mk_move("[]", "[count] |section|s backward or to the previous '}' in the first column.  |exclusive|")

-- TODO: Add code fold s:movements

-- local train_highlight_pulses = get(g:, 'train_highlight_pulse', [
--       \ {'higroup': "Error", 'timeout': 1000 },
--       \ {'higroup': "Function", 'timeout': 1000 }
--       \ ])

local train_motion_groups = {}

train_motion_groups.up_down = {
  basic = { "k", "j", "h", "l", "gg" },
  intermediate = { "M", "H", "L" },
  advanced = {},
}

train_motion_groups.word = {
  basic = { "w", "W", "e", "E", "b", "B" },
  intermediate = { "ge", "gE" },
  advanced = {},
}

train_motion_groups.text_obj = {
  basic = {
    movements["("],
    movements[")"],
    movements["{"],
    movements["}"],
  },
  intermediate = {
    movements["]]"],
    movements["]["],
    movements["[["],
    movements["[]"],
  },
  advanced = {},
}

local train = require "train"
vim.api.nvim_create_user_command("TrainUpDown", function()
  local motions = train.convert(train_motion_groups.up_down, "advanced")
  train.show_matches(motions)
end, {})

vim.api.nvim_create_user_command("TrainWord", function()
  local motions = train.convert(train_motion_groups.word, "advanced")
  train.show_matches(motions)
end, {})

vim.api.nvim_create_user_command("TrainTextObj", function()
  local motions = train.convert(train_motion_groups.text_obj, "advanced")
  train.show_matches(motions)
end, {})
