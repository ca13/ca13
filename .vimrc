" DESCRIPTION
" =============================================================================

"                    __ ____    _____        _    __ _ _
"                   /_ |___ \  |  __ \      | |  / _(_) |
"            ___ __ _| | __) | | |  | | ___ | |_| |_ _| | ___  ___
"           / __/ _` | ||__ <  | |  | |/ _ \| __|  _| | |/ _ \/ __|
"          | (_| (_| | |___) | | |__| | (_) | |_| | | | |  __/\__ \
"           \___\__,_|_|____/  |_____/ \___/ \__|_| |_|_|\___||___/


" INIT
" =============================================================================
" Skip initialisation for Vim Tiny/Small
if !1 | finish | endif

set nocompatible
set encoding=utf-8
set fileencoding=utf-8
scriptencoding utf-8


" ENVIRONMENT
" =============================================================================
" OS
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
silent function! OSX()
  return (has('macunix')  || has('mac') || has('gui_macvim'))
endfunction

silent function! LINUX()
  return has('unix') && !has('macunix') && !has('win32unix')
endfunction

silent function! WINDOWS()
  return (has('win16') || has('win32') || has('win64'))
endfunction

silent function! CYGWIN()
  return (has('win32unix') || has('win64unix'))
endfunction

silent function! MSYSGIT()
  return (has('win32') || has('win64')) && $TERM ==? 'cygwin'
endfunction

silent function! GUI()
  return (has('gui_running') || strlen(&term) == 0 || &term ==? 'builtin_gui')
endfunction

silent function! NVIM()
  return has('nvim')
endfunction


" Shell
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if WINDOWS()
  set shell=c:\windows\system32\cmd.exe
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
else
  set shell=/bin/sh
endif


" Variables
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
let s:is_msys = ($MSYSTEM =~? 'MINGW\d\d')



" HELPERS
" =============================================================================
" Create directory
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! CreateDir(path)
  "trim
  let l:path = expand(substitute(a:path,  '\s\+', '', 'g'), 1)

  if empty(l:path)
    echom "CreateDir(): invalid path: ".a:path
    return 0 "path is empty/blank.
  endif

  if !isdirectory(l:path)
    call mkdir(l:path, 'p')
  endif
  return isdirectory(l:path)
endfunction


" Create file
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! CreateFile(path)
  let l:path = expand(a:path, 1)
  if !filereadable(l:path) && -1 == writefile([''], l:path)
    echoerr "failed to create file: ".l:path
  endif
endfunction


" Create swap, backup, undo dirs
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
let s:cache_dir = empty($XDG_DATA_HOME) ? '~/.cache/.vim' : $XDG_DATA_HOME.'/.vim'
call CreateDir(s:cache_dir)

if isdirectory(expand(s:cache_dir, 1))
  call CreateDir(s:cache_dir . '/swap/')
  call CreateDir(s:cache_dir . '/backup/')
  call CreateDir(s:cache_dir . '/undo/')
  call CreateDir(s:cache_dir . '/views/')

  let &directory = expand(s:cache_dir, 1) . '/swap/'
  let &viewdir = expand(s:cache_dir, 1) . '/views/'
  au BufWinLeave * silent! mkview
  au BufWinEnter * silent! loadview

  set backup
  let &backupdir = expand(s:cache_dir, 1) . '/backup/'

  if has("persistent_undo")
    set undofile
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
    let &undodir = expand(s:cache_dir, 1) . '/undo/'
  endif
endif


" Create bundle directory
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
let s:bundle_dir = '~/.vim/bundle'
if !isdirectory(expand(s:bundle_dir, 1))
  call CreateDir(s:bundle_dir)
endif



" VIM-PLUG
" =============================================================================
" Auto-Install Vim-Plug
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !mkdir -p ~/.vim/autoload
  silent !curl -fLo ~/.vim/autoload/plug.vim
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif


" Begin Plugins Install
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
call plug#begin(expand(s:bundle_dir, 1))

" Core
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if executable('ag')
  Plug 'mileszs/ack.vim'
  let g:ackprg = 'ag --nogroup --color --column --smart-case'
elseif executable('ack-grep')
  let g:ackprg="ack-grep -H --color --nogroup --column"
  Plug 'mileszs/ack.vim'
elseif executable('ack')
  Plug 'mileszs/ack.vim'
endif


