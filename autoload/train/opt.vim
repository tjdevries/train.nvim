
let s:train_options = get(s:, 'train_options', {})

function! train#opt#set(option, value, ...)
  if a:0 > 0
    let default = a:1
  else
    let default = v:false
  endif

  " If we're setting a default, and we find the option already set
  " Don't do anything
  if default && has_key(s:train_options, a:option)
    return
  endif

  let s:train_options[a:option] = a:value
endfunction

function! train#opt#get(option)
  if has_key(s:train_options, a:option)
    return s:train_options[a:option]
  else
    return v:false
  endif
endfunction
