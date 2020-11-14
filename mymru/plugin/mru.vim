if exists('loaded_mru')
    finish
endif
let loaded_mru=1

if v:version < 700
    finish
endif

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim

" MRU configuration variables {{{1
" Maximum number of entries allowed in the MRU list
if !exists('MRU_Max_Entries')
    let MRU_Max_Entries = 300
endif

" Files to exclude from the MRU list
if !exists('MRU_Exclude_Files')
    let MRU_Exclude_Files = ''
endif

" Files to include in the MRU list
if !exists('MRU_Include_Files')
    let MRU_Include_Files = ''
endif

" Height of the MRU window
" Default height is 8
if !exists('MRU_Window_Height')
    let MRU_Window_Height = 8
endif

if !exists('MRU_Use_Current_Window')
    let MRU_Use_Current_Window = 0
endif

if !exists('MRU_Auto_Close')
    let MRU_Auto_Close = 1
endif

if !exists('MRU_File')
    if has('unix') || has('macunix')
        let MRU_File = $HOME . '/.vim_mru_files'
    else
        let MRU_File = $VIM . '/_vim_mru_files'
        if has('win32')
            " MS-Windows
            if $USERPROFILE != ''
                let MRU_File = $USERPROFILE . '\_vim_mru_files'
            endif
        endif
    endif
endif

if !exists('MRU_Max_Menu_Entries')
    let MRU_Max_Menu_Entries = 10
endif

if !exists('MRU_Max_Submenu_Entries')
    let MRU_Max_Submenu_Entries = 10
endif

if !exists('MRU_Window_Open_Always')
    let MRU_Window_Open_Always = 0
endif

if !exists('MRU_Filename_Format')
    let MRU_Filename_Format = {
        \   'formatter': 'fnamemodify(v:val, ":t") . " (" . v:val . ")"',
        \   'parser': '(\zs.*\ze)',
        \   'syntax': '^.\{-}\ze('
        \}
endif

let s:mru_list_locked = 0
let g:MRU_File = '/neovimplugin/tempmru.txt'

let s:MRU_files = []
let s:oldwinid=-1


fun! s:GoToOldwin()
   exec "close"
   call win_gotoid(s:oldwinid)
endfun

function! s:MRU_LoadList()
    if filereadable(g:MRU_File)
        let s:MRU_files = readfile(g:MRU_File)
    else
        let s:MRU_files = []
    endif

endfunction

" MRU_SaveList                          {{{1
" Saves the MRU file names to the MRU file
function! s:MRU_SaveList()
    let l = []
    call extend(l, s:MRU_files)
    call writefile(l, g:MRU_File)
endfunction

" MRU_AddFile                           {{{1
" Adds a file to the MRU file list
"   acmd_bufnr - Buffer number of the file to add
function! s:MRU_AddFile(acmd_bufnr)
    if s:mru_list_locked
        " MRU list is currently locked
        return
    endif

    " Get the full path to the filename
    let fname = fnamemodify(bufname(a:acmd_bufnr + 0), ':p')
    if fname == ''
        return
    endif

    " Skip temporary buffers with buftype set. The buftype is set for buffers
    " used by plugins.
    if &buftype != ''
        return
    endif

    if g:MRU_Include_Files != ''
        " If MRU_Include_Files is set, include only files matching the
        " specified pattern
        if fname !~# g:MRU_Include_Files
            return
        endif
    endif

    if g:MRU_Exclude_Files != ''
        " Do not add files matching the pattern specified in the
        " MRU_Exclude_Files to the MRU list
        if fname =~# g:MRU_Exclude_Files
            return
        endif
    endif

    " If the filename is not already present in the MRU list and is not
    " readable then ignore it
    let idx = index(s:MRU_files, fname)
    if idx == -1
        if !filereadable(fname)
            " File is not readable and is not in the MRU list
            return
        endif
    endif

    " Load the latest MRU file list
    call s:MRU_LoadList()

    " Remove the new file name from the existing MRU list (if already present)
    call filter(s:MRU_files, 'v:val !=# fname')

    " Add the new file list to the beginning of the updated old file list
    call insert(s:MRU_files, fname, 0)

    " Trim the list
    if len(s:MRU_files) > g:MRU_Max_Entries
        call remove(s:MRU_files, g:MRU_Max_Entries, -1)
    endif

    " Save the updated MRU list
    call s:MRU_SaveList()

    " If the MRU window is open, update the displayed MRU list
    let bname = '__MRU_Files__'
    let winnum = bufwinnr(bname)
    if winnum != -1
        let cur_winnr = winnr()
        call s:MRU_Open_Window()
        if winnr() != cur_winnr
            exe cur_winnr . 'wincmd w'
        endif
    endif
