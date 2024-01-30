set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching
set ignorecase              " case insensitive
"set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set smarttab
set autoindent              " indent a new line the same amount as the line just typed
set wildmode=longest,list   " get bash-like tab completions
"set cc=80                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
"set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
set noswapfile


call plug#begin()
 Plug 'liuchengxu/vista.vim'
 Plug 'tpope/vim-dispatch'
 Plug 'dracula/vim'
 "Plug 'ryanoasis/vim-devicons'
 "Plug 'SirVer/ultisnips'
 "Plug 'honza/vim-snippets'
 Plug 'scrooloose/nerdtree'
 Plug 'preservim/nerdcommenter'
 Plug 'mhinz/vim-startify'
 "Plug 'neoclide/coc.nvim', {'branch': 'release'}
 Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
 Plug 'junegunn/fzf.vim'
 Plug 'ericcurtin/CurtineIncSw.vim'
 Plug 'morhetz/gruvbox'
 Plug 'vim-airline/vim-airline'
 Plug 'vim-airline/vim-airline-themes'
 Plug 'rust-lang/rust.vim'
 Plug 'mattn/webapi-vim'
 Plug 'dense-analysis/ale'
 Plug 'rust-lang/rust.vim'

 let g:ale_pattern_options = {'\.sql$': {'ale_enabled': 0}}
call plug#end()

let mapleader = " "
set timeoutlen=500
colorscheme gruvbox

map <leader>t :NERDTreeToggle<CR>
map <leader>f :Files<CR>

function! s:JbzClangFormat(first, last)
  let l:winview = winsaveview()
  execute a:first . "," . a:last . "!clang-format"
  call winrestview(l:winview)
endfunction
command! -range=% JbzClangFormat call <sid>JbzClangFormat (<line1>, <line2>)

au FileType c,cpp nnoremap <buffer><leader>lf :<C-u>JbzClangFormat<CR>
au FileType c,cpp vnoremap <buffer><leader>lf :JbzClangFormat<CR>

nnoremap <silent> <Leader>ag :Ag <C-R><C-W><CR>
nnoremap <silent> <Leader>o :call CurtineIncSw()<CR>
nnoremap <silent> <Leader>b :Buffers<CR>
set t_Co=256

let g:rustfmt_autosave = 1
let g:rust_clip_command = 'pbcopy'


set background=dark
set number                  " add line numbers
set hls


nnoremap <leader>l :exec '!arc lint -a'<cr>
autocmd BufNewFile,BufRead TARGETS setlocal includeexpr=substitute(v:fname,'//\\(.*\\)','\\1/TARGETS','g')
nmap <leader>w :tabnew `~/scripts/tgt.sh %`<cr>

nmap <silent> <leader>z :History<cr>
"let g:ale_fix_on_save = 1

let g:ale_fixers = { 'cpp': ['clang-format'], }
let g:ale_linters = {'rust': ['analyzer']}

function! Fold_Includes(ln)
  let cur_line = getline(a:ln)
  let prev_line = getline(a:ln - 1)

  " skip empty lines
  let empty_regex = '^\s*$'
  if cur_line =~ empty_regex
    return -1
  endif

  if cur_line[:8] == '#include '
    return (prev_line[:8] == '#include ' ||
          \ prev_line =~ empty_regex) ? 1 : '>1'
  endif

  if cur_line[:9] == 'namespace '
    return prev_line[:9] == 'namespace ' ? 1 : '>1'
  endif

  let end_ns_regex = '^}}*\s*//\s*namespace'
  if cur_line =~ end_ns_regex
    return prev_line =~ end_ns_regex ? 1 : '>1'
  endif

  return 0
endfunction

au FileType c,cpp setlocal foldexpr=Fold_Includes(v:lnum) foldmethod=expr
let g:airline#extensions#tabline#enabled = 1
nnoremap <silent> <Leader>ag :Ag <C-R><C-W><CR>

set mouse=a                 " enable mouse click
command -nargs=* Cargo cex system("cargo <args>")
set pastetoggle=<F2>
vmap <C-c> :w !pbcopy<CR><CR>
