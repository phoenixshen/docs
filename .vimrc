"""""""""""""""""""VBUNDLE START"""""""""""""""""""
"setting for vbundle
set nocompatible              " be iMproved, required
" filetype off                 " required

"set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim/
" call vundle#begin('~/.vim/bundle')
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'Yggdroot/indentLine'
" 状态栏
Plugin 'Lokaltog/vim-powerline'
" 代码注释
Plugin 'tpope/vim-commentary'
" 复制/粘贴工具
Plugin 'vim-scripts/YankRing.vim'

Plugin 'jlanzarotta/bufexplorer'
"c2h
":A
Plugin 'vim-scripts/a.vim'
Plugin 'vim-scripts/grep.vim'
Plugin 'mbriggs/mark.vim'
Plugin 'vim-scripts/Marks-Browser'
"<Leader>mt  - Toggles ShowMarks on and off.
"<Leader>mo  - Turns ShowMarks on, and displays marks.
"<Leader>mh  - Clears a mark.
"<Leader>ma  - Clears all marks.
"<Leader>mm  - Places the next available mark.
Plugin 'vim-scripts/ShowMarks'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/taglist.vim'
Plugin 'vim-scripts/winmanager--Fox'
Plugin 'scrooloose/nerdtree'
" mk sessions
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
Bundle "scrooloose/syntastic"
Bundle "Valloric/YouCompleteMe"

Bundle "SirVer/ultisnips"
Bundle "honza/vim-snippets"
" 文件查找
Bundle "ctrlpvim/ctrlp.vim"
" func search in file
Bundle 'tacahiroy/ctrlp-funky'
Bundle 'Raimondi/delimitMate'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'

call vundle#end()
"""""""""""""""""""VBUNDLE END"""""""""""""""""""

""""""""""""""""""""VIM SET START""""""""""""""""""""

syntax on
filetype indent on           " 针对不同的文件类型采用不同的缩进格式
filetype plugin on           " 针对不同的文件类型加载对应的插件
filetype plugin indent on    "启用自动补全


set list lcs=tab:\¦\ ,

"Set mapleader
let mapleader = ","


"--search setting--
set incsearch
set hlsearch

set path +=.
set path +=,,

"--commandline config--
set showcmd
set showmode
"Fast reloading of the .vimrc
map <silent><leader>ss :source ~/.vimrc<cr>
"Fast editing of .vimrc
map <silent> <leader>ee :call SwitchToBuf("~/.vimrc")<cr>
"when .vimrc is edited, reload it
autocmd! bufwritepost .vimrc source ~/.vimrc
" Switch to buffer according to file name
function! SwitchToBuf(filename)
    "let fullfn = substitute(a:filename, "^\\~/", $HOME . "/", "")
    " find in current tab
    let bufwinnr = bufwinnr(a:filename)
    if bufwinnr != -1
        exec bufwinnr . "wincmd w"
        return
    else
        " find in each tab
		tabfirst
		let tab = 1
		while tab <= tabpagenr("$")
			let bufwinnr = bufwinnr(a:filename)
			if bufwinnr != -1
				exec "normal " . tab . "gt"
				exec bufwinnr . "wincmd w"
				return
			endif
			tabnext
			let tab = tab + 1
		endwhile
		" not exist, new tab
		exec "tabnew " . a:filename
	endif
endfunction

function! TrimEndLines()
	let save_cursor = getpos(".")
	"trim line end space
	:silent! %s/\s\+$//
	"trim  file end space line
	:silent! %s#\($\n\s*\)\+\%$##
	"silent normal! gg=G
	call setpos('.', save_cursor)
endfunction
"============================================
"Config for tab page
nnoremap <C-l> gt
nnoremap <C-h> gT
nnoremap <leader>t : tabe<CR>
nnoremap <leader>t. : tabe .<CR>

nmap <leader>w :w<CR>
nmap <silent> <leader>q :q<cr>
nmap <silent> <leader>qq :q!<cr>
nmap <leader>v <C-v>

"============================================
" Session options
set sessionoptions-=curdir
set sessionoptions+=sesdir
"Restore cursor to file position in previous editing session
set viminfo='10,\"100,:20,n~/.viminfo
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

"add for new line"
nmap <silent> to :call append('.', '')<CR>j
nmap <silent> tO :call append(line('.')-1, '')<CR>k

"replace esc"
imap jj <ESC>l