" Tmux
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if executable('tmux')
  Plug 'tpope/vim-tbone'
  Plug 'wellle/tmux-complete.vim'
  let g:tmuxcomplete#trigger = ''
endif


" g:ca13_bundle_groups
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if !exists('g:ca13_bundle_groups')
    let g:ca13_bundle_groups=[ 'general', 'programming', 'neocomplete', 'blade', 'c', 'csv', 'docker', 'go', 'html', 'javascript', 'nginx', 'php', 'python', 'ruby', 'scala', 'sql', 'writting' ]
endif


" g:override_ca13_bundles
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if !exists("g:override_ca13_bundles")

  " General
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'general')
    Plug 'tomasr/molokai'
    Plug 'altercation/vim-colors-solarized'
    Plug 'bling/vim-airline'
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'
    Plug 'mhinz/vim-signify'
    Plug 'MattesGroeger/vim-bookmarks'
    Plug 'tpope/vim-obsession'
    "Plug 'xolox/vim-session' | Plug 'xolox/vim-misc'
    Plug 'kien/ctrlp.vim' | Plug 'tacahiroy/ctrlp-funky'
    Plug 'Shougo/vimshell.vim'

  endif


  " Programming
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'programming')
    Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesEnable' }
    Plug 'tpope/vim-surround'
    Plug 'tomtom/tcomment_vim'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'joonty/vim-sauce'
    Plug 'ervandew/supertab'
    Plug 'sheerun/vim-polyglot'
    Plug 'Scrooloose/Syntastic'
    if executable('ctags')
      "Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
    endif
  endif


  " Snippets & AutoComplete
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'snipmate')
    Plug 'garbas/vim-snipmate'
    Plug 'honza/vim-snippets'
    " Source support_function.vim to support vim-snippets.
    if filereadable(expand(expand(s:bundle_dir, 1) . '/vim-snippets/snippets/support_functions.vim'))
      source expand(s:bundle_dir, 1) . '/vim-snippets/snippets/support_functions.vim'
    endif
  elseif count(g:ca13_bundle_groups, 'youcompleteme')
    Plug 'Valloric/YouCompleteMe', { 'do': './install.sh --clang-completer' } " Code Completion and Inline errors
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
  elseif count(g:ca13_bundle_groups, 'neocomplcache')
    Plug 'Shougo/neocomplcache'
    Plug 'Shougo/neosnippet'
    Plug 'Shougo/neosnippet-snippets'
    Plug 'honza/vim-snippets'
  elseif count(g:ca13_bundle_groups, 'neocomplete')
    "Plug 'Shougo/neocomplete.vim.git'
    Plug 'https://github.com/Shougo/neocomplete.vim.git'
    Plug 'Shougo/neosnippet'
    Plug 'Shougo/neosnippet-snippets'
    Plug 'honza/vim-snippets'
  endif


  " Blade
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'blade')
    Plug 'xsbeats/vim-blade', { 'for': 'blade' }
  endif


  " C
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'c')
    Plug 'vim-jp/cpp-vim', { 'for': ['c', 'cpp'] }
    Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }
  endif


  " Csv
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'csv')
    Plug 'chrisbra/csv.vim', { 'for': 'csv' }
  endif


  " Docker
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'docker')
    Plug 'honza/Dockerfile.vim', { 'for': 'dockerfile' }
  endif


  " Go
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'go')
    if exists("$GOPATH")
      Plug 'fatih/vim-go', { 'for': 'go' }
      Plug 'Blackrush/vim-gocode', { 'for': 'go' }
    endif
  endif


  " Html
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'html')
    Plug 'mattn/emmet-vim', { 'for': ['html', 'css', 'scss', 'sass' ] }
    Plug 'othree/html5.vim', { 'for': 'html' }
    Plug 'mustache/vim-mustache-handlebars', { 'for': [ 'html', 'mustache', 'hbs' ] }
    Plug 'groenewege/vim-less', { 'for': ['less', 'css'] }
    Plug 'wavded/vim-stylus', { 'for' :['sass', 'scss', 'css'] }
    Plug 'tpope/vim-haml', { 'for': ['haml', 'sass', 'scss'] }
    Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
    Plug 'parkr/vim-jekyll'
    Plug 'tpope/vim-liquid'
  endif


  " Javascript
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'javascript')
    Plug 'jelera/vim-javascript-syntax'
    Plug 'pangloss/vim-javascript'
    Plug 'elzr/vim-json', { 'for': 'json' }
    Plug 'briancollins/vim-jst'
    Plug 'kchmck/vim-coffee-script', { 'for': [ 'coffee', 'haml' ] }
    if executable('npm')
      Plug 'marijnh/tern_for_vim' , {'do': 'npm install'}
    endif
  endif


  " Nginx
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'nginx')
    Plug 'evanmiller/nginx-vim-syntax', { 'for': 'nginx' }
  endif


  " PHP
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'php')
    Plug 'spf13/PIV'
    Plug 'arnaud-lb/vim-php-namespace'
    Plug 'beyondwords/vim-twig'
    Plug 'joonty/vim-phpqa'
  endif


  " Python
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'python')
    Plug 'klen/python-mode'
    Plug 'yssource/python.vim'
    Plug 'python_match.vim'
    Plug 'pythoncomplete'
  endif


  " Ruby
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'ruby')
    Plug 'tpope/vim-rails', { 'for': 'ruby' }
    let g:rubycomplete_buffer_loading = 1
    "let g:rubycomplete_classes_in_global = 1
    "let g:rubycomplete_rails = 1
  endif


  " Scala
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'scala')
    Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
  endif


  " SQL
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'sql')
    Plug 'dbext.vim', { 'for': 'sql' }
  endif


  " Writing
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'writing')
    Plug 'reedes/vim-litecorrect'
    Plug 'reedes/vim-textobj-sentence'
    Plug 'reedes/vim-textobj-quote'
    Plug 'reedes/vim-wordy'
    Plug 'reedes/vim-pencil'
    Plug 'plasticboy/vim-markdown'
  endif


  " Yaml
  " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if count(g:ca13_bundle_groups, 'yaml')
    Plug 'chase/vim-ansible-yaml', { 'for': 'yaml' }
  endif

