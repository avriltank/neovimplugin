let s:nowpath=""
let s:oldwinid=-1

fun! s:RgGrepOnline()
   let grepfrom=getline(".")
   exec "close"
   call win_gotoid(s:oldwinid)
   let g:workdir=grepfrom
endfun
fun! s:GoToOldwin()
   exec "close"
   call win_gotoid(s:oldwinid)
endfun
fun! s:Map_Keys()
   nnoremap <buffer> <silent> <CR>
	    \ :call <SID>RgGrepOnline()<CR>
   nnoremap <buffer> <silent> <ESC> :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> <m-i> :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> q :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> ma :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> md :call <SID>GoToOldwin()<cr>
endfun

fun! s:ShowResult(result)
   let bname = '_ctags_make_from_'
   let winnum = bufwinnr(bname)
   if winnum != -1
      if winnr() != winnum
	 exe winnum . 'wincmd w'
      endif
      setlocal modifiable
      silent! %delete _
   else
      let bufnum = bufnr(bname)
      if bufnum == -1
	 let wcmd = bname
      else
	 let wcmd = '+buffer' . bufnum
      endif
      exe 'silent! botright ' . '10' . 'split ' . wcmd
   endif
   setlocal buftype=nofile
   setlocal noswapfile
   setlocal nowrap
   setlocal nobuflisted
   setlocal winfixheight
   setlocal modifiable

   let old_cpoptions = &cpoptions
   set cpoptions&vim
   call s:Map_Keys()
   let &cpoptions = old_cpoptions
   silent! %delete _
   silent! 0put =a:result
   silent! $delete _
   normal! gg


endfun


function! s:GetNowPath()
    "let l:dname = getcwd()
    let s:oldwinid=win_getid()
    let l:dname = expand('%:p:h')
    let l:dname = substitute(l:dname,'\\','/','g')
    let l:result=l:dname
    while isdirectory(l:dname)
	let l:dname = strpart(l:dname, 0, strridx(l:dname, "/"))
	let l:result.="\n"
	let l:result.=l:dname
    endwhile
    let l:result=strpart(l:result,0,strlen(l:result)-1)
    let l:result.="/"
    return l:result
endfunction

function! s:Aggrep()
	let s:nowpath=s:GetNowPath()
	call s:ShowResult(s:nowpath)
endfunction
nnoremap  ,e :call <SID>Aggrep()<CR>

