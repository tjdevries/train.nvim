
" Create a list of match_ids that we can use to clear them later
let s:list_of_match_ids = get(s:, 'list_of_match_ids', [])

let s:cached_options = get(s:, 'cached_options', {})
function! train#_cache_vim_option(option, value) abort
  let s:cached_options[a:option] = eval('&' . a:option)

  call execute('set ' . a:option . '=' . a:value)
endfunction

function! train#_uncache_vim_option(option) abort
  if !has_key(s:cached_options, a:option)
    return
  endif

  call execute('set ' . a:option . '=' . s:cached_options[a:option])
  unlet s:cached_options[a:option]
endfunction

function! train#_opt_string() abort
  " TODO: Could add configuration value here?
  "         But I don't know why you wouldn't want to remap them.
  let remap_keys = v:true

  let opt_string = ''

  " If remap_keys, add "m", add "n"
  let opt_string .= remap_keys ? 'm' : 'n'

  " Execute always til typeahead is done
  let opt_string .= 'x'

  return opt_string
endfunction

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

function! train#show_matches(motions, ...) abort
  call luaeval("require('train').show_matches(_A)", a:motions)
endfunction

" My test string is this string
" It spans multiple lines
" and it helps me to see things

function! train#convert_group(group, max_level) abort
  let level = s:convert_group(a:max_level)

  let motions = a:group.basic
  if level > 1
    let motions += a:group.intermediate
  endif

  if level > 2
    let motions += a:group.advanced
  endif

  return motions
endfunction




