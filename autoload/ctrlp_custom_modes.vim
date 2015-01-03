" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
"call add(g:ctrlp_ext_vars, {
	"\ 'init': 'ctrlp#sample#init()',
	"\ 'accept': 'ctrlp#sample#accept',
	"\ 'lname': 'long statusline name',
	"\ 'sname': 'shortname',
	"\ 'type': 'line',
	"\ 'enter': 'ctrlp#sample#enter()',
	"\ 'exit': 'ctrlp#sample#exit()',
	"\ 'update': 'ctrlp#sample#update',
	"\ 'opts': 'ctrlp#sample#opts()',
	"\ 'sort': 0,
	"\ 'specinput': 0,
	"\ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp_custom_modes#init()
  return ctrlp#files()
endfunction


function! ctrlp_custom_modes#update(str)
  return 'app/templates' . a:str . '.html'
endfunction


" Give the extension an ID

" Allow it to be called later
"function! ctrlp#sample#id()
	"return s:id
"endfunction

function! s:register(name)
  let shortname = 'c:'.a:name[0:2]
  call add(g:ctrlp_ext_vars, {
    \ 'init': 'ctrlp_custom_modes#init()',
    \ 'accept': 'ctrlp#acceptfile',
    \ 'lname': 'custom: '.a:name,
    \ 'sname': shortname,
    \ 'type': 'line',
    \ 'update': 'g:ctrlp_custom_modes_update_'.a:name,
    \ 'sort': 0,
    \ })

  let id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
  let b = " \n"
  "execute "function! ctrlp#".a:name."#id()" .b. "return ".id.b. "endfunction"
endfunction

let g:ctrlp_custom_modes_parsed = {}

function! s:parse(name, input)
  let [pre, post] = split(a:input, '@@input@@')
  let g:ctrlp_custom_modes_parsed[a:name] = { 'pre' : pre, 'post' : post}
endfunction

function! ctrlp_custom_modes#generate_update_fn(name)
  let head = 'function! g:ctrlp_custom_modes_update_'.a:name.' (str)'
  let body = 'return g:ctrlp_custom_modes_parsed["'.a:name.'"]["pre"].a:str.g:ctrlp_custom_modes_parsed["'.a:name.'"]["post"]'
  let foot = 'endfunction'
  let cmd = join([head, ech, body, foot], "\n")
  echo cmd
  execute cmd
endfunction

function! ctrlp_custom_modes#add_extensions(exts)
  if !exists('g:ctrlp_extensions')
    let g:ctrlp_extensions = []
  endif

  for [name, ext] in items(a:exts)
    call s:parse(name, ext)
    call ctrlp_custom_modes#generate_update_fn(name)
    call s:register(name)
    call add(g:ctrlp_extensions, name)
  endfor
endfunction


