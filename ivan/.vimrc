" Ivan's .vimrc file
" ivan@hipnik.net

" important settings
set nocompatible

" reading/writing files
set modeline
set modelines=10
set nobackup

" messages, info
set ruler
set visualbell

" syntax, highlighting
syntax on

" tabs, indenting
set autoindent
set smartindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" editing text
set backspace=indent,eol,start
set showmatch

" searching 
set smartcase
set ignorecase
set hlsearch

" multiple windows
set splitbelow
set splitright

" GUI
colorscheme desert
set guioptions=aeimtr
    " a = autoselect
    " e = show guitabline
    " m = menubar
    " L = left scrollbar when vertically split
    " r = right scrollbar

" python files
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,with,try,except,finally,def,class
