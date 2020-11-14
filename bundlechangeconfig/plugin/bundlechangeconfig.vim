let g:NERDCreateDefaultMappings = 0
map mg <plug>NERDCommenterComment
map mu <plug>NERDCommenterUncomment
let g:NERDDefaultAlign = 'left'
let g:NERDCustomDelimiters = { 'lua': { 'left':'--','leftAlt': '','right': '' } }
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap ,d :call ctags_selector#OpenTagSelector('/'.expand("<cword>"))<cr>
