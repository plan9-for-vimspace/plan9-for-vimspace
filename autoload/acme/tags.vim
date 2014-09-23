" acme/tags.vim

" support sets of executable commands (tags)
"
" the basic idea is to use omnifunc to create a popup menu of sorts that lists executable
" tags. this list is populated from both global and buffer-local variable
" sources. 
" currently, this approach won't work because we can't notify what was the
" last completion and extra info on CompleteDone. 
" another approach would be to use the commandline for this, or a nofile
" buffer.

function! acme#tags#Init()
    if !exists("g:plan9#acme#tags")
        let g:plan9#acme#tags = []
    endif
endfunction

function! acme#tags#ShowTags(findstart, base)
    if a:findstart == 1
        return col('.')
    else
        let l:complete_list_dict = []
        if exists('b:plan9_acme_tags')
            let l:tags = extend(g:plan9#acme#tags, b:acme_tags)
        else
            let l:tags = g:plan9#acme#tags
        endif
        for tag in l:tags 
            call add(l:complete_list_dict, {'word': '', 'abbr': tag, 'empty': 1, 'dup': 1})
        endfor
        return {'words': l:complete_list_dict}
    endif
endfunction

function! acme#tags#AddTag(tag, local)
    if a:local == 1
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