endif


call plug#end()


" SETTINGS
" =============================================================================
" Core
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
let mapleader = ','
let g:mapleader = ','
set mouse=a
set mousehide
set autoread " You can manually type :edit to reload open files
set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
set history=10000 " Default is 20
set gdefault


" UI
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Background
" ----------
set background=dark

function! ToggleBG()
  let s:tbg = &background

  " Inversion
  if s:tbg == "dark"
    set background=light
  else
    set background=dark
  endif
endfunction
noremap <leader>bg :call ToggleBG()<CR>


" Solarized
" ---------
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-colors-solarized/'))
  let g:solarized_termcolors=256
  let g:solarized_termtrans=1
  let g:solarized_contrast="normal"
  let g:solarized_visibility="normal"

  set cursorline
  highlight clear SignColumn      " SignColumn should match background
  highlight clear LineNr          " Current line number row will have same background color in relative mode
  "highlight clear CursorLineNr    " Remove highlight color from current line number
  colorscheme solarized
endif


" Statusline
" ----------
set laststatus=2



" Number
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set number numberwidth=3
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
    set number
  else
    set number
    set relativenumber
  endif
endfunc
nnoremap @@ :call NumberToggle()<cr>


" Format
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set tabstop=2
set shiftwidth=2
set expandtab smarttab " Use 'shiftwidth' when using <Tab>

nmap <leader>fef :call Preserve("normal gg=G")<CR>
" Strip trailing whitespace
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Indent
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set autoindent smartindent
" Keep visual selection after indenting
vnoremap < <gv
vnoremap > >gv


" Search
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Search main settings
" --------------------
set confirm
set ignorecase
set infercase
set smartcase
set hlsearch
set incsearch
set magic
set showmatch
set matchtime=2
set matchpairs+=<:>


" Use tab to move through matching brackets/braces
" ------------------------------------------------
nnoremap <tab> %
vnoremap <tab> %


" Regex and hlsearch mappings
" ---------------------------
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
cnoremap s/ s/\v

noremap <silent> <leader>; :set hlsearch! hlsearch?<cr>
map ;; :noh<cr>


" Map <leader>ff to display all lines with keyword under cursor
" and ask which one to jump to
nmap <leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>


" Normal mode pressing * or # searches for the current selection
" --------------------------------------------------------------
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz


" Visual mode pressing * or # searches for the current selection
" --------------------------------------------------------------
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>


" Ag and Grep
" -----------
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --column
else
  set grepprg=grep\ -rnH\ --exclude=tags\ --exclude-dir=.git\ --exclude-dir=node_modules
endif



" Folds
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

