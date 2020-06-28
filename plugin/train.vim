
let g:train_motion_groups = {}

let g:train_motion_groups.up_down = {
      \ 'basic': [ 'k', 'j', 'h', 'l', 'gg'],
      \ 'intermediate': ['M', 'H', 'L'],
      \ 'advanced': [],
      \ }

let g:train_motion_groups.word = {
      \ 'basic': ['w', 'W', 'e', 'E', 'b', 'B'],
      \ 'intermediate': ['ge', 'gE'],
      \ 'advanced': [],
      \ }

let g:train_motion_groups.text_obj = {
      \ 'basic': ['(', ')', '{', '}'],
      \ 'intermediate': [']]', '][', '[[', '[]'],
      \ 'advanced': [],
      \ }



command! TrainClear :lua require('train').clear_matches()

command! TrainUpDown :call train#show_matches(train#convert_group(g:train_motion_groups.up_down, 'advanced'))

