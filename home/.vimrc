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
nnoremap <Up> 10k
nnoremap <Down> 10j
nnoremap <Left> 20h
nnoremap <Right> 20l

nnoremap <M-h> 20h
nnoremap <M-j> 10j
nnoremap <M-k> 10k
nnoremap <M-l> 20l

nnoremap H 20h
nnoremap J 10j
nnoremap K 10k
nnoremap L 20l

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
