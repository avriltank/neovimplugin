let g:caller_window_id = ''
function ctags_selector#OpenTagSelector(nowword)
    " レジスタ保存
    let g:nowctagsword=a:nowword
    "let tmp = @"
    let tmp = g:nowctagsword

    " カーソル下のワードを記憶
    normal viwy

    """ 変数 taglist に ``:tselect`` の結果を格納
    let g:taglist=""
    redir => g:taglist
    "execute "silent tselect " . @"
    execute "silent! tselect " . tmp
    redir END
    if stridx(g:taglist,'时发生错误')>=0
        return
    endif
    " 呼び出し元のウィンドウ ID を記憶
    let g:caller_window_id = win_getid()

    " 新しいバッファを作成
    "if bufexists(bufnr('__CTAGS_SELECTOR_TAG_LIST__'))
        "bwipeout! __CTAGS_SELECTOR_TAG_LIST__
    "endif
    "silent bo new __CTAGS_SELECTOR_TAG_LIST__
   let bname = '__CTAGS_SELECTOR_TAG_LIST__'
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

    " タグファイルリスト取得
    let tag_files = tagfiles()

    " タグファイルの内容を読み込む
    silent put!=g:taglist
    "normal Gdddd0ggjldggdd

   "silent! %delete _
   "silent! 0put =g:taglist
   "silent! $delete _
   normal! ggdd

    " レジスタ復元
    "let @" = tmp

    """ バッファリスト用バッファの設定
    setlocal noshowcmd
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal wrap
    setlocal nonumber
    setlocal filetype=tags
    
    """ 選択したバッファに移動
    map <buffer> <Return> :call ctags_selector#OpenBuffer(g:nowctagsword)<Return>

    """ バッファリストを閉じる
    map <buffer> q :call ctags_selector#CloseTagSelector()<Return>
    map <buffer> ma :call ctags_selector#CloseTagSelector()<Return>
    map <buffer> md :call ctags_selector#CloseTagSelector()<Return>
    map <buffer> <esc> :call ctags_selector#CloseTagSelector()<Return>
endfunction

function ctags_selector#CloseTagSelector()
    """ バッファリストを閉じる
    :bwipeout!

    """ 呼び出し元ウィンドウをアクティブにする
    call win_gotoid(g:caller_window_id)
endfunction

function ctags_selector#OpenBuffer(nowword)
    if line('.') == 1
        return
    endif

    "let tag_info = ctags_selector#GetTagInfo()
    let number = ctags_selector#GetTagInfo()
    "let number = tag_info["number"]
    "let symbol_name = tag_info["symbol"]
    let symbol_name = a:nowword
    :bwipeout!

    """ 呼び出し元ウィンドウをアクティブにする
    call win_gotoid(g:caller_window_id)

    """ タグジャンプ
    execute ":" . number . "tag " . symbol_name
endfunction

function ctags_selector#GetTagInfo()
    " タグリストのナンバーを検索
    " 今いる行の先頭がうまく検索対象に入らないのでとりあえず次行に移動してる。
    normal j
    "execute '?^\d'
    execute '?\<\d\>'

    " 行を記憶
    let row = line('.')
    let line = getline(row)

    " symbol 取得
    "normal gg0
    "execute '/tag'
    normal n
    "let tag_start_col = col('.')
    "execute 'normal ' . row . 'gg'
    "execute 'normal ' . (tag_start_col) . 'le'
    "let tag_end_col = col('.')
    "let symbol = line[tag_start_col - 1 : tag_end_col]

    " number 取得
    let line = substitute(line, '\s\+', ' ', 'g')
    let splited_line = split(line, ' ')
    let number = get(splited_line, 0)
 
    return number
    "return {'number' : number, 'symbol' : symbol}
endfunction
