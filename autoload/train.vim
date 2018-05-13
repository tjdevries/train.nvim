
let s:up_down_motions = {
      \ 'basic': [ 'k', 'j', 'h', 'l', 'gg'],
      \ 'intermediate': ['M', 'H', 'L'],
      \ 'advanced': [],
      \ }

let s:word_motions = {
      \ 'basic': ['w', 'W', 'e', 'E', 'b', 'B'],
      \ 'intermediate': ['ge', 'gE'],
      \ 'advanced': [],
      \ }

let s:text_object_motions = {
      \ 'basic': ['(', ')', '{', '}'],
      \ 'intermediate': [']]', '][', '[[', '[]'],
      \ 'advanced': [],
      \ }

" Create a list of match_ids that we can use to clear them later
let s:list_of_match_ids = get(s:, 'list_of_match_ids', [])

let s:cached_options = get(s:, 'cached_options', {})
function! s:cache_nvim_option(option, value) abort
  let s:cached_options[a:option] = eval('&' . a:option)

  call execute('set ' . a:option . '=' . a:value)
endfunction

function! s:uncache_nvim_option(option) abort
  if !has_key(s:cached_options, a:option)
    return
  endif

  call execute('set ' . a:option . '=' . s:cached_options[a:option])
  unlet s:cached_options[a:option]
endfunction

function! train#_set_up() abort
  if train#conf#get('conceal', 'override')
    call s:cache_nvim_option('conceallevel', train#conf#get('conceal', 'level'))
    call s:cache_nvim_option('concealcursor', train#conf#get('conceal', 'cursor'))
  endif
endfunction

function! train#_clean_up() abort
  call s:uncache_nvim_option('conceallevel')
  call s:uncache_nvim_option('concealcursor')
endfunction

function! train#clear_matches() abort
  for match_id in s:list_of_match_ids
    try
      call matchdelete(match_id)
    catch
    endtry
  endfor

  let s:list_of_match_ids = []

  call train#_clean_up()
endfunction

function! train#_opt_string(opts) abort
  " Parse the options from a 
  if has_key(a:opts, 'remap')
    let remap_keys = a:opts.remap
  else
    let remap_keys = train#conf#get('input', 'remap')
  endif

  let opt_string = ''

  " If remap_keys, add "m", add "n"
  let opt_string .= remap_keys ? 'm' : 'n'

  " Execute always til typeahead is done
  let opt_string .= 'x'

  return opt_string
endfunction

" TODO: Include count as an option
function! train#show_matches(motions, ...) abort
  if a:0 > 0
    let opts = a:1
  else
    let opts = {}
  endif

  " Clear any old matches
  call train#clear_matches()
  call train#_set_up()

  " Get the current position
  let save_cursor = getcurpos()

  if !train#conf#get('input', 'no_mark')
    call execute('normal! mt')
  endif

  let positions_found = []

  " Cache the eventignore value
  call s:cache_nvim_option('eventignore', 'all')

  " Move through each motion
  for motion in a:motions
    " Move to our original position
    call setpos('.', save_cursor)

    " Perform the motion
    let opt_string = train#_opt_string(opts)
    call nvim_feedkeys(motion, opt_string, v:false)

    let next_position = getcurpos()

    " Skip if we didn't go anywhere
    if next_position == save_cursor
      continue
    endif

    " Check if we've already added this one
    if index(positions_found, next_position) > -1
      continue
    endif

    " Add to the list of found positions
    call add(positions_found, next_position)

    for index in range(len(motion))
      if index == 0
        let conceal_hl = 'Conceal'
      else
        let conceal_hl = 'Conceal'
      endif

      call insert(s:list_of_match_ids, matchaddpos(
            \ conceal_hl,
            \ [[next_position[1], next_position[2] + index]],
            \ 10000,
            \ -1,
            \ {'conceal': strpart(motion, index, 1)}))
    endfor
  endfor

  call setpos('.', save_cursor)
  call s:uncache_nvim_option('eventignore')
endfunction




function! TESTER() abort
  let motions = s:text_object_motions.basic
  let motions += s:text_object_motions.intermediate
  let motions += s:word_motions.intermediate

  return train#show_matches(motions, {'remap': v:true})
  " for index in range(len('asdf'))
  "   echo strpart('asdf', index, 1)
  " endfor
endfunction

" My test string is this string
" It spans multiple lines
" and it helps me to see things
