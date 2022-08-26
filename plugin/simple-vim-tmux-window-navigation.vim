" --------------------------------------------------
"  keybindings
" --------------------------------------------------
if !get(g:, 'tmux_navigator_nomappings', 0)
	nnoremap <silent> <C-h> :TmuxNavigatePrevious<cr>
	nnoremap <silent> <C-l>  :TmuxNavigateNext<cr>
endif
if empty($TMUX)
	command! TmuxNavigatePrevious call s:VimNavigate('p')
	command! TmuxNavigateNext call s:VimNavigate('n')
else
	command! TmuxNavigatePrevious call s:TmuxAwareNavigate('p') " :.-
	command! TmuxNavigateNext call s:TmuxAwareNavigate('n')     " :.+
endif
" --------------------------------------------------
"  utility
" --------------------------------------------------
function! s:TmuxSocket()
  " The socket path is the first value in the comma-separated list of $TMUX.
  return split($TMUX, ',')[0]
endfunction

function! s:TmuxCommand(args)
	let cmd = 'tmux' . ' -S ' . s:TmuxSocket() . ' ' . a:args
	let l:x = &shellcmdflag
	let &shellcmdflag = '-c'
	let retval = system(cmd)
	let $shellcmdflag = l:x
	return retval
endfunction

function! s:TmuxNavigatorProcessList()
  echo s:TmuxCommand("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
endfunction
command! TmuxNavigatorProcessList call s:TmuxNavigatorProcessList()

" not working on terminal vim
" function! s:WindowFocus()
" 	if s:tmux_is_last_pane
" 		1wincmd w
" 	endif
" endfunction
"
" --------------------------------------------------
"  autocmd
" --------------------------------------------------
let s:tmux_is_last_pane = 0
augroup simple_vim_tmux_navigator
	au!
	autocmd WinEnter * let s:tmux_is_last_pane = 0
	" autocmd FocusGained * call s:WindowFocus()
augroup END

" --------------------------------------------------
"  Navigate
" --------------------------------------------------
function! s:VimNavigate(direction)
	try
		if a:direction == 'n'
			execute 'wincmd ' . 'w'
		elseif a:direction == 'p'
			execute 'wincmd ' . 'W'
		endif
	catch
		echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> execute, CTRL-C quits: wincmd k' | echohl None
	endtry
endfunction

function! s:TmuxAwareNavigate(direction)
	let s:is_last = (winnr() == winnr('$'))
	let s:is_first = (winnr() == 1)

	if (s:is_first && (a:direction == 'p'))
		let l:tmuxdir = ':.-'
    let l:args = 'select-pane ' . '-t' . l:tmuxdir
		silent call s:TmuxCommand(l:args)
		let s:tmux_is_last_pane = 1
	elseif (s:is_last && (a:direction == 'n'))
		let l:tmuxdir = ':.+'
    let l:args = 'select-pane ' . '-t' . l:tmuxdir
		silent call s:TmuxCommand(l:args)
		let s:tmux_is_last_pane = 1
	else
		call s:VimNavigate(a:direction)
		let s:tmux_is_last_pane = 0
	endif
endfunction
