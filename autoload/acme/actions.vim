" acme/actions.vim
"
" acme mouse actions

function! acme#actions#Init()
    if !exists("g:plan9#acme#map_mouse")
	let g:plan9#acme#map_mouse = 1
    endif
    if !exists("g:plan9#acme#move_mouse")
	let g:plan9#acme#move_mouse = 0
    endif
    if !exists("g:plan9#acme#map_keyboard")
	let g:plan9#acme#map_keyboard = 1
    endif
    if !exists("g:plan9#acme#open_folds")
        let g:plan9#acme#open_folds = 1
    endif
    if g:plan9#acme#map_mouse > 0
	nnoremap <silent> <RightMouse> <LeftMouse>:call acme#actions#RightMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <RightMouse> :call acme#actions#RightMouse(getreg("*"))<cr>
	nnoremap <silent> <MiddleMouse> <LeftMouse>:set opfunc=acme#actions#MiddleMouse<cr>g@
	vnoremap <silent> <MiddleMouse> :<C-U>call acme#actions#MiddleMouse(visualmode())<cr>
    endif

    if g:plan9#acme#map_keyboard > 0
	nnoremap <silent> <leader>90 :call acme#actions#RightMouse(expand('<cWORD>'))<cr>
	vnoremap <silent> <leader>90 :call acme#actions#RightMouse(getreg("*"))<cr>
	nnoremap <silent> <leader>99 :set opfunc=acme#actions#MiddleMouse<cr>g@
	vnoremap <silent> <leader>99 :<C-U>call acme#actions#MiddleMouse(visualmode())<cr>
    endif
endfunction

" MiddleMouse(text): emulate the middle mouse operation in acme {{{1
" executes the command in the selection
function! acme#actions#MiddleMouse(type)
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
" if text is a valid address, it moves to the location
" if not, it searches the word under the cursor
function! acme#actions#RightMouse(text)
    let text_data = split(a:text, ":")
    if len(text_data) > 0
        if filereadable(text_data[0]) || (text_data[0] == '' && len(text_data) > 1)
            call plan9#address#Do(a:text)
        else
            exe "silent normal *"
        endif
        if g:plan9#acme#open_folds == 1
            try
                normal! zo
            catch /E490/
            endtry
        endif
    endif
endfunction
