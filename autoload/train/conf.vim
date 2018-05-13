
" Prefix to use for this autoload file
let s:autoload_prefix = "train#conf"
let s:autoload_file = expand("<sfile>:p")

call conf#set_name(s:, 'train.vim')
call conf#set_version(s:, [1, 0, 0])

" ===== Training Options =====
call conf#add_area(s:, 'training_set')
" call conf#add_setting(s:, 'training_set', 'current', {})
" call conf#add_setting(s:, 'training_set', 'review', {})

call conf#add_area(s:, 'vertical')
call conf#add_setting(s:, 'vertical', 'basic', {
      \ 'default': [ 'k', 'j', 'h', 'l', 'gg'],
      \ 'type': v:t_list,
      \ 'description': '(string[]): List of basic vertical motions',
      \ })
call conf#add_setting(s:, 'vertical', 'intermediate', {
      \ 'default': ['M', 'H', 'L'],
      \ 'type': v:t_list,
      \ 'description': '(string[]): List of intermediate vertical motions',
      \ })
call conf#add_setting(s:, 'vertical', 'advanced', {
      \ 'default': [],
      \ 'type': v:t_list,
      \ 'description': '(string[]): List of advanced vertical motions',
      \ })

" ===== Input Options =====
call conf#add_area(s:, 'input')
call conf#add_setting(s:, 'input', 'remap', {
      \ 'default': v:true,
      \ 'type': v:t_bool,
      \ 'description': '(Boolean): Should remap the input',
      \ })
call conf#add_setting(s:, 'input', 'no_mark', {
      \ 'default': v:false,
      \ 'type': v:t_bool,
      \ 'description': '(Boolean): Whether a mark should be set or not during training',
      \ })

" ===== Conceal Override =====
call conf#add_area(s:, 'conceal')
call conf#add_setting(s:, 'conceal', 'override', {
      \ 'default': v:true,
      \ 'type': v:t_bool,
      \ 'description': '(Boolean): If false, conceal options will not be overridden',
      \ })
call conf#add_setting(s:, 'conceal', 'level', {
      \ 'default': 1,
      \ 'type': v:t_number,
      \ 'description': '(Integer): The conceal level to set during training',
      \ })
call conf#add_setting(s:, 'conceal', 'cursor', {
      \ 'default': 'n',
      \ 'type': v:t_string,
      \ 'description': '(String): The conceal cursor setting to use during training',
      \ })


" And then add some options
" call conf#add_setting(s:, 'defaults', 'map_key', {'default': '<leader>x', 'type': v:t_string})
" call conf#add_setting(s:, 'defaults', 'another_key', {'default': '<leader>a', 'type': v:t_string})


""
" train#conf#set
" Set a "value" for the "area.setting"
" See |conf.set_setting|
function! train#conf#set(area, setting, value) abort
  return conf#set_setting(s:, a:area, a:setting, a:value)
endfunction


""
" train#conf#get
" Get the "value" for the "area.setting"
" See |conf.get_setting}
function! train#conf#get(area, setting) abort
  return conf#get_setting(s:, a:area, a:setting)
endfunction


""
" train#conf#view
" View the current configuration dictionary.
" Useful for debugging
function! train#conf#view() abort
  return conf#view(s:)
endfunction


""
" train#conf#menu
" Provide the user with an automatic "quickmenu"
" See |conf.menu|
function! train#conf#menu() abort
  return conf#menu(s:)
endfunction


""
" train#conf#version
" Get the version for this plugin
" Returns a semver dict
function! train#conf#version() abort
  return conf#get_version(s:)
endfunction


""
" train#conf#require
" Require a version of this plugin.
" Returns false if not a high enough version
function! train#conf#require(semver) abort
  return conf#require_version(s:, a:semver)
endfunction


""
" train#conf#debug
" Print a debug statement containing information about the plugin
" and the versions of required plugins
function! train#conf#debug() abort
  return conf#debug(s:)
endfunction


""
" train#conf#generate_docs
" Returns a list of lines to be placed in your documentation
" Can use :call append(line("%"), func())
function! train#conf#generate_docs() abort
  return conf#docs#generate(s:, s:autoload_prefix)
endfunction

""
" train#conf#insert_docs
" Insert the generated docs under where you cursor is
function! train#conf#insert_docs() abort
  return conf#docs#insert(s:, s:autoload_prefix)
endfunction

