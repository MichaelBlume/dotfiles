set nocompatible
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin('~/.vundle')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'luochen1990/rainbow' "rainbow parens
let g:rainbow_active = 1
let g:paredit_matchlines = 200
Plugin 'kovisoft/paredit' "essential
Plugin 'tpope/vim-fireplace'
Plugin 'guns/vim-clojure-static'
Plugin 'udalov/kotlin-vim'
Plugin 'guns/vim-clojure-highlight'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
let g:clojure_align_multiline_strings = 1
let g:jsx_ext_required = 0
nmap cpP :Eval <CR>
Plugin 'airblade/vim-gitgutter' "This is nice to see what you've modified and not
" for gitgutter
highlight clear SignColumn

Plugin 'tpope/vim-fugitive'

Plugin 'bling/vim-airline' "nice status line stuff
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
set laststatus=2
let g:airline_theme='dark'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '◀'
let g:airline_symbols.branch = '⎇ '
let g:airline_section_y = ""
let g:airline_section_x = ""


Plugin 'wting/rust.vim'


call vundle#end()            " required
filetype plugin indent on    " required



" " to select autocomplete results with j/k
inoremap <expr> j ((pumvisible())?("\<C-n>"):("j"))
inoremap <expr> k ((pumvisible())?("\<C-p>"):("k"))
set complete-=i

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
set wildmode=list:longest

set wildmenu

if exists("&wildignorecase")
  set wildignorecase
endif

syntax on 

set tabstop=2
set shiftwidth=2
set softtabstop=2
autocmd FileType python set tabstop=4
autocmd FileType python set shiftwidth=4
autocmd FileType python set softtabstop=4
autocmd FileType rust set tabstop=4
autocmd FileType rust set shiftwidth=4
autocmd FileType rust set softtabstop=4
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
" set guifont=Source\ Code\ Pro\ Medium:h14

map <C-t> :update<cr>:Eval (do (require 'editor-fns) (editor-fns/run-all-tests))<cr>
map <C-n> :update<cr>:Eval (do (require 'clojure.tools.namespace.repl) (clojure.tools.namespace.repl/refresh))<cr>
autocmd BufNewFile,BufRead *.cljc,*.cljx,*.cljs setlocal filetype=clojure

" Octave syntax
augroup filetypedetect
  au! BufRead,BufNewFile *.m,*.oct set filetype=octave
augroup END
