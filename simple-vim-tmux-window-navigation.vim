" vim側でのウィンドウナビゲーション
function! s:VimNavigate(direction)
	try
		execute 'wincmd ' . a:direction
	catch
		echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> execute, CTRL-C quits: wincmd k' | echohl None
	endtry
endfunction
"
function! s:TmuxSocket()
  " The socket path is the first value in the comma-separated list of $TMUX.
  return split($TMUX, ',')[0]
endfunction
" 
function! s:TmuxCommand(args)
	let cmd = 'tmux' . ' -S ' . s:TmuxSocket() . ' ' . a:args
	let l:x = &shellcmdflag
	let &shellcmdflag = '-c'
	let retval = system(cmd) " シェルコマンドを実行し、その結果を文字列で得る
	let $shellcmdflag = l:x
	return retval
endfunction

function! s:TmuxNavigatorProcessList()
  echo s:TmuxCommand("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
endfunction
command! TmuxNavigatorProcessList call s:TmuxNavigatorProcessList()

" tmux側でのウィンドウナビゲーション
function! s:TmuxAwareNavigate(direction)
	let nr = winnr() " winnr(): 現在のウィンドウを示す
	" 
	" let tmux_last_pane = (s:tmux_is_last_pane) " 
	" 前回のペインがtmuxでない(つまりvimの時)
	" if !tmux_last_pane
		" VimNavigateを呼び出す
	call s:VimNavigate(a:direction)
	" endif
	" 上で移動しなかったらtrue(つまりvimが移動できなかったときtrue)
	let at_tab_page_edge = (nr==winnr())

	" if a:tmux_last_pane || a:at_tab_page_edge
	if  s:at_tab_page_edge
		let l:tmuxdir
		if a:direction == 'w'
			l:tmuxdir = ':.+'
		elseif a:direction == 'W'
			l:tmuxdir = ':.-'
		else
		endif
		" trの動作
		let args = 'select-pane -t ' . shellescape($TMUX_PAIN) . ' -' .l:tmuxdir
		silent call s:TmuxCommand(args)
		" let s:tmux_is_last_pane =1
	else
		" let s:tmux_is_last_pane = 0
	endif
endfunction



" function!  s:main()

" 最後のペインかどうか
" let s:tmux_is_last_pane = 0 
" windowを切り替えるたび実行する自動コマンドを設定
augroup tmux_navigator
	au!
	autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

" キーバインディングの初期化
if !get(g:, 'tmux_navigator_nomappings', 0)
	nnoremap <c-h> :TmuxNavigatePrevious<cr>
	nnoremap <c-l> :TmuxNavigateNext<cr>
endif

" TMUXを使用していない時のTmuxNavigateの動作を登録
if empty($TMUX)
	command! TmuxNavigatePrevious call s:VimNavigate('W')
	command! TmuxNavigateNext call s:VimNavigate('w')
endif
" Tmux使用中のTmuxNavigateの動作を登録
command! TmuxNavigatePrevious call s:TmuxAwareNavigate('W') " :.-
command! TmuxNavigateNext call s:TmuxAwareNavigate('w')     " :.+

" endfunction