"===========================================
"Quickfix
nmap <leader>cn :cn<cr>
nmap <leader>cp :cp<cr>
nmap <leader>cw :cw 10<cr>
nmap <leader>cl :ccl<cr>
nmap <leader>ll :lcl<cr>

"============================================
"config for grep plugin
nnoremap <silent> <leader>g :Grep<CR>
nnoremap <silent> <leader>rg :Rgrep<CR>
nnoremap <silent> <leader>ag :GrepArgs<CR>

"============================================
"config for lvimgrep
function! s:GetVisualSelection()
	let save_a = @a
	silent normal! gv"ay
	let v = @a
	let @a = save_a
	let var = escape(v, '\\/.$*')
	return var
endfunction
" Fast grep
nmap <silent> <leader>lv :lv /<c-r>=expand("<cword>")<cr>/ %<cr>:lw<cr>
vmap <silent> <leader>lv :lv /<c-r>=<sid>GetVisualSelection()<cr>/ %<cr>:lw<cr>
"""============================================


"--status line config--
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}  " status line shows
set laststatus=2
set ruler

"hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=green
""set cursorline "highlight curr line
" need to add \ for regex symbol
set magic

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set ignorecase  " ignore capital letters small letters
set smartcase "if have no  capital letters,turn ignorecare
set autoread
set autowrite
"set smartintent
set tabstop=4
set softtabstop=4
"add for linux use tab intend
" set expandtab
set autoindent
set shiftwidth=4
set cindent
set cinoptions={0,1s,t0,n-2,p2s,(03s,=.5s,>1s,=1s,:1s  "set c/c+= intent
set backspace=2   "backspace is work
set showmatch
set linebreak
"set whichwrap=b,s,<,>,[,] "allow cursor and backspace cross line boundary
"set hidden " Hide buffers when they are abandoned
"set mouse=a            " Enable mouse usage (all modes)
set selection=exclusive
set selectmode=key
"show space in split window
set fillchars=vert:\|,stl:\ ,stlnc:\
set history=500
"set previewwindow
" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	"have Vim load indentation rules and plugins according to the detected filetype
	filetype plugin indent on
	set number            " Enable line number
	" set line num color"
    highlight LineNr ctermfg=grey
endif
"set for terminal"
set viminfo+=! "keep globa varible
set term=xterm
set t_Co=256
set background=dark
"let g:molokai_original = 1
" let g:rehash256 = 1

""""""""""""""""""""""add for color scheme""""""""""""""""""""""
colorscheme molokai
"colorscheme default
" hi Comment ctermfg=blue cterm=none

"设置variable为蓝色非粗体
""hi Identifier ctermfg=cyan cterm=NONE
"修改字符串颜色
"hi String ctermfg =darkred
"
"修改类型颜色
"hi Type ctermfg =yellow
"
"修改数字颜色
"hi Number ctermfg =darkblue
"
"修改常量颜色
"hi Constant ctermfg =blue
"
"修改声明颜色
"hi Statement ctermfg =darkyellow

" hi CursorLine  cterm=NONE   ctermbg=darkgrey ctermfg=green
" For showmarks plugin
hi ShowMarksHLl ctermbg=lightgreen    ctermfg=Black  guibg=#FFDB72 guifg=Black
hi ShowMarksHLu ctermbg=darkyellow  ctermfg=Black  guibg=#FFB3FF guifg=Black

"For mark plugin
hi MarkWord1  ctermbg=Cyan     ctermfg=black    guibg=#8CCBEA    guifg=Black
hi MarkWord2  ctermbg=Green    ctermfg=black    guibg=#A4E57E    guifg=Black
hi MarkWord3  ctermbg=Yellow   ctermfg=black    guibg=#FFDB72    guifg=Black
hi MarkWord4  ctermbg=Red      ctermfg=black    guibg=#FF7272    guifg=Black
hi MarkWord5  ctermbg=Magenta  ctermfg=black    guibg=#FFB3FF    guifg=Black
hi MarkWord6  ctermbg=Blue     ctermfg=black    guibg=#9999FF    guifg=Black

autocmd InsertLeave * se nocul
autocmd InsertEnter * se cul
"set cmdheight=1
"set scrolloff=3  "keep 3 line away from top or buttom when scroll
set novisualbell
set foldenable " allow fold
set foldmethod=manual
"set foldmethod=syntax
"set foldcolumn=4

set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936

set clipboard+=unnamed  "share clipborad with system

"inoremap ( ()<ESC>i
"inoremap ) <c-r>=ClosePair(')')<CR>
"inoremap { {<CR>}<ESC>O
"inoremap } <c-r>=ClosePair('}')<CR>
"inoremap [ []<ESC>i
"inoremap ] <c-r>=ClosePair(']')<CR>
"inoremap " ""<ESC>i
"inoremap ' ''<ESC>i
"function! ClosePair(char)
"	if getline('.')[col('.') - 1] == a:char
"		return "\<Right>"
"	else
"		return a:char
"	endif
"endfunction
""for sh  set speical intend
" autocmd FileType sh inoremap { {}<ESC>i
" autocmd FileType sh inoremap } <c-r>=ClosePair('}')<CR>
"delimitMate
let delimitMate_expand_space = 1
let delimitMate_expand_cr = 1

set completeopt=longest,menu

"for multi line
nnoremap j gj
nnoremap k gk

"Smart way to move btw. windows
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k
nmap <C-h> <C-W>h
nmap <C-l> <C-W>l

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"auto check dir
"''''''''''''''''''''''''''''''''''''''''''''''''''''"
nmap <silent><Leader>cd :lcd %:p:h<cr>
nmap <silent><Leader>c- :cd -<cr>


"not used cfg for default file explorer netrw
"netrw setting

""let g:netrw_winsize = 30
" nmap <silent> <leader>fe :Sexplore!<cr>
""""""""""""""""""""""""""""""
 " file explorer setting
 "Split vertically
 " let g:explVertical=1

 "Window size
" let g:explWinSize=35

" let g:explSplitLeft=1
" let g:explSplitBelow=1

"Hide some files
" let g:explHideFiles='^\.,.*\.class$,.*\.swp$,.*\.pyc$,.*\.swo$,\.DS_Store$'

"Hide the help thing..
" let g:explDetailedHelp=0
""""""""""""""""""""""""""""""
" bufexplorer setting
""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp=1       " Do not show default help.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
let g:bufExplorerSplitRight=0        " Split left.
let g:bufExplorerSplitVertical=1     " Split vertically.
let g:bufExplorerSplitVertSize = 35  " Split width
let g:bufExplorerUseCurrentWindow=1  " Open in new window.
let g:bufExplorerMaxHeight=30        " Max height
let g:bufExplorerMinHeight=20       " Max height

""""""""""""""""""""""""""""
"tagbar config
""""""""""""""""""""""""""""""
nmap <F3> :TagbarToggle<CR>
let g:tagbar_ctags_bin='/usr/bin/ctags'
let g:tagbar_width=30
"F2ctrl num
nnoremap <F2> :set nonumber!<CR>:set foldcolumn=0<CR>

