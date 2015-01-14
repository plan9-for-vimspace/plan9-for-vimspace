" Note: Is there a better way to do this?
let s:valid_cmds_regex = '('.
            \"<\d*e(>|d|di|dit)@=|".
            \"<\d*vi(>|s|su|sua|sual)@=|".
            \"<\d*sp(>|l|li|lit)@=|".
            \"<\d*vs(>|p|pl|pli|plit)@=|".
            \"<\d*new|".
            \"<\d*vne(>|w)@=|".
            \"<\d*vie(>|w)@=|".
            \"<\d*sv(>|i|ie|iew)@=".
            \")"

function! address_handler#address_handler#Init()
    if !exists("g:plan9#address_handler#full_plan9_address")
        let g:plan9#address_handler#full_plan9_address = 0
    endif
    if !exists("g:plan9#address_handler#gnu_col")
        let g:plan9#address_handler#gnu_col = 1
    endif
    au! BufReadCmd *:* call address_handler#address_handler#ReadCmd(fnameescape(expand("<amatch>")))
endfunction

function! address_handler#address_handler#ReadCmd(match)
    let l:match_data = split(a:match, ":")

    " we must support addresses like `test:1:1`,
    " where `test:1` is a valid filename
    let l:test_path = a:match
    let l:test_idx = 1
    while !filereadable(l:test_path)
        try
            let l:test_path = join(l:match_data[:-l:test_idx], ":")
        catch /E684/ "we didn't find a valid filename
            " we will use the path given,
            " since we can't go to an address anyway
            let l:test_path = a:match
            break
        endtry
        let l:test_idx += 1
    endwhile
    let l:path = l:test_path
    let l:offset = len(l:match_data) - l:test_idx + 2 " '2' because both len(match_data) and l:test_idx have an offset of 1
    let l:address_spec_data = l:match_data[l:offset+0:]

    " we must pass the command the BufReadCmd triggered, to be consistent
    let l:open_cmd = matchstr(histget("cmd", -1), '\v.*'.s:valid_cmds_regex )
    if l:open_cmd == ''
        let l:open_cmd = "edit"
    endif

    "rename the buffer, so we don't clutter the bufferlist with extraneous
    "stuff or go agains expectations re buffer numbers
    if expand('%r') != ''
        if l:open_cmd =~ "\ve(>|d|di|dit)@="
            silent exe "file ".l:path
        else
            bw! 
        endif
    endif

    if g:plan9#address_handler#full_plan9_address == 1
        " defer all work to our address compiler
        call plan9#address#Do(a:match, l:open_cmd)
    else
        let l:line = 1
        let l:col = 1
        if len(address_spec_data) > 0
            if l:address_spec_data[0] !~ '^\\\#'
                let l:line = l:address_spec_data[0]
            else
                let l:byte = substitute(l:address_spec_data[0], '\\\#', '', '')
            endif
        endif

        " GNU utils sometimes output addresses in the form FILE:LNUM:COL
        " This supports that syntax.
        if g:plan9#address_handler#gnu_col == 1
            try
                let l:col = l:address_spec_data[1]
            catch /E684/
            endtry
        endif
        " this should take care of lnums and searches
        " Note: ?...? works, but /.../ causes a vim error we can't catch
        silent exe l:open_cmd." ".l:path
        silent call cursor(1,1)
        if !exists('l:byte')
            silent call cursor(l:line, l:col)
        else
            let l:line = byte2line(l:byte)
            let l:col = l:byte-line2byte(line)+1
            silent call cursor(line, col)
        endif
    endif

    filetype detect
endfunction