function! CustomFoldText()
" http://www.gregsexton.org/2011/03/improving-the-text-displayed-in-a-fold/
  "get first non-blank line
  let fs = v:foldstart
  while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
    let line = getline(v:foldstart)
  else
    let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif

  let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = " " . foldSize . " lines "
  let foldLevelStr = repeat("+--", v:foldlevel)
  let lineCount = line("$")
  let foldPercentage = printf("[ %.1f", (foldSize*1.0)/lineCount*100) . "% ] "
  let expansionString = repeat(".", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
  return line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
endfunction


function! NeatFoldText()
  let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
  let lines_count = v:foldend - v:foldstart + 1
  let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  let foldchar = matchstr(&fillchars, 'fold:\zs.')
  let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
  let foldtextend = lines_count_text . repeat(foldchar, 8)
  let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction


" Folding is enabled by default
" -----------------------------
set foldenable
"set foldtext=NeatFoldText()
set foldtext=CustomFoldText()
set foldlevel=0


" Toggle and untoggle folds
" -------------------------
nnoremap <space> za
vnoremap <space> zf


" Code folding options
" --------------------
noremap <leader>f0 :set foldlevel=0<CR>
noremap <leader>f1 :set foldlevel=1<CR>
noremap <leader>f2 :set foldlevel=2<CR>
noremap <leader>f3 :set foldlevel=3<CR>
noremap <leader>f4 :set foldlevel=4<CR>
noremap <leader>f5 :set foldlevel=5<CR>
noremap <leader>f6 :set foldlevel=6<CR>
noremap <leader>f7 :set foldlevel=7<CR>
noremap <leader>f8 :set foldlevel=8<CR>
noremap <leader>f9 :set foldlevel=9<CR>



" PasteToggle
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
map ,, :set invpaste<CR>:set paste?<CR>
" Set paste, paste some text, set nopaste
nnoremap <Leader>p :set paste<CR>o<esc>
" Select just-pasted text
nnoremap gp `[v`]


" Tab completion
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set wildmenu
set wildmode=list:longest,full
set ofu=syntaxcomplete#Complete


" List
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set list
"set listchars=tab:›\ ,trail:•,extends:›,precedes:‹,nbsp:+,eol:$
set listchars=trail:•,nbsp:+,precedes:«,extends:»,eol:$,tab:▸\
set fillchars=diff:-
set showbreak=↪\
nmap <leader>l :set list! list?<cr>


" Errors
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set noerrorbells
set novisualbell
set timeoutlen=500
set t_vb=


" Windows navigation
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set splitbelow
set splitright

" Move around windows
" -------------------
nnoremap + <C-W>+
nnoremap _ <C-W>-
nnoremap = <C-W>>
nnoremap - <C-W><_

nnoremap <C-h> <C-w>h<C-w>_
nnoremap <C-j> <C-w>j<C-w>_
nnoremap <C-k> <C-w>k<C-w>_
nnoremap <C-l> <C-w>l<C-w>_

inoremap <C-h> <C-o><C-w>h<C-w>_
inoremap <C-j> <C-o><C-w>j<C-w>_
inoremap <C-k> <C-o><C-w>k<C-w>_
inoremap <C-l> <C-o><C-w>l<C-w>_


