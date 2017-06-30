
let s:up_down_motions = {
            \ 'basic': [ 'k', 'j', 'h', 'l', 'gg'],
            \ 'intermediate': ['-', '+'],
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

" TODO: Include count as an option
function! train#show_matches() abort
    let save_cursor = getcurpos()

    let motions = s:text_object_motions.basic
    let motions += s:text_object_motions.intermediate
    let motions += s:word_motions.intermediate

    let positions_found = []

    let ignore_var = &eventignore

    set eventignore=all
    for motion in motions
        call setpos('.', save_cursor)
        call nvim_feedkeys(motion, 'nx', v:true)
        let next_position = getcurpos()

        " Check if we've already added this one
        if index(positions_found, next_position) > -1
            continue
        endif

        " Add to the list of found positions
        call add(positions_found, next_position)

        for index in range(len(motion))
            if index != 0
                let conceal_hl = 'Conceal'
            else
                let conceal_hl = 'Conceal'
            endif

            call matchaddpos(conceal_hl, [[next_position[1], next_position[2] + index]], 10000, -1, {'conceal': strpart(motion, index, 1)})
        endfor
    endfor

    call setpos('.', save_cursor)
    execute('set eventignore=' . ignore_var)
endfunction

function! TESTER() abort
    for index in range(len('asdf'))
        echo strpart('asdf', index, 1)
    endfor
endfunction

" My test string is this string
" It spans multiple lines
" and it helps me to see things
