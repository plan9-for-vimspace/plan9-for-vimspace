function! address_handler#address_handler#Init()
    au! BufReadCmd *:* call address_handler#address_handler#ReadCmd(expand("<amatch>"))
endfunction

function! address_handler#address_handler#ReadCmd(match)
    let l:match_data = split(a:match, ":")
    let l:path = l:match_data[0]
    let l:line = l:match_data[1] 
    if filereadable(l:path)
        bw! "required so we don't pollute the bufferlist
        exe "edit ".l:path
        filetype detect
        try
            silent exe l:line
        catch /E486/
        endtry
    endif
endfunction