endfunction

" MRU_escape_filename                   {{{1
" Escape special characters in a filename. Special characters in file names
" that should be escaped (for security reasons)
let s:esc_filename_chars = ' *?[{`$%#"|!<>();&' . "'\t\n"
function! s:MRU_escape_filename(fname)
    if exists("*fnameescape")
        return fnameescape(a:fname)
    else
        return escape(a:fname, s:esc_filename_chars)
    endif
endfunction

" MRU_Edit_File                         {{{1
" Edit the specified file
"   filename - Name of the file to edit
"   sanitized - Specifies whether the filename is already escaped for special
"   characters or not.
function! s:MRU_Edit_File(filename, sanitized)
    if !a:sanitized
	let esc_fname = s:MRU_escape_filename(a:filename)
    else
	let esc_fname = a:filename
    endif

    " If the file is already open in one of the windows, jump to it
    let winnum = bufwinnr('^' . a:filename . '$')
    if winnum != -1
        if winnum != winnr()
            exe winnum . 'wincmd w'
        endif
    else
        if !&hidden && (&modified || &buftype != '' || &previewwindow)
            " Current buffer has unsaved changes or is a special buffer or is
            " the preview window.  The 'hidden' option is also not set.
            " So open the file in a new window.
            exe 'split ' . esc_fname
        else
            " The current file can be replaced with the selected file.
            exe 'edit ' . esc_fname
        endif
    endif
endfunction

" MRU_Window_Edit_File                  {{{1
"   fname     : Name of the file to edit. May specify single or multiple
"               files.
"   edit_type : Specifies how to edit the file. Can be one of 'edit' or 'view'.
"               'view' - Open the file as a read-only file
"               'edit' - Edit the file as a regular file
"   multi     : Specifies  whether a single file or multiple files need to be
"               opened.
"   open_type : Specifies where to open the file.
"               useopen - If the file is already present in a window, then
"                         jump to that window.  Otherwise, open the file in
"                         the previous window.
"               newwin_horiz - Open the file in a new horizontal window.
"               newwin_vert - Open the file in a new vertical window.
"               newtab  - Open the file in a new tab. If the file is already
"                         opened in a tab, then jump to that tab.
"               preview - Open the file in the preview window
function! s:MRU_Window_Edit_File(fname, multi, edit_type, open_type)
    let esc_fname = s:MRU_escape_filename(a:fname)


    " If the selected file is already open in one of the windows,
    " jump to it
    let winnum = bufwinnr('^' . a:fname . '$')
    if winnum != -1
        exe winnum . 'wincmd w'
    else
        if g:MRU_Auto_Close == 1 && g:MRU_Use_Current_Window == 0
            " Jump to the window from which the MRU window was opened
            if exists('s:MRU_last_buffer')
                let last_winnr = bufwinnr(s:MRU_last_buffer)
                if last_winnr != -1 && last_winnr != winnr()
                    exe last_winnr . 'wincmd w'
                endif
            endif
        else
            if g:MRU_Use_Current_Window == 0
                " Goto the previous window
                " If MRU_Use_Current_Window is set to one, then the
                " current window is used to open the file
                wincmd p
            endif
        endif

        let split_window = 0

        if (!&hidden && (&modified || &previewwindow)) || a:multi
            " Current buffer has unsaved changes or is the preview window
            " or the user is opening multiple files
            " So open the file in a new window
            let split_window = 1
        endif

        if &buftype != ''
            " Current buffer is a special buffer (maybe used by a plugin)
            if g:MRU_Use_Current_Window == 0 ||
                        \ bufnr('%') != bufnr('__MRU_Files__')
                let split_window = 1
            endif
        endif

        " Edit the file
        if split_window
            " Current buffer has unsaved changes or is a special buffer or
            " is the preview window.  So open the file in a new window
            if a:edit_type ==# 'edit'
                exe 'split ' . esc_fname
            else
                exe 'sview ' . esc_fname
            endif
        else
            if a:edit_type ==# 'edit'
                exe 'edit ' . esc_fname
            else
                exe 'view ' . esc_fname
            endif
        endif
    endif
