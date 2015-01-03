if ( exists('g:loaded_ctrlp_custom_modes') && g:loaded_ctrlp_custom_modes)
	\ || v:version < 700 || &cp
	finish
endif

call ctrlp_custom_modes#setup()

let extensions = [
      \ ['directives', 'directives/@@input@@.js'],
      \ ['templates', 'app/templates/@@input@@.html'],
    \ ]

call ctrlp_custom_modes#init_extensions(extensions)
let g:loaded_ctrlp_custom_modes = 1

for i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  exec 'com! CtrlPCustomMode'.i. ' call ctrlp_custom_modes#init('.i.')'
endfor
