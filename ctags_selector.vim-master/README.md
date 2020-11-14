ctags_selector.vim
==================

シンプルで簡単に使えるタグセレクターです。

Usage:
------

`ctags_selector#OpenTagSelector()` を、お好みのキーにマッピングしてください。

`ctags_selector#OpenTagSelector()` を実行すると、ファイル絞り込み用バッファーが開きます。
ファイル絞り込み用バッファーには、カレントディレクトリ以下のファイルを再帰的に取得した一覧が表示されます。

設定例 :

```vim
nnoremap <C-]> :call ctags_selector#OpenTagSelector()<Enter>
```


License:
--------

Copyright (C) 2017 mikoto2000

This software is released under the MIT License, see LICENSE

このソフトウェアは MIT ライセンスの下で公開されています。 LICENSE を参照してください。


Author:
-------

mikoto2000 <mikoto2000@gmail.com>
