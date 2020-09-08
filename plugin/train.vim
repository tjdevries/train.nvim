
" TODO: Add code fold s:movements

let s:movements = train#builtin#get()

let g:train_highlight_pulses = get(g:, 'train_highlight_pulse', [
      \ {'higroup': "Error", 'timeout': 1000 },
      \ {'higroup': "Function", 'timeout': 1000 }
      \ ])

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
      \ 'basic': [
        \ s:movements['('], 
        \ s:movements[')'], 
        \ s:movements['{'], 
        \ s:movements['}']],
      \ 'intermediate': [
        \ s:movements[']]'], 
        \ s:movements[']['], 
        \ s:movements['[['], 
        \ s:movements['[]']],
      \ 'advanced': [],
      \ }

command! TrainClear :lua require('train').clear_matches()

command! TrainUpDown  :call train#show_matches(train#convert_group(g:train_motion_groups.up_down, 'advanced'))
command! TrainWord    :call train#show_matches(train#convert_group(g:train_motion_groups.word, 'advanced'))
command! TrainTextObj :call train#show_matches(train#convert_group(g:train_motion_groups.text_obj, 'advanced'))

