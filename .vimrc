set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'luochen1990/rainbow' "rainbow parens
let g:rainbow_active = 1
Plugin 'kovisoft/paredit' "essential
Plugin 'tpope/vim-fireplace'
Plugin 'guns/vim-clojure-static'
Plugin 'airblade/vim-gitgutter' "This is nice to see what you've modified and not
" for gitgutter
highlight clear SignColumn

call vundle#end()            " required
filetype plugin indent on    " required




" let g:paredit_electric_return=0
" let g:lisp_rainbow = 1

" create a backup of files when editing in /tmp
set backupdir=~/tmp
" swap file directory
set dir=/tmp
set background=dark
highlight LineNr  term=NONE
set backspace=indent,eol,start
set autoindent
set smartindent
set ignorecase
set smartcase
set ruler
set showmatch
set showmode
set hlsearch
set incsearch
set nopaste
set number
set esckeys
set wildmode=longest,list,full
syntax on 

set tabstop=2
set shiftwidth=2
set softtabstop=2
autocmd FileType python set tabstop=4
autocmd FileType python set shiftwidth=4
autocmd FileType python set softtabstop=4
set expandtab 		
set textwidth=79

" filetype on
filetype indent on
filetype plugin on
" Tag List
" let Tlist_Auto_Open = 1
" let Tlist_Ctags_Cmd='/usr/bin/ctags'
"
let python_highlight_all=1
set completeopt+=longest
set foldmethod=indent
set nofoldenable

" Django/Python Coding
"remap code complete to ctrl space
autocmd FileType python inoremap <S-Tab> <C-x><C-o>

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType python inoremap # X#

"no toolbar
set guioptions-=T
"no scrollbar
set guioptions-=r
set guioptions-=L
"autoselect. Always.
set guioptions+=A

colorscheme koehler
set guifont=Source\ Code\ Pro\ Medium:h14

map <C-t> :update<cr>:Eval (do (require 'mike) (mike/run-all-tests))<cr>
