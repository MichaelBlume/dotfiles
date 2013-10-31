execute pathogen#infect()
let g:paredit_electric_return=0
let g:slimv_swank_cmd = '! mvn clojure:swank &'
let g:lisp_rainbow = 1
au! BufWritePost .vimrc source %
set nocompatible

" create a backup of files when editing in /tmp
set backupdir=~/tmp
" swap file directory
set dir=/tmp
" color desert
color delek
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
set wildmenu
syntax on 

set tabstop=2
set shiftwidth=2
set softtabstop=2
autocmd FileType python set tabstop=4
autocmd FileType python set shiftwidth=4
autocmd FileType python set softtabstop=4
set expandtab 		
set textwidth=79

set wmnu

" set GUI font
command F set guifont=Monaco:h13

" filetype on
filetype indent on
filetype plugin on
" Tag List
" let Tlist_Auto_Open = 1
" let Tlist_Ctags_Cmd='/usr/bin/ctags'
"
command DiffOrg vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

set tags=tag,./TAGS,tags,TAGS,/opt/loggly/web/tags

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
set guifont=Monospace\ 9

map ]t cpr:Eval (run-tests)<cr>

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
