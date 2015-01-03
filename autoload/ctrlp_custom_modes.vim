function! s:register(name)
  let shortname = 'c:'.a:name[0:2]
  call add(g:ctrlp_ext_vars, {
    \ 'init': 'ctrlp#files()',
    \ 'accept': 'ctrlp#acceptfile',
    \ 'lname': 'custom: '.a:name,
    \ 'sname': shortname,
    \ 'type': 'path',
    \ 'update': 'g:ctrlp_custom_modes_update_'.a:name,
    \ 'sort': 0,
    \ })

  let id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
  let s:ids[a:name] = id
endfunction

let s:input_exts= {}
let s:ids    = {}

function! s:parse(name, input)
  let [pre, post] = split(a:input, '@@input@@')
  let s:input_exts[a:name] = { 'pre' : pre, 'post' : post}
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
  let head = 'function! g:ctrlp_custom_modes_update_'.a:name.' (str)'
  let body = 'return '.def.'["pre"].a:str.'.def.'["post"]'
  let foot = 'endfunction'
  let cmd = join([head, body, foot], "\n")
  execute cmd
endfunction

function! ctrlp_custom_modes#add_extensions(exts)
  if !exists('g:ctrlp_extensions')
    let g:ctrlp_extensions = []
  endif

  for [name, ext] in items(a:exts)
    call s:parse(name, ext)
    call s:generate_update_fn(name)
    call s:register(name)
    call add(g:ctrlp_extensions, name)
  endfor
endfunction

" TODO
"
" - Really parse for a definition file
" - Properly reinit the extensions, but only when
"   - the root path changes and we find a new (or no) file
" - Init key mappings


