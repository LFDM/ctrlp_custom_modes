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
  call add(s:ids, [[a:name], id])
endfunction

let s:input_exts= {}
let s:ids    = []

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

function! ctrlp_custom_modes#setup()
  if !exists('g:ctrlp_extensions')
    let g:ctrlp_extensions = []
  endif
endfunction

function! ctrlp_custom_modes#init_extensions(exts)
  for [name, ext] in a:exts
    call s:parse(name, ext)
    call s:generate_update_fn(name)
    call s:register(name)
    call add(g:ctrlp_extensions, name)
  endfor

endfunction

function! ctrlp_custom_modes#init(i)
  let max  = len(s:ids) - 1
  if a:i <= max
    let ext = s:ids[a:i]
    call ctrlp#init(ext[1])
  else
    echo "No custom mode defined"
  endif
endfunction

" TODO
"
" - Really parse for a definition file
" - Properly reinit the extensions, but only when
"   - the root path changes and we find a new (or no) file
" - Init key mappings