" Some mappings for tabs: Cmd + number selects a particular tab
" -------------------------------------------------------------
map <D-S-]> gt
map <D-S-[> gT
map <D-1> 1gt
map <D-2> 2gt
map <D-3> 3gt
map <D-4> 4gt
map <D-5> 5gt
map <D-6> 6gt
map <D-7> 7gt
map <D-8> 8gt
map <D-9> 9gt
" ...and Cmd + 0 selects the final tab
map <D-0> :tablast<CR>


" Buffer
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Move between buffers
" --------------------
nnoremap <left> :bn<CR>
nnoremap <right> :bp<CR>


" Quick buffer open
" -----------------
nnoremap <leader>bl :ls<cr>:e #


" Close current buffer
map <leader>bd :Bclose<cr>


" Close all buffers
" -----------------
map <leader>ba :1,1000 bd!<cr>


" Remember info about open buffers on close
" -----------------------------------------
set viminfo^=%















" Filetype
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Git
" ---
au BufNewFile,BufRead *gitconfig set filetype=gitconfig
autocmd FileType gitcommit set colorcolumn=72 spell


" Ruby
" ----
autocmd FileType ruby
  \ setlocal shiftwidth=2 |
  \ setlocal tabstop=2 |
  \ setlocal expandtab |
  \ setlocal smarttab
let b:ruby_no_expensive = 1


" GUI
" =============================================================================
" GVIM- (here instead of .gvimrc)
if GUI()
  set guioptions-=T           " Remove the toolbar
  set lines=40                " 40 lines of text instead of 24

  if LINUX() && has("gui_running")
    set guifont=Andale\ Mono\ Regular\ 12,Menlo\ Regular\ 11,Consolas\ Regular\ 12,Courier\ New\ Regular\ 14
  elseif OSX() && has("gui_running")
    set guifont=Andale\ Mono\ Regular:h12,Menlo\ Regular:h11,Consolas\ Regular:h12,Courier\ New\ Regular:h14
  elseif WINDOWS() && has("gui_running")
    set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
  endif
else
  if &term == 'xterm' || &term == 'screen'
    set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
  endif
  "set term=builtin_ansi       " Make arrow and other keys work
endif


" MAPPINGS
" =============================================================================

" Keep hands on keyboard
" ----------------------
inoremap jj <ESC>
inoremap kk <ESC>
inoremap hh <ESC>
inoremap jk <ESC>
inoremap kj <ESC>


" Start and end of line
" ---------------------
nnoremap H ^
nnoremap L $
vnoremap L g_


" Unmap help
" ----------
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>


" Edit vimrc
" ----------
nnoremap <silent> <leader>vi :e $MYVIMRC<CR>
nnoremap <silent> <leader>sv :so $MYVIMRC<CR>


" Edit files mode
" ---------------
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%


" F5 | Date and hour
" ------------------
nnoremap <F5> "=strftime("%d-%m-%Y %H:%M:%S %z")<CR>
inoremap <F5> <C-R>=strftime("%d-%m-%Y %H:%M:%S %z")<CR>


" Insert line
" -----------
inoremap <C-i> <CR><Esc>O


" Allow using the repeat operator with a visual selection (!)
" -----------------------------------------------------------
vnoremap . :normal .<CR>


" For when you forget to sudo.. Really Write the file.
" ----------------------------------------------------
cmap w!! w !sudo tee % >/dev/null


" Change Working Directory to that of the current file
" ----------------------------------------------------
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h


" Switch CWD to the directory of the open buffer
" ----------------------------------------------
map <leader>cd :cd %:p:h<cr>:pwd<cr>


" Make Y consistent with C and D.
" -------------------------------
nnoremap Y y$


" Copy entire file contents (to gui-clipboard if available)
" ---------------------------------------------------------
nnoremap yY :let b:winview=winsaveview()<bar>exe 'norm ggVG'.(has('clipboard')?'"+y':'y')<bar>call winrestview(b:winview)<cr>
inoremap <insert> <C-r>+


" Easier horizontal scrolling
" ---------------------------
map zl zL
map zh zH


" Easier formatting
" -----------------
nnoremap <silent> <leader>q gwip


" Fullscreen mode for GVIM and Terminal, need 'wmctrl' in you PATH
" ----------------------------------------------------------------
map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>


" Visual selection of various text objects
" ----------------------------------------
nnoremap VV V
nnoremap Vit vitVkoj
nnoremap Vat vatV
nnoremap Vab vabV
nnoremap VaB vaBV


" Remove Windows ^M character
" ---------------------------
noremap <leader>mm mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm



" COMMANDS
" =============================================================================
" Automatically reload the vimrc config
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
augroup vimrc_myvimrc
  autocmd!
  autocmd BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END


" Remember cursor position
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
augroup vimrc_cursor
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END


" Remove trailing spaces :Chomp
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
command! Chomp silent! normal! :%s/\s\+$//<cr>


" #! | Shebang
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
inoreabbrev <expr> #!! "#!/usr/bin/env" . (empty(&filetype) ? '' : ' '.&filetype)


" EX | chmod +x
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
command! EX if !empty(expand('%'))
   \|   write
   \|   call system('chmod +x '.expand('%'))
   \| else
   \|   echohl WarningMsg
   \|   echo 'Save the file first'
   \|   echohl None
   \| endif


" AutoSave
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! s:autosave(enable)
  augroup autosave
    autocmd!
    if a:enable
      autocmd TextChanged,InsertLeave <buffer>
        \  if empty(&buftype) && !empty(bufname(''))
        \|   silent! update
        \| endif
    endif
  augroup END
endfunction

command! -bang AutoSave call s:autosave(<bang>1)


" ConnectChrome
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if OSX()
  function! s:connect_chrome(bang)
    augroup connect-chrome
      autocmd!
      if !a:bang
        autocmd BufWritePost <buffer> call system(join([
          \ "osascript -e 'tell application \"Google Chrome\"".
          \               "to tell the active tab of its first window\n",
          \ "  reload",
          \ "end tell'"], "\n"))
      endif
    augroup END
  endfunction
  command! -bang ConnectChrome call s:connect_chrome(<bang>0)
endif


" <leader>? | Google it
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
function! s:goog(pat)
  let q = '"'.substitute(a:pat, '["\n]', ' ', 'g').'"'
  let q = substitute(q, '[[:punct:] ]',
    \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system('open https://www.google.co.kr/search?q='.q)
endfunction

nnoremap <leader>? :call <SID>goog(expand("<cWORD>"))<cr>
xnoremap <leader>? "gy:call <SID>goog(@g)<cr>gv


" <leader>I/A | Prepend/Append to all adjacent lines with same indentation
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
nmap <silent> <leader>I ^vio<C-V>I
nmap <silent> <leader>A ^vio<C-V>$A



" PLUGINGS
" =============================================================================
"
" Airline
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-airline/'))
  let g:airline_powerline_fonts = 1

  if !exists('g:airline_symbols')
      let g:airline_symbols = {}
  endif

  if !exists('g:airline_theme')
    let g:airline_theme = 'solarized'
  endif

  let g:airline_symbols.paste = 'ρ'
  let g:airline_symbols.space = "\ua0"
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tagbar#enabled = 1
  let g:airline#extensions#whitespace#enabled = 1
endif


" Bookmarks
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-bookmarks/'))

  highlight BookmarkSign ctermbg=NONE ctermfg=208
  highlight BookmarkLine ctermbg=NONE ctermfg=154
  highlight BookmarkAnnotationSign ctermbg=NONE ctermfg=208
  highlight BookmarkAnnotationLine ctermbg=NONE ctermfg=154

  let g:bookmark_sign = '⚑'
  let g:bookmark_annotation_sign = '♥'
  let g:bookmark_highlight_lines = 1
  let g:bookmark_auto_save = 1
  let g:bookmark_save_per_working_dir = 1

  if isdirectory(expand(s:cache_dir, 1))
    call CreateDir(s:cache_dir . '/bookmarks/')
    let g:bookmark_auto_save_file = expand(s:cache_dir, 1) . '/bookmarks/.vim-bookmarks'
  endif

endif


" Ctrlp
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/ctrlp.vim/'))

  if isdirectory(expand(s:cache_dir, 1))
    call CreateDir(s:cache_dir . '/ctrlp/')
    let g:ctrlp_cache_dir = expand(s:cache_dir, 1) . '/ctrlp/'
  endif

  let g:ctrlp_working_path_mode = 'ra'

  if OSX() || LINUX()
    set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
  elseif WINDOWS()
    set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows
endif

  let g:ctrlp_custom_ignore = {
    \ 'dir':  '\.git$\|\.hg$\|\.svn$',
    \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }
endif


" Emmet
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/emmet-vim/'))
  let g:user_emmet_leader_key='<c-e>'
  let g:user_emmet_install_global = 0
  autocmd FileType html,css EmmetInstall
endif


" Fugitive
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-fugitive/'))
  nnoremap <silent> <leader>gs :Gstatus<CR>
  nnoremap <silent> <leader>gd :Gdiff<CR>
  nnoremap <silent> <leader>gc :Gcommit<CR>
  nnoremap <silent> <leader>gb :Gblame<CR>
  nnoremap <silent> <leader>gl :Glog<CR>
  nnoremap <silent> <leader>gp :Git push<CR>
  nnoremap <silent> <leader>gr :Gread<CR>
  nnoremap <silent> <leader>gw :Gwrite<CR>
  nnoremap <silent> <leader>ge :Gedit<CR>
  nnoremap <silent> <leader>gi :Git add -p %<CR>
  nnoremap <silent> <leader>gg :SignifyToggle<CR>
endif


" IndentLine
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . 'indentLine'))
  let g:indentLine_color_term = 235
  GUI() && let g:indentLine_color_gui = '#A4E57E'
  let g:indentLine_char = 'c'
