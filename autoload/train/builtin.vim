" Substitution to move help text to nice s:movements thing
" :s/\(\S*\)\s*\(.*\)/let s:movements["\1"] = s:mk_move("\1", "\2")

function! s:mk_move(move, desc) abort
  return {
        \ 'movement': a:move,
        \ 'description': a:desc,
        \ }
endfunction

let s:movements = {}

let s:movements["("] = s:mk_move('(', '[count] |sentence|s backward.  |exclusive| motion.')
let s:movements[")"] = s:mk_move(')', '[count] |sentence|s forward.  |exclusive| motion.')
let s:movements["{"] = s:mk_move('{', '[count] |paragraph|s backward.  |exclusive| motion.')
let s:movements["}"] = s:mk_move('}', '[count] |paragraph|s forward.  |exclusive| motion.')

let s:movements["]]"] = s:mk_move("]]", "[count] |section|s forward or to the next '{' in the first column.  When used after an operator, then also stops below a '}' in the first column.  |exclusive|")
let s:movements["[["] = s:mk_move('[[', "[count] |section|s backward or to the previous '{' in the first column.  |exclusive|")
let s:movements["]["] = s:mk_move("][", "[count] |section|s forward or to the next '}' in the first column.  |exclusive|")
let s:movements["[]"] = s:mk_move("[]", "[count] |section|s backward or to the previous '}' in the first column.  |exclusive|")

function! train#builtin#get() abort
  return s:movements
endfunction