endfunction


function! s:MRU_Select_File_Cmd(opt) range
    let [edit_type, open_type] = split(a:opt, ',')

    let fnames = getline(a:firstline, a:lastline)

    if g:MRU_Auto_Close == 1 && g:MRU_Use_Current_Window == 0
        " Automatically close the window if the file window is
        " not used to display the MRU list.
        silent! close
    endif

    let multi = 0

    for f in fnames
        if f == ''
            continue
        endif

        " The text in the MRU window contains the filename in parenthesis
        let file = matchstr(f, g:MRU_Filename_Format.parser)

        call s:MRU_Window_Edit_File(file, multi, edit_type, open_type)

        if a:firstline != a:lastline
            " Opening multiple files
            let multi = 1
        endif
    endfor
endfunction

" MRU_Warn_Msg                          {{{1
" Display a warning message
function! s:MRU_Warn_Msg(msg)
    echohl WarningMsg
    echo a:msg
    echohl None
endfunction

" MRU_Open_Window                       {{{1
" Display the Most Recently Used file list in a temporary window.
" If the optional argument is supplied, then it specifies the pattern of files
" to selectively display in the MRU window.
function! s:MRU_Open_Window(...)

    " Load the latest MRU file list
    call s:MRU_LoadList()

    " Check for empty MRU list
    if empty(s:MRU_files)
        call s:MRU_Warn_Msg('MRU file list is empty')
        return
    endif

    let s:oldwinid=win_getid()
    " Save the current buffer number. This is used later to open a file when a
    " entry is selected from the MRU window. The window number is not saved,
    " as the window number will change when new windows are opened.
    let s:MRU_last_buffer = bufnr('%')

    let bname = '__MRU_Files__'

    " If the window is already open, jump to it
    let winnum = bufwinnr(bname)
    if winnum != -1
        if winnr() != winnum
            " If not already in the window, jump to it
            exe winnum . 'wincmd w'
        endif

        setlocal modifiable

        " Delete the contents of the buffer to the black-hole register
        silent! %delete _
    else
        if g:MRU_Use_Current_Window
            " Reuse the current window
            "
            " If the __MRU_Files__ buffer exists, then reuse it. Otherwise open
            " a new buffer
            let bufnum = bufnr(bname)
            if bufnum == -1
                let cmd = 'edit ' . bname
            else
                let cmd = 'buffer ' . bufnum
            endif

            exe cmd

            if bufnr('%') != bufnr(bname)
                " Failed to edit the MRU buffer
                return
            endif
        else
            " Open a new window at the bottom

            " If the __MRU_Files__ buffer exists, then reuse it. Otherwise open
            " a new buffer
            let bufnum = bufnr(bname)
            if bufnum == -1
                let wcmd = bname
            else
                let wcmd = '+buffer' . bufnum
            endif

            exe 'silent! botright ' . g:MRU_Window_Height . 'split ' . wcmd
        endif
    endif

    setlocal modifiable

    " Mark the buffer as scratch
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nowrap
    setlocal nobuflisted
    " Set the 'filetype' to 'mru'. This allows the user to apply custom
    " syntax highlighting or other changes to the MRU bufer.
    setlocal filetype=mru
    " Use fixed height for the MRU window
    setlocal winfixheight

    " Setup the cpoptions properly for the maps to work
    let old_cpoptions = &cpoptions
    set cpoptions&vim

    " Create mappings to select and edit a file from the MRU list
    nnoremap <buffer> <silent> <CR>
                \ :call <SID>MRU_Select_File_Cmd('edit,useopen')<CR>
    vnoremap <buffer> <silent> <CR>
                \ :call <SID>MRU_Select_File_Cmd('edit,useopen')<CR>
    nnoremap <buffer> <silent> u :MRU<CR>
    nnoremap <buffer> <silent> <2-LeftMouse>
                \ :call <SID>MRU_Select_File_Cmd('edit,useopen')<CR>
   nnoremap <buffer> <silent> <ESC> :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> <m-i> :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> q :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> ma :call <SID>GoToOldwin()<cr>
   nnoremap <buffer> <silent> md :call <SID>GoToOldwin()<cr>

    " Restore the previous cpoptions settings
    let &cpoptions = old_cpoptions

    " Display the MRU list
    if a:0 == 0
        " No search pattern specified. Display the complete list
        let m = copy(s:MRU_files)
    else
        " Display only the entries matching the specified pattern
	" First try using it as a literal pattern
	let m = filter(copy(s:MRU_files), 'stridx(v:val, a:1) != -1')
	if len(m) == 0
	    " No match. Try using it as a regular expression
	    let m = filter(copy(s:MRU_files), 'v:val =~# a:1')
	endif
    endif

    " Get the tail part of the file name (without the directory) and display
    " it along with the full path in parenthesis.
    let  output = map(m, g:MRU_Filename_Format.formatter)
    silent! 0put =output

    " Delete the empty line at the end of the buffer
    silent! $delete _

    " Move the cursor to the beginning of the file
    normal! gg

    " Add syntax highlighting for the file names
    if has_key(g:MRU_Filename_Format, 'syntax')
        exe "syntax match MRUFileName '" . g:MRU_Filename_Format.syntax . "'"
        highlight default link MRUFileName Identifier
    endif

    setlocal nomodifiable