endif


" Matchit
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Load matchit.vim
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif


" NERDTree
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/nerdtree/'))
  map <leader>nt :NERDTreeToggle<CR>

  let NERDTreeShowBookmarks=1
  let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
  let NERDTreeChDirMode=0
  let NERDTreeQuitOnOpen=1
  let NERDTreeMouseMode=2
  let NERDTreeShowHidden=1
  let NERDTreeKeepTreeInNewTab=1
  let g:nerdtree_tabs_open_on_gui_startup=0
endif


" Obsession
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-obsession/'))
  " Autoload sessions created by vim-obsession when starting Vim
  " The auto-restoring of sessions works on a per-directory basis,
  " so you just need to start vim from within the directory you're working on and it will restore that session.
  augroup sourcesession
  autocmd!
  autocmd VimEnter * nested
    \ if !argc() && empty(v:this_session) && filereadable('Session.vim') |
    \   source Session.vim |
    \ endif
  augroup END

  let g:airline_section_z = airline#section#create(['%{ObsessionStatus(''$'', '''')}', 'windowswap', '%3p%% ', 'linenr', ':%3v '])
endif


" Sauce
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/vim-sauce'))
  if isdirectory(expand(s:cache_dir, 1))
    call CreateDir(s:cache_dir . '/vimsauce/')
    let g:sauce_path = expand(s:cache_dir, 1) . '/vimsauce/'
  endif
