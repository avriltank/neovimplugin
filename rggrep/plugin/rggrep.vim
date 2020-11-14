let s:grepword=""
let s:nowpath=""
if IsWin()
    let s:mingling = 'dir'
else
    let s:mingling = 'ls'
endif
if IsVim()
    let s:job=job_start(s:mingling)
else
    "let s:job=jobstart(s:mingling)
    let s:job=''
endif

let s:oldwinid=-1
fun! s:GoToOldwin()
   exec "close"
   call win_gotoid(s:oldwinid)
endfun

function! s:ClearNewline(s)
    if empty(a:s)
        return a:s
    endif

    let lastchar = strlen(a:s)-1
    if char2nr(a:s[lastchar]) == 10
        return strpart(a:s, 0, lastchar)
    endif

    return a:s
endfunction

function! s:GetCurrentSelection()
    return s:ClearNewline(@")
endfunction
function! s:GetCurrentWord()
    return expand("<cword>")
endfunction

fun! QuickFixOut(channel,msg)
	caddexpr a:msg
endfun
fun! s:QuickFixOutNvim(id,data,event)
    let size = getqflist({'size' : 1}).size
    if size> 1000
        call s:StopJob()
        return
    endif
    caddexpr a:data
endfun

fun! s:RgGrepOnline()
   let grepfrom=getline(".")
   exec "close"
   if IsVim()
       if job_status(s:job)=='run'
            call job_stop(s:job,'kill')
       endif
   else
        if s:job>0
            silent! call jobstop(s:job)
        endif
   endif
   call setqflist([])
   let &errorformat="%f:%l:%c:%m"
   exec "copen"
   let grepcmd="rg --hidden --max-filesize 1M --mmap --vimgrep "
   let grepcmd.='"'
   let grepcmd.=s:grepword
   let grepcmd.='" "'
   let grepcmd.=grepfrom
   let grepcmd.='"'
   if IsVim()
       let s:job=job_start(grepcmd,{'out_cb':'QuickFixOut'})
   else
       let s:job=jobstart(grepcmd,{'on_stdout':function('s:QuickFixOutNvim')})
   endif
endfun
fun! s:StopJob()
    if IsVim()
       if job_status(s:job)=='run'
        call job_stop(s:job,'kill')
        echo "job is stopped!ok"
       else
           echo "no job is run"
       endif
    else
        if s:job>0
            silent! call jobstop(s:job)
            echo "job is stopped!ok"
        else
            echo "no job is run"
        endif
    endif
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
   let bname = '_Grep_Search_from_'
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

function! s:Aggrep(mode)
	if a:mode==0
		let s:grepword=s:GetCurrentWord()
	endif
	if a:mode==1
		let s:grepword=s:GetCurrentSelection()
	endif
	let s:grepword=escape(s:grepword,'#^&*()-+[{]}|.?$"\\')
	let s:nowpath=s:GetNowPath()
	call s:ShowResult(s:nowpath)
endfunction
nnoremap  mf :call <SID>Aggrep(0)<CR>
vmap  mf y:call <sid>Aggrep(1)<cr>
nnoremap  ,s :call <SID>StopJob()<CR>
fun! s:RgGrepOnlinecmd(...)
   if(len(a:000)==0)
	let grepword=expand('<cword>')
	   let grepword=escape(grepword,'#^&*()-+[{]}|.?$\\"')
	   let grepfrom=escape(getcwd(),'\')
	   let grepcmd="rg --vimgrep "
	   let grepcmd.='"'
	   let grepcmd.=grepword
	   let grepcmd.='" "'
	   let grepcmd.=grepfrom
	   let grepcmd.='"'
       if IsVim()
           if job_status(s:job)=='run'
            call job_stop(s:job,'kill')
           endif
       else
            if s:job>0
                silent! call jobstop(s:job)
            endif
        endif
	   call setqflist([])
	   exec "copen"
       if IsVim()
           let s:job=job_start(grepcmd,{'out_cb':'QuickFixOut'})
       else
           let s:job=jobstart(grepcmd,{'on_stdout':function('s:QuickFixOutNvim')})
       endif
   else
	   let grepword=escape(a:1,'#^&*()-+[{]}|.?$\\"')
	   let grepfrom=escape(a:2,'\')
	   let grepcmd="rg --vimgrep "
	   let grepcmd.='"'
	   let grepcmd.=grepword
	   let grepcmd.='" "'
	   let grepcmd.=grepfrom
	   let grepcmd.='"'
       if IsVim()
           if job_status(s:job)=='run'
            call job_stop(s:job,'kill')
           endif
       else
            if s:job>0
                silent! call jobstop(s:job)
            endif
        endif
	   call setqflist([])
	   exec "copen"
       if IsVim()
           let s:job=job_start(grepcmd,{'out_cb':'QuickFixOut'})
       else
           let s:job=jobstart(grepcmd,{'on_stdout':function('s:QuickFixOutNvim')})
       endif

   endif
endfun

command! -nargs=* -complete=file Rgg call <sid>RgGrepOnlinecmd(<f-args>)
