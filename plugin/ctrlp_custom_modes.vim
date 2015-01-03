" Load guard
if ( exists('g:loaded_ctrlp_custom_modes') && g:loaded_ctrlp_custom_modes)
	\ || v:version < 700 || &cp
	finish
endif


call ctrlp_custom_modes#setup()

let extensions = { 'directives' : 'directives/@@input@@.js', 'templates': 'app/templates/@@input@@.html' }
call ctrlp_custom_modes#init_extensions(extensions)
let g:loaded_ctrlp_custom_modes = 1



" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/sample.vim
" command! CtrlPSample call ctrlp#init(ctrlp#sample#id())

" vim:nofen:fdl=0:ts=2:sw=2:sts=2
