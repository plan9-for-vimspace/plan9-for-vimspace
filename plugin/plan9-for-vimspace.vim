" vim: set fdm=marker :
" 
" plan9-for-vimspace.vim: plan9 for vim space loader

" Defaults: {{{1
if !exists("g:plan9#modules#enabled")
    let g:plan9#modules#enabled = [
                \"acme",
                \"address_handler"
                \]
endif

" Initialize: {{{1
for module in g:plan9#modules#enabled
    call {module}#{module}#Init()
endfor