endif


" TagBar
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if isdirectory(expand(expand(s:bundle_dir, 1) . '/tagbar/'))
  nnoremap <silent> <leader>tt :TagbarToggle<CR>

  set tags=./tags;/,~/.vimtags
  " Make tags placed in .git/tags file available in all levels of a repository
  let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
  if gitroot != ''
      let &tags = &tags . ',' . gitroot . '/.git/tags'
  endif
endif


" TagBar
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
set completeopt=longest,menuone

" YouCompleteMe
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" Install on linux
" ----------------
" $ > sudo apt-get install build-essential cmake
" $ > sudo apt-get install python-dev
if count(g:ca13_bundle_groups, 'youcompleteme')

  let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
  let g:clang_library_path = "/usr/lib64/"
  let g:clang_complete_copen = 0
  let g:clang_hl_errors = 1
  let g:clang_snippets = 1
  let g:clang_snippets_engine = "ultisnips"
  let g:clang_close_preview = 1
  let g:clang_complete_macros = 1

  let g:ycm_autoclose_preview_window_after_completion = 1
  let g:ycm_autoclose_preview_window_after_insertion = 1
  let g:ycm_use_ultisnips_completer = 1
  let g:ycm_key_list_select_completion=[]
  let g:ycm_key_list_previous_completion=[]

  " remap Ultisnips for compatibility for YCM
  let g:UltiSnipsExpandTrigger = '<C-j>'
  let g:UltiSnipsJumpForwardTrigger = '<C-j>'
  let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

  " For snippet_complete marker.
  if has('conceal')
    set conceallevel=2 concealcursor=i
  endif
endif


" NeoComplete
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if count(g:ca13_bundle_groups, 'neocomplete')

  let g:acp_enableAtStartup = 0
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#enable_auto_delimiter = 1
  let g:neocomplete#max_list = 15
  let g:neocomplete#force_overwrite_completefunc = 1

  if isdirectory(expand(s:cache_dir, 1))
    call CreateDir(s:cache_dir . '/neosnippets/')
    let g:neosnippet#snippets_directory = expand(s:cache_dir, 1) . '/neosnippets/'
  endif

  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : expand(s:cache_dir, 1) . '/.vimshell_hist',
    \ 'scheme' : expand(s:cache_dir, 1) . '/.gosh_completions'
    \ }

  " Define keyword.
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  " Plugin key-mappings
  " These two lines conflict with the default digraph mapping of <C-K>
  if !exists('g:ca13_no_neosnippet_expand')
    imap <C-k> <Plug>(neosnippet_expand_or_jump)
    smap <C-k> <Plug>(neosnippet_expand_or_jump)
  endif
  if exists('g:ca13_noninvasive_completion')
    inoremap <CR> <CR>
    " <ESC> takes you out of insert mode
    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
    " <CR> accepts first, then sends the <CR>
    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
    " <Down> and <Up> cycle like <Tab> and <S-Tab>
    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
    " Jump up and down the list
    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
  else
    " <C-k> Complete Snippet
    " <C-k> Jump to next snippet point
    imap <silent><expr><C-k> neosnippet#expandable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
      \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

    inoremap <expr><C-g> neocomplete#undo_completion()
    inoremap <expr><C-l> neocomplete#complete_common_string()
    "inoremap <expr><CR> neocomplete#complete_common_string()

    " <CR>: close popup
    " <s-CR>: close popup and save indent.
    inoremap <expr><s-CR> pumvisible() ? neocomplete#smart_close_popup()."\<CR>" : "\<CR>"

    function! CleverCr()
      if pumvisible()
        if neosnippet#expandable()
          let exp = "\<Plug>(neosnippet_expand)"
          return exp . neocomplete#smart_close_popup()
        else
          return neocomplete#smart_close_popup()
        endif
      else
        return "\<CR>"
      endif
    endfunction

    " <CR> close popup and save indent or expand snippet
    imap <expr> <CR> CleverCr()
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y> neocomplete#smart_close_popup()
  endif

  " <TAB>: completion.
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

  " Courtesy of Matteo Cavalleri
  function! CleverTab()
    if pumvisible()
      return "\<C-n>"
    endif
    let substr = strpart(getline('.'), 0, col('.') - 1)
    let substr = matchstr(substr, '[^ \t]*$')
    if strlen(substr) == 0
      " nothing to match on empty string
      return "\<Tab>"
    else
      " existing text matching
      if neosnippet#expandable_or_jumpable()
        return "\<Plug>(neosnippet_expand_or_jump)"
      else
        return neocomplete#start_manual_complete()
      endif
    endif
  endfunction

  imap <expr> <Tab> CleverTab()

  " Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif

  let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'

