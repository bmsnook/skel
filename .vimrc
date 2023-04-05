" MacOS - MacOS-specific information for MacVim
"   :version reveals that MacVim loads configuration files in this order
"      system vimrc file: "$VIM/vimrc"
"        user vimrc file: "$HOME/.vimrc"
"    2nd user vimrc file: "~/.vim/vimrc"
"         user exrc file: "$HOME/.exrc"
"     system gvimrc file: "$VIM/gvimrc"
"       user gvimrc file: "$HOME/.gvimrc"
"   2nd user gvimrc file: "~/.vim/gvimrc"
"          defaults file: "$VIMRUNTIME/defaults.vim"
"       system menu file: "$VIMRUNTIME/menu.vim"
"     fall-back for $VIM: "/Applications/MacVim.app/Contents/Resources/vim"
" 
" MacOS - MacVim colorschemes
" Included colorschemes in 
"   /Applications/MacVim.app/Contents/Resources/vim/runtime/colors
" Add custom colorschemes to ~/.vim/colors
"set term=vt220
" set colorscheme blue for MacVim (ignored by vim in a terminal)
colorscheme blue
" Much useful information on customizing colors and 
"   overriding MacVim default settings in 
"     % ls -l /Applications/MacVim.app/Contents/Resources/vim
"     total 16
"     -rw-r--r--@  1 bxs414  admin  3012 Feb  7 07:45 gvimrc
"     drwxr-xr-x@ 64 bxs414  admin  2048 Feb  7 07:45 runtime
"     -rw-r--r--@  1 bxs414  admin  1940 Feb  7 07:45 vimrc
" https://stackoverflow.com/questions/21112972/macvim-gets-all-settings-from-vimrc-but-not-the-colors-and-i-have-to-source

" MacOS - MacVim running check/test
"
" https://serverfault.com/questions/70196/how-to-tell-if-im-in-macvim-in-vimrc
"
"   if has("gui_macvim")
"       " set macvim specific stuff
"   endif
"   if has("gui_running")
"       " set macvim specific stuff
"   endif
"   COMMENT: 
"     has("gui_macvim") returns true if MacVim runs in GUI or terminal
"     has("gui_running") only returns true if MacVim is running as a GUI
"


set nonumber
"set paste to avoid autoindent on code already formatted when pasting
"set autoindent to  autoindent on code newly-entered when typing
set paste
set autoindent
"set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set tabstop=4
set softtabstop=0
set expandtab
set shiftwidth=4
set smarttab
set backspace=indent,eol,start

" https://stackoverflow.com/questions/1878974/redefine-tab-as-4-spaces

" call UseTabs()
function! UseTabs()
  set tabstop=4     " Size of a hard tabstop (ts).
  set shiftwidth=4  " Size of an indentation (sw).
  set noexpandtab   " Always uses tabs instead of space characters (noet).
  set autoindent    " Copy indent from current line when starting a new line (ai).
endfunction

" call UseSpaces()
function! UseSpaces()
  set tabstop=4     " Size of a hard tabstop (ts).
  set shiftwidth=4  " Size of an indentation (sw).
  set expandtab     " Always uses spaces instead of tab characters (et).
  set softtabstop=0 " Number of spaces a <Tab> counts for. When 0, feature is off (sts).
  set autoindent    " Copy indent from current line when starting a new line (ai).
  set smarttab      " Inserts blanks on a <Tab> key (as per sw, ts and sts).
endfunction

" retab accepts ranges
"     retab the whole file with :retab
"     retab the current line with :.retab

