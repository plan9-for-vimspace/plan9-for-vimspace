" acme/tags.vim

" support sets of executable commands (tags)
"

function! acme#tags#Init()
    if !exists("g:plan9#acme#tags")
        let g:plan9#acme#tags = ["Cut", "Paste", "Edit", "Look", "Snarf", "Undo"]
    endif
    runtime syntax/plan9-acme-ui.vim
    noremap <silent> <leader>9t :call acme#tags#ShowTags()<cr>
endfunction

function! s:GatherTags()
    if exists('g:plan9#acme#tags')
        if exists('b:plan9_acme_tags')
            return extend(g:plan9#acme#tags, b:plan9_acme_tags)
        else
            return g:plan9#acme#tags
        endif
    else
        if exists('b:plan9_acme_tags')
            return b:plan9_acme_tags
        else
            return []
        endif
    endif
endfunction

function! s:Reset()
    let s:orig_buf = 0
endfunction

function! acme#tags#ShowTags()
    if bufnr('^acme/tags$') == -1
        let s:orig_buf = bufnr('%')
        silent 1new acme/tags
        call append(0, join(s:GatherTags(), " ").repeat(" ", &columns))
        " delete last line (it is unused anyway)
        normal dd 
        set ft=plan9-acme-tags "initialize buffer config from ftplugin/plan9-acme-tags.vim 
    endif
endfunction

function! acme#tags#AddTag(tag, local)
    if a:local == 1
        if !exists("b:plan9_acme_tags")
            let b:plan9_acme_tags = []
        endif
        call add(b:plan9_acme_tags, a:tag)
    else
        call add(g:plan9#acme#tags, a:tag)
    endif
endfunction

function! acme#tags#RemoveTag(tag, local)
    if a:local == 1
        call remove(b:plan9_acme_tags, index(b:plan9_acme_tags, a:tag))
    else
        call remove(g:plan9#acme#tags, index(g:plan9#acme#tags, a:tag))
    endif
endfunction
