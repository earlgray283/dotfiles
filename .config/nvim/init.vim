set number
set autoindent
set tabstop=4
set shiftwidth=4
set title

call plug#begin('~/.vim/plugged')
	Plug 'rust-lang/rust.vim'
	Plug 'neoclide/coc.nvim'
	Plug 'vim-scripts/vim-auto-save'
	Plug 'hzchirs/vim-material'
	Plug 'morhetz/gruvbox'
	Plug 'preservim/nerdtree'
	Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
	Plug 'octol/vim-cpp-enhanced-highlight'
call plug#end()

syntax enable
filetype plugin indent on

" color
set background=dark
colorscheme gruvbox
set t_Co=256
hi Pmenu ctermbg=153 ctermfg=0
hi PmenuSel ctermbg=44i

" Screen
set laststatus=2


" ???
let g:rustfmt_autosave = 1
