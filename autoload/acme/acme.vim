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
	let g:plan9#acme#map_keyboard = 1
    endif

    if g:plan9#acme#map_mouse > 0
	nnoremap <silent> <RightMouse> <LeftMouse>:call acme#acme#RightMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <RightMouse> :call acme#acme#RightMouse(getreg("*"))<cr>
	nnoremap <silent> <MiddleMouse> <LeftMouse>:set opfunc=acme#acme#MiddleMouse<cr>g@
	vnoremap <silent> <MiddleMouse> :<C-U>call acme#acme#MiddleMouse(visualmode())<cr>
    endif

    if g:plan9#acme#map_keyboard > 0
	nnoremap <silent> <leader>mr :call acme#acme#RightMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <leader>mr :call acme#acme#RightMouse(getreg("*"))<cr>
	nnoremap <silent> <leader>mm :set opfunc=acme#acme#MiddleMouse<cr>g@
	vnoremap <silent> <leader>mm :<C-U>call acme#acme#MiddleMouse(visualmode())<cr>
    endif
endfunction

" MiddleMouse(text): emulate the middle mouse operation in acme {{{1
function! acme#acme#MiddleMouse(type)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@
    if a:type =~? "v"
	execute "normal! `<".a:type."`>x"
    else
	execute "normal! BvEx"
    endif
    let l:text = @@
    if executable(split(l:text)[0])
	normal P
	let cmd_output = system(l:text)
	botright vnew
	"exec "0read !". substitute(a:prog, "!", "\\\\!", "g")
	exe "normal i\<C-r>=cmd_output\<cr>"
	setlocal nosmarttab
	try
	    exe "%s/\t//g"
	catch
	endtry
	setlocal buftype=nofile
    else
	if l:text[0] == "<"
	    " replace selection with output
	    let cmd_output = system(l:text[1:])
	    exe "normal i\<C-r>=cmd_output\<cr>"
	elseif l:text[0] == ">"
	    " open the output in a new buffer
	    let cmd_output = system(l:text[1:], getreg("*"))
	    botright vnew
	    exe "normal i\<C-r>=cmd_output\<cr>"
	    try
		exe "%s/\t//g"
	    catch
	    endtry
	    setlocal buftype=nofile
	elseif l:text[0] == "|"
	    " replace selection with output
	    let cmd_output = system(l:text[1:], getreg("*"))
	    exe "normal i\<C-r>=cmd_output\<cr>"
	endif
    endif
    let @@ = reg_save
    let &selection = sel_save
endfunction

" RightMouse(text): emulate the right mouse operation in acme {{{1
function! acme#acme#RightMouse(text) 
    let text_data = split(a:text, ":")
    if filereadable(text_data[0]) || (text_data[0] == '' && len(text_data) > 1)
	call plan9#address#Do(a:text)
	return
    endif
    exe "silent normal *"
endfunction
