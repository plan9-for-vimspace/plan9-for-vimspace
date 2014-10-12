let s:valid_cmds = [
            \"edit",
            \"visual",
            \"split",
            \"vsplit",
            \"new",
            \"view",
            \"sview",
            \]

function! address_handler#address_handler#Init()
    if !exists("g:plan9#address_handler#full_plan9_address")
        let g:plan9#address_handler#full_plan9_address = 0
    endif
    if !exists("g:plan9#address_handler#gnu_col")
        let g:plan9#address_handler#gnu_col = 1
    endif

    au! BufReadCmd *:* call address_handler#address_handler#ReadCmd(expand("<amatch>"))
endfunction

function! address_handler#address_handler#ReadCmd(match)
    let l:match_data = split(a:match, ":")

    " we must support addresses like `test:1:1`,
    " where `test:1` is a valid filename
    let l:test_path = l:match_data[0]
    let l:test_idx = 1
    while !filereadable(l:test_path)
        try
            let l:test_path = join([l:test_path, l:match_data[l:test_idx]], ":")
            let l:test_idx += 1
        catch /E684/ "we didn't find a valid filename
            " we will use the path given,
            " since we can't go to an address anyway
            let l:test_path = a:match
            break
        endtry
    endwhile
    let l:path = l:test_path
    let l:address_spec_data = l:match_data[l:test_idx+0:]

    " we must pass the command the BufReadCmd triggered, to be consistent
    let l:valid_open_cmd_regex = '\('.join(s:valid_cmds, '\|').'\)'
    " TODO: improve this regex
    let l:open_cmd = matchstr(histget("cmd", -1),
                \'\(\(\d*verbo\?s\?e\?\|sile\?n\?t\?!\?\)\s\)\?'.
                \'\(\('.
                    \'bot\?r\?i\?g\?h\?t\?\|'.
                    \'top\?l\?e\?f\?t\?\|'.
                    \'verti\?c\?a\?l\?\|'.
                    \'letfab\?o\?v\?e\?\|'.
                    \'abov\?e\?l\?e\?f\?t\?\|'.
                    \'rightbe\?l\?o\?w\?\|'.
                    \'belo\?w\?r\?i\?g\?h\?t\?'
                \'\)\s\)\?'.
                \'\d*.*!\?\ze\s')
    if match(l:open_cmd, l:valid_open_cmd_regex) == -1
        let l:open_cmd = "edit"
    endif

    "rename the buffer, so we don't clutter the bufferlist with extraneous
    "stuff or go agains expectations re buffer numbers
    silent exe "file ".l:path

    if g:plan9#address_handler#full_plan9_address == 1
        " defer all work to our address compiler
        call plan9#address#Do(a:match, l:open_cmd)
    else
        if len(address_spec_data) > 0
            let l:line = l:address_spec_data[0]
        else
            let l:line = 1 "default
        endif
        let l:col = 1 "default

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
        silent exe l:line
        " if we have a column number, we move the cursor
        if l:col != 1
            silent call cursor(l:line, l:col)
        endif
    endif

    filetype detect
endfunction