""""""""""""""""""""""""""""""
" winmanagef setting
""""""""""""""""""""""""""""""
let g:winManagerWindowLayout = "NERDTree|BufExplorer"
let g:winManagerWidth = 35
let g:defaultExplorer = 0
let g:explShowHiddenFiles = 1
let g:NERDTree_title="[NERDTree]"
let g:AutoOpenWinManager = 1
let g:TagBar_title="[TagBar]"
autocmd BufWinEnter \[Buf\ List\] setl nonumber
nmap <silent> <F4> :WMToggle<cr>
function! NERDTree_Start()
    exe 'q'
    exe 'NERDTree'
endfunction

function! NERDTree_IsValid()
    return 1
endfunction

function! TagBar_Start()
    exe 'q'
    exe 'TagbarOpen'
endfunction

function! TagBar_IsValid()
    return 1
endfunction

""""""""""""""""""""""""""""""
" NERDTree setting
""""""""""""""""""""""""""""""
nmap <silent> <leader>n :NERDTreeToggle<cr>
nn <silent> <leader>. : exec("NERDTree ".expand('%:h'))<CR>
nn <leader>bb :Bookmark <<c-r>=expand("<cword>")<cr>><cr>j
let NERDTreeHijackNetrw=1
"go //pre check
"t  // open in tab
"K J // fist && last\
"p //up
"C //set dir
"u //last dir
"! //exec"
"x X open dir tree/close
"e edit the current dif
"D del bookmark"
"o set dir as root"
let NERDTreeShowBookmarks=1
let NERDTreeIgnore = ['\.o$']

""""""""""""""""""""""""""""""
""markbrowser setting
""""""""""""""""""""""""""""""
nmap <silent> <leader>mb :MarksBrowser<cr>

