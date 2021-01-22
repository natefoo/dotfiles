execute pathogen#infect()

set modeline

syntax on
"colorscheme desert
set title
filetype plugin on
filetype indent on
set autoindent

set textwidth=120

" Set the indentation style
" arg 0 = ["space", "tab"], default = "space"
" arg 1 = width of tab
function IndentStyle(...)
    let l:style = get(a:, 1, "space")
    if l:style == "space"
        let l:width = get(a:, 2, 4)
        let &softtabstop=l:width
        set expandtab
        set smarttab
    elseif l:style == "tab"
        let l:width = get(a:, 2, 8)
        let &softtabstop=0
        set noexpandtab
        set nosmarttab
    endif
    let &tabstop=l:width
    let &shiftwidth=l:width
    "set smartindent
endfunction

" DetectIndent and sleuth are more opinionated and heavy than my needs dictate, especially since I only plan to use this
" with *.c files. Just count the number of tabs and decide based on that (ftplugin file types will override the default)
function TabDetect(...)
    let a:mintabs = get(a:, 1, 0)
    redir => tabcount
    %s/\t//gne
    redir END
    " second half of the condition tests if the buffer is empty (new)
    if (tabcount != '' && split(tabcount)[0] > a:mintabs) || (line('$') == 1 && getline(1) == '')
        call IndentStyle("tab")
    else
        call IndentStyle("space")
    endif
endfunction

function SwitchIndentStyle()
    if &expandtab == "noexpandtab"
        call IndentStyle("space")
        echo "Now using SpaceTabs"
    else
        call IndentStyle("tab")
        echo "Now using TabTabs"
    endif
endfunction

function SwitchPasteMode()
    if &paste == "nopaste"
        set paste
        echo "Paste Mode ON"
    else
        set nopaste
        echo "Paste Mode OFF"
    endif
endfunction

function ToggleWrap()
    if &formatoptions =~ "t"
        set formatoptions-=t
        echo "Automatic wrapping OFF"
    else
        set formatoptions+=t
        echo "Automatic wrapping ON"
    endif
endfunction

map <F5> :call ToggleWrap()<CR>
map <F4> :call SwitchIndentStyle()<CR>
map <F3> :call SwitchPasteMode()<CR>

" The TouchBar MBP arrows are awful
"imap \\\ <esc>

" Default all files to Python-style indentation
call IndentStyle()

" Stolen from Fedora
" Only do this part when compiled with support for autocommands
if has("autocmd")
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
endif

" http://cedric.bosdonnat.free.fr/wordpress/?p=243
au BufReadCmd *.docx,*.xlsx,*.pptx call zip#Browse(expand("<amatch>"))
au BufReadCmd *.odt,*.ott,*.ods,*.ots,*.odp,*.otp,*.odg,*.otg call zip#Browse(expand("<amatch>"))

" https://stackoverflow.com/questions/102384/using-vims-tabs-like-buffers
"set hidden

let mapleader = '-'

let NERDTreeIgnore=['\.pyc$']
nnoremap <Leader>f :NERDTreeFocus<Enter>
nnoremap <Leader>r :NERDTreeFind<Enter>
" au vimenter * NERDTree

" local inclusions
if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif
