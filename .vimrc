execute pathogen#infect()

set modeline

syntax on
"colorscheme desert
set title
filetype plugin on
filetype indent on
set autoindent

set textwidth=120

function TwoSpaceTabs()
    set tabstop=2
    set shiftwidth=2
    set softtabstop=2
    set expandtab
    set smarttab
    "set smartindent
endfunction

function SpaceTabs()
    set tabstop=4
    set shiftwidth=4
    set softtabstop=4
    set expandtab
    set smarttab
    "set smartindent
endfunction

function TabTabs()
    set tabstop=8
    set shiftwidth=8
    set softtabstop=0
    set noexpandtab
    set nosmarttab
    "set nosmartindent
endfunction

function SwitchTabType()
    if &expandtab == "noexpandtab"
        call SpaceTabs()
        echo "Now using SpaceTabs"
    else
        call TabTabs()
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
map <F4> :call SwitchTabType()<CR>
map <F3> :call SwitchPasteMode()<CR>

" The TouchBar MBP arrows are awful
imap \\\ <esc>

call SpaceTabs()

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
nnoremap <Leader>f :NERDTreeToggle<Enter>
" au vimenter * NERDTree
