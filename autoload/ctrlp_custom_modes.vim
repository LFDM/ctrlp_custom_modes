function! s:register(name)
  let shortname = 'c:'.a:name[0:2]
  call add(g:ctrlp_ext_vars, {
    \ 'init': 'ctrlp#files()',
    \ 'accept': 'ctrlp#acceptfile',
    \ 'lname': 'custom: '.a:name,
    \ 'sname': shortname,
    \ 'type': 'path',
    \ 'update': s:update_fn(a:name),
    \ 'sort': 0,
    \ })

  let id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
  call add(s:ids, [a:name, id])
endfunction

function! s:parse(name, input)
  let [pre, post] = split(a:input, '@@input@@', 1)
  let s:input_exts[a:name] = { 'pre' : pre, 'post' : post}
endfunction

function! s:update_fn(name)
  return 'g:ctrlp_custom_modes_update_'.a:name
endfunction

" Generate an update function, e.g. given a custom mode called
"   templates
" like this:
"
" function! g:ctrlp_custom_modes_update_templates(str)
"   return s:input_exts['templates']['pre'].a:str.s:input_exts['templates']['post']
" endfunction
function! s:generate_update_fn(name)
  let def = 's:input_exts["'.a:name.'"]'
  let head = 'function! '.s:update_fn(a:name).'(str)'
  let body = 'return '.def.'["pre"].a:str.'.def.'["post"]'
  let foot = 'endfunction'
  let cmd = join([head, body, foot], "\n")
  execute cmd
endfunction

function! s:cleanup_update_fns()
  for [name, id] in s:ids
    exec 'delf '.s:update_fn(name)
  endfor
endfunction

function! s:setup()
  if !exists('g:ctrlp_extensions') | let g:ctrlp_extensions = [] | endif
  if exists('s:ids') | call s:cleanup_update_fns() | endif
  let s:input_exts = {}
  let s:ids = []
endfunction

" Taken from tpope at https://github.com/tpope/vim-projectionist/blob/ef252eb227928df6f63590f21584a46c08792021/autoload/projectionist.vim#L57-L68
function! s:json_parse(string)
  let [null, false, true] = ['', 0, 1]
  let string = type(a:string) == type([]) ? join(a:string, ' ') : a:string
  let stripped = substitute(string, '\C"\(\\.\|[^"\\]\)*"', '', 'g')
  if stripped !~# "[^,:{}\\[\\]0-9.\\-+Eaeflnr-u \n\r\t]"
    try
      return eval(substitute(string, "[\r\n]", ' ', 'g'))
    catch
    endtry
  endif
  throw "invalid JSON: ".string
endfunction

function! s:init_extensions(exts)
  for [name, ext] in a:exts
    call s:parse(name, ext)
    call s:generate_update_fn(name)
    call s:register(name)
    call add(g:ctrlp_extensions, name)
  endfor
endfunction

let s:silent = 0
function! ctrlp_custom_modes#start()
  call s:setup()
  let file = '.ctrlp_custom_modes.json'

  if filereadable(file)
    let extensions = s:json_parse(readfile(file))
    call s:init_extensions(extensions)
  else
    if !s:silent
      echo "No CtrlPCustomMode json file found"
    endif
  endif
endfunction

function! ctrlp_custom_modes#start_silent()
  let s:silent = 1
  call ctrlp_custom_modes#start()
  let s:silent = 0
endfunction

function! ctrlp_custom_modes#init(i)
  let max  = len(s:ids) - 1
  if a:i <= max
    let ext = s:ids[a:i]
    call ctrlp#init(ext[1])
  else
    echo "No CtrlP custom mode ".a:i." defined"
  endif
endfunction
