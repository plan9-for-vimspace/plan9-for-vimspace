function! address_handler#address_handler#Init()
    if !exists("g:plan9#address_handler#gnu_col")
        let g:plan9#address_handler#gnu_col = 0
    endif

    au! BufReadCmd *:* call address_handler#address_handler#ReadCmd(expand("<amatch>"))
endfunction

function! address_handler#address_handler#ReadCmd(match)
    let l:match_data = split(a:match, ":")
    echom l:match_data
    let l:path = l:match_data[0]
    let l:line = l:match_data[1]
    let l:col = 1 "default

    " GNU utils sometimes output addresses in the form FILE:LNUM:COL
    " This supports that syntax.
    if g:plan9#address_handler#gnu_col == 1
        try
            let l:col = l:match_data[2]
        catch /E684/ 
        endtry
    endif

    if filereadable(l:path)
        bw! "required so we don't pollute the bufferlist
        exe "edit ".l:path
        filetype detect
        silent call cursor(l:line, l:col)
    endif
endfunction