endfunction

" MRU_Complete                          {{{1
" Command-line completion function used by :MRU command
function! s:MRU_Complete(ArgLead, CmdLine, CursorPos)
    if a:ArgLead == ''
        " Return the complete list of MRU files
        return s:MRU_files
    else
        " Return only the files matching the specified pattern
        return filter(copy(s:MRU_files), 'v:val =~? a:ArgLead')
    endif
endfunction

" MRU_Cmd                               {{{1
" Function to handle the MRU command
"   pat - File name pattern passed to the MRU command
function! s:MRU_Cmd(pat)
    if a:pat == ''
        " No arguments specified. Open the MRU window
        call s:MRU_Open_Window()
        return
    endif

    " Load the latest MRU file
    call s:MRU_LoadList()

    " Empty MRU list
    if empty(s:MRU_files)
        call s:MRU_Warn_Msg('MRU file list is empty')
        return
    endif

    " First use the specified string as a literal string and search for
    " filenames containing the string. If only one filename is found,
    " then edit it (unless the user wants to open the MRU window always)
    let m = filter(copy(s:MRU_files), 'stridx(v:val, a:pat) != -1')
    if len(m) > 0
	if len(m) == 1 && !g:MRU_Window_Open_Always
	    call s:MRU_Edit_File(m[0], 0)
	    return
	endif

	" More than one file matches. Try find an accurate match
	let new_m = filter(m, 'v:val ==# a:pat')
	if len(new_m) == 1 && !g:MRU_Window_Open_Always
	    call s:MRU_Edit_File(new_m[0], 0)
	    return
	endif

	" Couldn't find an exact match, open the MRU window with all the
        " files matching the pattern.
	call s:MRU_Open_Window(a:pat)
	return
    endif

    " Use the specified string as a regular expression pattern and search
    " for filenames matching the pattern
    let m = filter(copy(s:MRU_files), 'v:val =~? a:pat')

    if len(m) == 0
        " If an existing file (not present in the MRU list) is specified,
        " then open the file.
        if filereadable(a:pat)
            call s:MRU_Edit_File(a:pat, 0)
            return
        endif

        " No filenames matching the specified pattern are found
        call s:MRU_Warn_Msg("MRU file list doesn't contain " .
                    \ "files matching " . a:pat)
        return
    endif

    if len(m) == 1 && !g:MRU_Window_Open_Always
        call s:MRU_Edit_File(m[0], 0)
        return
    endif

    call s:MRU_Open_Window(a:pat)
endfunction

" Load the MRU list on plugin startup
call s:MRU_LoadList()

" MRU autocommands {{{1
" Autocommands to detect the most recently used files
autocmd BufRead * call s:MRU_AddFile(expand('<abuf>'))
autocmd BufNewFile * call s:MRU_AddFile(expand('<abuf>'))
autocmd BufWritePost * call s:MRU_AddFile(expand('<abuf>'))

" The ':vimgrep' command adds all the files searched to the buffer list.
" This also modifies the MRU list, even though the user didn't edit the
" files. Use the following autocmds to prevent this.
autocmd QuickFixCmdPre *vimgrep* let s:mru_list_locked = 1
autocmd QuickFixCmdPost *vimgrep* let s:mru_list_locked = 0

" Command to open the MRU window
command! -nargs=? -complete=customlist,s:MRU_Complete MRU
            \ call s:MRU_Cmd(<q-args>)

map ,f :MRU<cr>
" }}}

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set foldenable foldmethod=marker:
