let mapleader = " "
let mapleaderlocal = " "

set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set ruler
syntax on
set mouse=a
set ignorecase
set smartcase
set incsearch
set selectmode=
set keymodel=

nnoremap U <C-r>

map <C-h> <C-w>h
map <C-l> <C-w>l
map <C-j> <C-w>j
map <C-k> <C-w>k

map <C-=> <C-w>=
map <C-+> <C-w>+
map <C--> <C-w>-
map <C->> <C-w>>
map <C-<> <C-w><

nnoremap H 20h
nnoremap J 10j
nnoremap K 10k
nnoremap L 20l

vnoremap H 20h
vnoremap J 10j
vnoremap K 10k
vnoremap L 20l

nnoremap dH 20dh
nnoremap dJ 10dj
nnoremap dK 10dk
nnoremap dL 20dl

nnoremap d "_d
nnoremap D "_D
nnoremap x "_x
nnoremap X "_X
nnoremap c "_c
nnoremap C "_C

vnoremap d "_d
vnoremap D "_D
vnoremap c "_c
vnoremap C "_C

nnoremap <Tab> :tabn<CR>
vnoremap <Tab> :tabn<CR>

nnoremap <S-Tab> :tabp<CR>
vnoremap <S-Tab> :tabp<CR>

