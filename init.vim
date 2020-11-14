"nvim配置init.vim路径
    "windows: e:/neovim/config///nvim/init.vim是配置文件
    "linux: $HOME/nvimplugin///nvim/int.vim是配置文件
"nvim可以加载插件的runtime
    "$XDG_CONFIG_HOME/nvim
"vim配置vimrc路径
    "window: $VIM/_vimrc (e:/vim/_vimrc)
    "linux: $HOME/.vim/vimrc
"vim可以加载插件的runtime
    "windows:$VIM/vimfiles
    "linux:$HOME/.vim
"nvim放置
    "$XDG_CONFIG_HOME/nvim/autoload下pathogen和plug.vim
    "windows: e:/neovim/config///nvim/autoload
    "unix: $HOME/nvimplugin///nvim/autoload
"vim放置
    "windows: e:/vim/vimfiles/autoload
    "unix: $HOME/.vim/autoload
set nocompatible
function! IsWin()
    if has('win32') || has('win64')
        return 1
    else
        return 0
endfunction

function! IsVim()
    return !has('nvim')
endfunction


if IsVim() && !IsWin() && !has('gui_running')
  function! s:metacode(key)
    execute "set <m-".a:key.">=\e".a:key
  endfunc
  for i in range(10)
    call s:metacode(nr2char(char2nr('0')+i))
  endfor
  for i in range(26)
    call s:metacode(nr2char(char2nr('a')+i))
    call s:metacode(nr2char(char2nr('A')+i))
  endfor
  for c in [',','.','/',';','{','}','?',':','-','_']
    call s:metacode(c)
  endfor
  set ttimeoutlen=50
  let &t_SI .= "\<Esc>[5 q"
  let &t_EI .= "\<Esc>[1 q"
  let &t_SR .= "\<Esc>[3 q"
endif
"##### basic setting ###########
set showcmd
set termguicolors
set mouse=a

set viminfo+=! 
if !IsWin()
    if IsVim()
        rviminfo! $HOME/.viminfo
    endif
endif
set history=1000
set wildmenu

set fileformats=unix,dos
set laststatus=2
set statusline=%F
set winaltkeys=no
set nobackup
set noswapfile
set guioptions-=m
set guioptions-=T
set guioptions+=b
set number
if IsVim()
    set clipboard=unnamed,unnamedplus
else
    set clipboard+=unnamedplus
endif  

syntax on
syntax enable
filetype on
filetype plugin on

set hlsearch
set ignorecase
set re=1
set lazyredraw
set synmaxcol=128
syntax sync minlines=256