" NeoComplcache
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
elseif count(g:ca13_bundle_groups, 'neocomplcache')

  let g:acp_enableAtStartup = 0
  let g:neocomplcache_enable_at_startup = 1
  let g:neocomplcache_enable_camel_case_completion = 1
  let g:neocomplcache_enable_smart_case = 1
  let g:neocomplcache_enable_underbar_completion = 1
  let g:neocomplcache_enable_auto_delimiter = 1
  let g:neocomplcache_max_list = 15
  let g:neocomplcache_force_overwrite_completefunc = 1

  " Define dictionary.
  let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : expand(s:cache_dir, 1) . '/.vimshell_hist',
    \ 'scheme' : expand(s:cache_dir, 1) . '/.gosh_completions'
    \ }

  " Define keyword.
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns._ = '\h\w*'

  " Plugin key-mappings {
  " These two lines conflict with the default digraph mapping of <C-K>
  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)
  if exists('g:ca13_noninvasive_completion')
    inoremap <CR> <CR>
    " <ESC> takes you out of insert mode
    inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
    " <CR> accepts first, then sends the <CR>
    inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
    " <Down> and <Up> cycle like <Tab> and <S-Tab>
    inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
    inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
    " Jump up and down the list
    inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
  else
    imap <silent><expr><C-k> neosnippet#expandable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
      \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
    smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

    inoremap <expr><C-g> neocomplcache#undo_completion()
    inoremap <expr><C-l> neocomplcache#complete_common_string()
    "inoremap <expr><CR> neocomplcache#complete_common_string()

    function! CleverCr()
      if pumvisible()
        if neosnippet#expandable()
          let exp = "\<Plug>(neosnippet_expand)"
          return exp . neocomplcache#close_popup()
        else
          return neocomplcache#close_popup()
        endif
      else
        return "\<CR>"
      endif
    endfunction

    " <CR> close popup and save indent or expand snippet
    imap <expr> <CR> CleverCr()

    " <CR>: close popup
    " <s-CR>: close popup and save indent.
    inoremap <expr><s-CR> pumvisible() ? neocomplcache#close_popup()."\<CR>" : "\<CR>"
    "inoremap <expr><CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y> neocomplcache#close_popup()
  endif
  " <TAB>: completion.
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

  " Enable heavy omni completion.
  if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
  endif

  let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
  let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.go = '\h\w*\.\?'

" Normal Vim omni-completion
" =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
" To disable omni complete, add the following to your .vimrc.before file:
" let g:ca13_no_omni_complete = 1
elseif !exists('g:ca13_no_omni_complete')
  " Enable omni-completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

endif




" LOCAL
" =============================================================================
" Override ONLY Vim parameters and NOT Bundles
let s:vimrc_local = fnamemodify(resolve(expand('<sfile>')), ':p:h').'/.vimrc.local'
  if filereadable(s:vimrc_local)
  execute 'source' s:vimrc_local
endif

