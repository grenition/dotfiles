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


" Russian keys
map й q
map ц w
map у e
map к r
map е t
map н y
map г u
map ш i
map щ o
map з p
map х [
map ъ ]

map Й Q
map Ц W
map У E
map К R
map Е T
map Н Y
map Г U
map Ш I
map Щ O
map З P
map Х {
map Ъ }

map ф a
map ы s
map в d
map а f
map п g
map р h
map о j
map л k
map д l
map ж ;
map э '

map Ф A
map Ы S
map В D
map А F
map П G
map Р H
map О J
map Л K
map Д L
map Ж :
map Э "

map я z
map ч x
map с c
map м v
map и b
map т n
map ь m
map б ,
map ю .

map Я Z
map Ч X
map С C
map М V
map И B
map Т N
map Ь M
map Б <
map Ю >

