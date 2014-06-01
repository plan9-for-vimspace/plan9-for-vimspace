" vim: set fdm=marker :
"
" acme/acme.vim
"
" acme emulation for vim

" Init(): configure and initialize acme functionality {{{1
function! acme#acme#Init()
    if !exists("g:plan9#acme#map_mouse")
	let g:plan9#acme#map_mouse = 1
    endif
    if !exists("g:plan9#acme#move_mouse")
	let g:plan9#acme#move_mouse = 0
    endif
    if !exists("g:plan9#acme#map_keyboard")
	let g:plan9#acme#map_keyboard = 0
    endif

    if g:plan9#acme#map_mouse > 0
	nnoremap <silent> <MiddleMouse> <LeftMouse>:call acme#acme#MiddleMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <MiddleMouse> :call acme#acme#MiddleMouse(getreg("*"))<cr>
	nnoremap <silent> <RightMouse> <LeftMouse>:call acme#acme#RightMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <RightMouse> :call acme#acme#RightMouse(getreg("*"))<cr>
    endif

    if g:plan9#acme#map_keyboard > 0
	nnoremap <silent> <leader>mm :call acme#acme#MiddleMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <leader>mm :call acme#acme#MiddleMouse(getreg("*"))<cr>
	nnoremap <silent> <leader>mr :call acme#acme#RightMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <leader>mr :call acme#acme#RightMouse(getreg("*"))<cr>
    endif
endfunction

" s:EscapeForBang(text): escape string for execution in bang commands {{{1
function! s:EscapeForBang(text)
	return substitute(a:text, "!", "\\\\!", "g")
endfunction

" s:Exec(prog): execute a program and put its output in a new buffer {{{1
function! s:Exec(prog) 
    botright vnew
    exec "0read !". s:EscapeForBang(a:prog)
    setlocal buftype=nofile
endfunction

" RightMouse(text): emulate the right mouse operation in acme {{{1
" acme's manual calls this button 'mouse button 2'
function! acme#acme#RightMouse(text)
    if executable(split(a:text)[0])
	call s:Exec(a:text)
    endif
endfunction

" MiddleMouse(text): emulate the middle mouse operation in acme {{{1
" acme's manual calls this button 'mouse button 3'
function! acme#acme#MiddleMouse(text) 
    let text_data = split(a:text, ":")[:1]
    if len(text_data) > 1
	if filereadable(text_data[0]) || text_data[0] == ''
            call plan9#address#Do(a:text)
	    return
	endif
    endif
    exe "silent normal *"
endfunction
