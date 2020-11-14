if !IsWin()
    finish
endif
if IsVim()
    let s:job=job_start('dir')
else
    "let s:job=jobstart('dir')
    let s:job=''
endif
let s:oldwinid=-1
fun! s:GoToOldwin()
   exec "close"
   call win_gotoid(s:oldwinid)
endfun
fun! FindeverythingCallback(channel,msg)
	if a:msg!=''
		let one=iconv(a:msg,"cp936","utf-8")
		if matchstr(one,'$RECYCLE.BIN')==''
		   let bname = '_Everything_Search_Result_'
		   let winnum = bufwinnr(bname)
		   if winnum == -1
			    if job_status(s:job)=='run'
                    call job_stop(s:job,'kill')
			   endif
		   elseif winnr() != winnum
			    if job_status(s:job)=='run'
                    call job_stop(s:job,'kill')
			   endif
			   return
		   else
			call append(line('$'),one)
		   endif
		endif
	endif
endfun

fun! s:QuickFixOutNvim(id,data,event)
    for itemdata in a:data
        "let two=strpart(itemdata,0,strlen(itemdata)-1)
        let two = substitute(itemdata,'','','g')
        let one=iconv(two,"cp936","utf-8")
        if matchstr(one,'$RECYCLE.BIN')==''
           let bname = '_Everything_Search_Result_'
           let winnum = bufwinnr(bname)
           if winnum == -1
                if s:job>0
                    silent! call jobstop(s:job)
                endif
           elseif winnr() != winnum
                if s:job>0
                    silent! call jobstop(s:job)
                endif
                return
           else
               if(strlen(one)>0)
                    call append(line('$'),one)
               endif
           endif
        endif
    endfor
endfun

fun! Findeverything()
    let l:fe_es_exe = 'es' 
 	let l:cmd=input('find:')
	if l:cmd==''
        return
	endif
	let l:escmd=l:fe_es_exe.' -s '.l:cmd
    if IsVim()
        if job_status(s:job)=='run'
            call job_stop(s:job,'kill')
        endif
    else
        if s:job>0
            silent! call jobstop(s:job)
        endif
    endif
    let s:oldwinid=win_getid()
    call s:ShowResult()
    if IsVim()
        let s:job=job_start(l:escmd,{'callback':'FindeverythingCallback'})
    else
        let s:job=jobstart(l:escmd,{'on_stdout':function('s:QuickFixOutNvim')})
    endif
endfun
fun! s:ShowResult()
   let bname = '_Everything_Search_Result_'
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

endfun

fun! s:Map_Keys()
   nnoremap <buffer> <silent> <CR>
            \ :call <SID>Open_Everything_File()<CR>
   nnoremap <buffer> <silent> <ESC> :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> <m-i> :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> q :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> ma :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> md :call <SID>GoToOldwin()<cr>
endfun
fun! s:Open_Internal(fname)
   let s:esc_fname_chars = ' *?[{`$%#"|!<>();&' . "'\t\n"
   let esc_fname = escape(a:fname, s:esc_fname_chars)
   let winnum = bufwinnr('^' . a:fname . '$')
   if winnum != -1
      silent! close
      let winnum = bufwinnr('^' . a:fname . '$')
      if winnum != winnr()
         exe winnum . 'wincmd w'
      endif
   else
      silent! close
      exe 'edit! ' . esc_fname
   endif
endfun
fun! s:Open_Everything_File()
   let fname = getline('.')
   if fname == ''
      return
   endif
   silent! close
   call win_gotoid(s:oldwinid)
   "call s:Open_Internal(fname)
   exe 'edit! ' . fname
endfun
command! -nargs=* FE call Findeverything()
map go :FE<cr>
