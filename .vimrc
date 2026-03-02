set nocompatible              " required
filetype off                  " required

" Leader key (set early so mappings that use <leader> work)
let mapleader=","

" Use vim-plug as plugin manager (faster, parallel installs)
if empty(glob('~/.vim/autoload/plug.vim'))
    " If vim-plug isn't installed, user can run: \
    " curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    " https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
call plug#begin('~/.vim/plugged')
Plug 'tmhedberg/SimpylFold'
Plug 'vim-scripts/indentpython.vim'
Plug 'dense-analysis/ale'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-obsession'
Plug 'airblade/vim-rooter'
Plug 'mhinz/vim-startify'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'preservim/tagbar'
call plug#end()

filetype plugin indent on    " required

set number
set relativenumber

set clipboard=unnamed

" Persistent undo, backups and swap (keeps history and avoids data loss)
if !isdirectory(expand('~/.vim/undo'))
    call mkdir(expand('~/.vim/undo'), 'p')
endif
if !isdirectory(expand('~/.vim/backup'))
    call mkdir(expand('~/.vim/backup'), 'p')
endif
if !isdirectory(expand('~/.vim/swap'))
    call mkdir(expand('~/.vim/swap'), 'p')
endif
set undodir=~/.vim/undo//
set undofile
set backup
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//

" Performance and UI tweaks
set lazyredraw
set ttyfast
set updatetime=300
set termguicolors
set signcolumn=yes
set cursorline

" shortcuts
inoremap jk <ESC>
" Enable folding with the spacebar
nnoremap <space> za

" Tagbar: symbol sidebar (toggle with <F8>)
nnoremap <F8> :TagbarToggle<CR>

" Session / project management
" Toggle recording a session with Obsession
nnoremap <leader>ss :Obsession<CR>
" Save current session to Session.vim
nnoremap <leader>sl :mksession! Session.vim<CR>
" Load session
nnoremap <leader>so :source Session.vim<CR>

" Rooter: change cwd to project root (looks for .git, pyproject.toml, etc.)
let g:rooter_patterns = ['.git', 'pyproject.toml', 'setup.cfg', 'Pipfile', 'pyproject.toml']

" Startify: show recent sessions and bookmarks on startup
let g:startify_session_autoload = 1
let g:startify_session_dir = '~/.vim/sessions'

" Formatting / Fixing
nnoremap <leader>f :ALEFix<CR>
command! RuffFix ALEFix

" Spell toggle (useful for docs/README)
nnoremap <leader>z :setlocal spell!<CR>

" Safety & portability
set modelines=0
set fileencodings=utf-8,latin1

" split navigations
set splitbelow
set splitright

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" set noswapfile
set hlsearch
set ignorecase
set incsearch

" theme
" colorscheme gruvbox
set bg=dark

" Enable folding (key: za)
set foldmethod=indent
set foldlevel=99

" let g:SimpylFold_docstring_preview=1

augroup filetype_settings
    autocmd!
    autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent fileformat=unix
    autocmd FileType javascript,html,css setlocal tabstop=2 softtabstop=2 shiftwidth=2
    autocmd FileType lua setlocal tabstop=3 softtabstop=3 shiftwidth=3 expandtab autoindent
augroup END

augroup trim_whitespace
    autocmd!
    autocmd BufWritePre *.py,*.js,*.html,*.css,*.lua %s/\s\+$//e
augroup END

"Flagging Unnecessary Whitespace
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" set cursorline
set showmatch
set encoding=utf-8

" ALE (async linting/fixing) + Ruff integration
let g:ale_linters = { 'python': ['ruff'] }
let g:ale_fixers = { 'python': ['ruff'] }
let g:ale_fix_on_save = 1

" Try to detect project virtualenvs and set python3 host for plugins
function! s:FindVenvPython()
    if !empty($VIRTUAL_ENV)
        return $VIRTUAL_ENV . '/bin/python'
    endif
    let l:dir = expand('%:p:h')
    while !empty(l:dir) && l:dir !=# '/'
        if filereadable(l:dir . '/.venv/bin/python')
            return l:dir . '/.venv/bin/python'
        endif
        let l:dir = fnamemodify(l:dir, ':h')
    endwhile
    return ''
endfunction

let s:venv_python = s:FindVenvPython()
if !empty(s:venv_python)
    let g:python3_host_prog = s:venv_python
endif
autocmd BufEnter * let g:python3_host_prog = s:FindVenvPython()

" enable all Python syntax highlighting features
let python_highlight_all = 1
syntax on

"ignore files in NERDTree
let NERDTreeIgnore=['\.pyc$', '\~$']

" Improve cursor visibility (GUI + terminal)
" - GUI: explicit `guicursor` shape + visible `Cursor` highlight
" - Terminal: keep `cursorline` and stronger `CursorLine` background
if has('gui_running') || has('nvim')
    if exists('+guicursor')
        set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
    endif
    highlight Cursor guibg=Yellow guifg=Black
else
    set cursorline
    highlight CursorLine cterm=none ctermbg=236 guibg=#3e4451
    " If your terminal supports changing the cursor color via OSC:
    " Uncomment and set `g:cursor_color` (e.g. '#f8f8f2') then run the printf line.
    " let g:cursor_color = '#f8f8f2'
    " execute printf('\e]12;%s\a', g:cursor_color)
endif