set backspace=indent,eol,start
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set cindent
set cinoptions={0,1s,t0,n-2,p2s,(03s,=.5s,>1s,=1s,:1s
set backspace=2
set expandtab

set fileignorecase
"""""""
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,chinese
set ambiwidth=double
set fileencoding=utf-8


runtime macros/matchit.vim 
if IsWin()
    if has('gui_running')
        autocmd GUIEnter * simalt ~x
        set guifont=courier_new:h12
        source $vimruntime/delmenu.vim
        source $vimruntime/menu.vim
    endif
endif

if has("autocmd")                                                          
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    "au BufEnter * 
        "\ if(expand('%:p:h'))!='' && &filetype!='' && &filetype!='qf' && &filetype!='leaderf'
        "\ && &filetype!='fzf' && &filetype!='list' && filereadable(expand('%:p'))|
        "\ exe 'cd! '.expand('%:p:h') | 
        "\ endif
endif

set autochdir
set ff=unix
"##### basic setting end ###########

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
imap <m-i> <Esc>
map <m-i> i
imap <m-;> <end>;
imap <m-space> <space>
inoremap <expr> <CR>       pumvisible() ? "\<c-y>" : "\<CR>"
inoremap <expr> <m-j>       pumvisible() ? "\<C-n>" : "\<down>"
inoremap <expr> <m-k>       pumvisible() ? "\<C-p>" : "\<up>"
inoremap <expr> <m-h>       pumvisible() ? "\<esc>i" : "\<left>"
inoremap <expr> <m-l>       pumvisible() ? "\<esc>la" : "\<right>"

map <m-l> l
map <m-h> h
imap <m-m> <end>
imap <m-n> <home>
imap <m-o> <end><enter>
imap <m-space> <space>
map <m-o> o
map gj :%s///g
vmap gj :s///g
map gh <c-w>w
map <m-space> <c-w>w
map <space> <c-w>w
map <m-j> jjjjj
map <m-k> kkkkk
vmap <m-j> jjjjj
vmap <m-k> kkkkk
map ma :close<cr>
map mm zR
map MM zM
function! PasteUnderNowLine()
    let l:text = getreg('+',0,v:true)
    call append(line('.'),l:text)
endfunction
map ,p :call PasteUnderNowLine()<cr>
map <m-m> :bn!<CR>
map <m-n> :bp!<CR>
map mq ^
map mp $
vmap mp $h
map ms <c-]>
map mt <c-t>

map me :split<cr>
map mw :vsplit<cr>
if IsVim()
    cmap <m-h> <left>
    cmap <m-l> <right>
    cmap <m-j> <down>
    cmap <m-k> <up>
    cmap <m-m> <end>
    cmap <m-n> <home>
    cmap <m-p> <c-r>+
    cmap <m-i> <esc>
else
    cmap <expr> <m-h>       pumvisible() ? "\<down>\<left>" : "\<left>"
    cmap <expr> <m-l>       pumvisible() ? "\<down>\<right>" : "\<right>"
    cmap <expr> <m-j>       pumvisible() ? "\<Right>" : "\<down>"
    cmap <expr> <m-k>       pumvisible() ? "\<Left>" : "\<up>"
    cmap <expr> <m-m>       pumvisible() ? "\<down>\<end>" : "\<end>"
    cmap <expr> <m-n>       pumvisible() ? "\<down>\<home>" : "\<home>"
    cmap <expr> <cr>     pumvisible() ? "\<down>" : "\<cr>"
    cmap <m-p> <c-r>+
endif

tmap <m-i> <c-\><c-n>
tmap <m-l> <right>
tmap <m-h> <left>
tmap <m-n> <home>
tmap <m-m> <end>
tmap <m-j> <down>
tmap <m-k> <up>

if IsVim()
    tmap <m-p> <c-w>"+
else 
    tmap <m-p> <c-\><c-n>pa
endif

map md :Bdelete!<cr>
map mn :NERDTreeToggle<CR>

map f <leader><leader><leader>f
map mg <leader>cc
map mu <leader>cu

let g:buftabline_numbers=2
nmap <m-1> <Plug>BufTabLine.Go(1)
nmap <m-2> <Plug>BufTabLine.Go(2)
nmap <m-3> <Plug>BufTabLine.Go(3)
nmap <m-4> <Plug>BufTabLine.Go(4)
nmap <m-5> <Plug>BufTabLine.Go(5)
nmap <m-6> <Plug>BufTabLine.Go(6)
nmap <m-7> <Plug>BufTabLine.Go(7)
nmap <m-8> <Plug>BufTabLine.Go(8)
nmap <m-9> <Plug>BufTabLine.Go(9)
nmap <m-0> <Plug>BufTabLine.Go(10)
""""""""""""""""""""""""""""""""""""""
func MyRun()
	exec "w"
	if &filetype == 'python'
		exec 'terminal python3 %'
	endif
	if &filetype == 'php'
		exec "AsyncRun php %"
		exec "copen"
	endif
	if &filetype == 'lua'
		exec "luafile %"
	endif
endfunc
map ` :call MyRun()<cr>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if IsWin()
    if IsVim()
        function! Openterminal()
            exec "terminal"
            exec "startinsert"
        endfunction
    else
        function! Openterminal()
            exec "split term://cmd"
            exec "startinsert"
        endfunction
    endif
else
    if IsVim()
        function! Openterminal()
            exec "terminal"
            exec "startinsert"
        endfunction
    else
        function! Openterminal()
            exec "split term://bash"
            exec "startinsert"
        endfunction
    endif
endif
map <leader>g :call Openterminal()<cr>

call pathogen#infect('/neovimplugin/{}')

call plug#begin('/neovimplugin')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()
