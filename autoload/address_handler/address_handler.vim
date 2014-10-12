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
    let l:path = l:match_data[0]

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

    if filereadable(l:path)
        bw! "required so we don't pollute the bufferlist
        
        if g:plan9#address_handler#full_plan9_address == 1
            " defer all wor to our address compiler
            call plan9#address#Do(a:match, l:open_cmd)
        else
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
            " this should take care of lnums and searches
            " Note: ?...? works, but /.../ causes a vim error we can't catch
            exe l:open_cmd." ".l:path 
            exe l:line
            " if we have a column number, we move the cursor
            if l:col != 1
                silent call cursor(l:line, l:col)
            endif
        endif

        filetype detect
    endif
endfunction