" see current values of settings with a question mark
"     set tabstop?
"     set smarttab?
"     set sw?
"     set ai?
"
"     set tabstop? softtabstop? expandtab? shiftwidth? smarttab? autoindent?
" 
" References
"
" https://vim.fandom.com/wiki/Converting_tabs_to_spaces
"         :help 'tabstop'
"         :help 'shiftwidth'
"         :help 'expandtab'
"         :help 'smarttab'
"         :help 'softtabstop'~
"
" https://vimdoc.sourceforge.net/htmldoc/options.html#'softtabstop'
"     'softtabstop' 'sts'   number  (default 0)
"             local to buffer
"             {not in Vi}
"         Number of spaces that a <Tab> counts for while performing editing
"         operations, like inserting a <Tab> or using <BS>.  It "feels" like
"         <Tab>s are being inserted, while in fact a mix of spaces and <Tab>s is
"         used.  This is useful to keep the 'ts' setting at its standard value
"         of 8, while being able to edit like it is set to 'sts'.  However,
"         commands like "x" still work on the actual characters.
"         When 'sts' is zero, this feature is off.
"         'softtabstop' is set to 0 when the 'paste' option is set.
"         See also |ins-expandtab|.  When 'expandtab' is not set, the number of
"         spaces is minimized by using <Tab>s.
"         The 'L' flag in 'cpoptions' changes how tabs are used when 'list' is
"         set.
"         NOTE: This option is set to 0 when 'compatible' is set.
"
" https://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim
"     Related, if you open a file that uses both tabs and spaces, assuming you've got
" 
"         set expandtab ts=4 sw=4 ai
"
"     You can replace all the tabs with spaces in the entire file with
" 
"         :%retab
"
"
"
"     Firstly, do not use the Tab key in Vim for manual indentation. Vim has a pair of commands in insert mode for manually increasing or decreasing the indentation amount. Those commands are Ctrl-T and Ctrl-D. These commands observe the values of tabstop, shiftwidth and expandtab, and maintain the correct mixture of spaces and tabs (maximum number of tabs followed by any necessary number of spaces).
"     
"     Secondly, these manual indenting keys don't have to be used very much anyway if you use automatic indentation.
"     
"     If Ctrl-T instead of Tab bothers you, you can remap it:
"     
"     :imap <Tab> ^T
"     You can also remap Shift-Tab to do the Ctrl-D deindent:
"     
"     :imap <S-Tab> ^D
"     Here ^T and ^D are literal control characters that can be inserted as Ctrl-VCtrl-T.
"     
"     With this mapping in place, you can still type literal Tab into the buffer using Ctrl-VTab. Note that if you do this, even if :set expandtab is on, you get an unexpanded tab character.
"     
"     A similar effect to the <Tab> map is achieved using :set smarttab, which also causes backspace at the front of a line to behave smart.
"     
"     In smarttab mode, when Tab is used not at the start of a line, it has no special meaning. That's different from my above mapping of Tab to Ctrl-T, because a Ctrl-T used anywhere in a line (in insert mode) will increase that line's indentation.
"     
"     Other useful mappings may be:
"     
"     :map <Tab> >
"     :map <S-Tab> <
"     Now we can do things like select some lines, and hit Tab to indent them over. Or hit Tab twice on a line (in command mode) to increase its indentation.
"     
"     If you use the proper indentation management commands, then everything is controlled by the three parameters: shiftwidth, tabstop and expandtab.
"     
"     The shiftwidth parameter controls your indentation size; if you want four space indents, use :set shiftwidth=4, or the abbreviation :set sw=4.
"     
"     If only this is done, then indentation will be created using a mixture of spaces and tabs, because noexpandtab is the default. Use :set expandtab. This causes tab characters which you type into the buffer to expand into spaces, and for Vim-managed indentation to use only spaces.
"     
"     When expandtab is on, and if you manage your indentation through all the proper Vim mechanisms, the value of tabstop becomes irrelevant. It controls how tabs appear if they happen to occur in the file. If you have set tabstop=8 expandtab and then sneak a hard tab into the file using Ctrl-VTab, it will produce an alignment to the next 8-column-based tab position, as usual.
"     
"     
" linewrapping
"
" https://stackoverflow.com/questions/36950231/auto-wrap-lines-in-vim-without-inserting-newlines
"     If your goal, while typing in insert mode, is to automatically soft-wrap text (only visually) at the edge of the window:
"     
"     set number # (optional - will help to visually verify that it's working)
"     set textwidth=0
"     set wrapmargin=0
"     set wrap
"     set linebreak # (optional - breaks by word rather than character)
"     If your goal, while typing insert mode, is to automatically hard-wrap text (by inserting a new line into the actual text file) at 80 columns:
"     
"     set number # (optional - will help to visually verify that it's working)
"     set textwidth=80
"     set wrapmargin=0
"     set formatoptions+=t
"     set linebreak # (optional - breaks by word rather than character)
"     If your goal, while typing in insert mode, is to automatically soft-wrap text (only visually) at 80 columns:
"     
"     set number # (optional - will help to visually verify that it's working)
"     set textwidth=0
"     set wrapmargin=0
"     set wrap
"     set linebreak # (optional - breaks by word rather than character)
"     set columns=80 # <<< THIS IS THE IMPORTANT PART
"     The latter took me 2-3 significant Internet-scouring sessions to find from here (give 'er a read - it's very well-written): 
"         https://agilesysadmin.net/how-to-manage-long-lines-in-vim/
"     
"     
"     https://stackoverflow.com/questions/3033423/vim-command-to-restructure-force-text-to-80-columns
"         Set textwidth to 80 (:set textwidth=80), move to the start of the file (can be done with Ctrl-Home or gg), and type gqG.
"         
"         gqG formats the text starting from the current position and to the end of the file. It will automatically join consecutive lines when possible. You can place a blank line between two lines if you don't want those two to be joined together.
"         
"         @dmranck After set textwidth=76 your lines will autowrap while typing. My complaint is that it doesn't do anything to existing lines being editing. But V}gq is extremely useful in that regard. V enters visual selection mode, } selects down to the next paragraph break, and gq executes the current formatter on it (or use gw to explicitly call the vi formatter). Also, { will select upwards. You can select the whole document and format with ggVGgq although maybe there's an easier way. Save that as a macro using @ to make it easier. Use vipgq to fmt current paragraph. – 
"         ktbiz
"          Apr 22, 2017 at 17:37 
"         
"         
" https://vi.stackexchange.com/questions/26578/only-wrap-line-when-it-becomes-greater-than-80-characters-after-previously-being