""""""""""""""""""""""""""""""
" showmarks setting
""""""""""""""""""""""""""""""
",mm add bookmark

" Enable ShowMarks
let showmarks_enable = 1
" Show which marks
let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
" Ignore help, quickfix, non-modifiable buffers
let showmarks_ignore_type = "hqm"
" Hilight lower & upper marks
let showmarks_hlline_lower = 1
let showmarks_hlline_upper = 1

 """"""""""""""""""""""""""""""
 " hightlight setting
 """"""""""""""""""""""""""""""
nmap <silent> <leader>hl <Plug>MarkSet
vmap <silent> <leader>hl <Plug>MarkSet
nmap <silent> <leader>hh <Plug>MarkClear
vmap <silent> <leader>hh <Plug>MarkClear
nmap <silent> <leader>hr <Plug>MarkRegex
vmap <silent> <leader>hr <Plug>MarkRegex

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"cscope setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("cscope")
    set cscopequickfix=s-,c-,d-,i-,t-,e-
    set csprg=~/bin/cscope
	set csto=1
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
	endif
	set csverb
endif
"search symbol"
nmap <C-@>s :cs find s <C-R>=expand("<cword>")<CR><CR><CR>:cw<CR>
"define"
nmap <C-@>g :cs find g <C-R>=expand("<cword>")<CR><CR><CR>:cw<CR>
"called"
nmap <C-@>c :cs find c <C-R>=expand("<cword>")<CR><CR><CR>:cw<CR>
"string"
nmap <C-@>t :cs find t <C-R>=expand("<cword>")<CR><CR><CR>:cw<CR>
"egrep"
nmap <C-@>e :cs find e <C-R>=expand("<cword>")<CR><CR><CR>:cw<CR>
"find file"
nmap <C-@>f :cs find f <C-R>=expand("<cfile>")<CR><CR><CR>:cw<CR>
"find include this file"
nmap <C-@>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR><CR>:cw<CR>
nmap <C-@>d :cs find d <C-R>=expand("<cword>")<CR><CR><CR>:cw<CR>


" vim-commentary: 注释代码
"(01) gcc to comment 1 line "        (03) gcu to un-comment 1 line
autocmd FileType python,sh set commentstring=#\ %s
autocmd FileType java,c,cpp set commentstring=//\ %s

" vim-plugin
let  g:C_UseTool_cmake   = 'yes'
let  g:C_UseTool_doxygen = 'yes'

" YankRing
nmap <Leader>ys :YRShow<CR>
nmap <Leader>yc :YRClear<CR>

"====syntastic config====
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

"====for Youcompleteme
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'

"==== snipptes
let g:UltiSnipsExpandTrigger="<c-t>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" If you want :UltiSnipsEdit to split your window.
 let g:UltiSnipsEditSplit="vertical"

au BufWritePre * call TrimEndLines()
""""""""""""""ctrlp"""""""""""""""
let g:ctrlp_map = '<leader>p'
let g:ctrlp_cmd = 'CtrlP'
map <leader>f :CtrlPMRU<CR>
let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
			\ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz|pyc|o)$',
			\ }
let g:ctrlp_working_path_mode = 0
let g:ctrlp_match_window_bottom = 1
let g:ctrlp_max_height = 15
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_mruf_max = 500
let g:ctrlp_follow_symlinks = 1

""""""""""""""ctrlp funcky"""""""""""""""""
nnoremap <Leader>fu :CtrlPFunky<Cr>
" narrow the list down with a word under cursor
nnoremap <Leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
let g:ctrlp_funky_syntax_highlight = 1
let g:ctrlp_extensions = ['funky']

""""""""""""""""""""intend Line """"""""""""""""""""""""
let g:indentLine_char = '¦'
let g:indentLine_color_term = 239"


""""""""""""markdown""""""""""""""""""""
let g:vim_markdown_folding_disabled = 1
"let g:vim_markdown_override_foldtext = 0
"let g:vim_markdown_folding_level = 6
"let g:vim_markdown_no_default_key_mappings = 1
"let g:vim_markdown_emphasis_multiline = 0
"set conceallevel=2
"let g:vim_markdown_frontmatter=1
"
"""""""""""""""""original"""""""""""""""""
"copy to vim cmd line"
"c-r cw  current word
"c-r "   copylipborad word
"gf open file under cursor
"c-w f open file in  new
"copy system to vim"
" "+p
"copy vim to system"
" "+y
" command line mode ctrl+r 0 copy clipboard 0 to command
