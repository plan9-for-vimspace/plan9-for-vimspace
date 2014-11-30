setlocal statusline=%#acmeStatusline#\ acme/tags
setlocal nowrap
setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal nobuflisted
setlocal concealcursor=nc
au BufLeave <buffer> :bdelete
noremap <silent> <buffer> q :bdelete<cr>
noremap <silent> <buffer> $ :call search('.\(\s\+$\)\@=', '')<cr>
noremap <silent> <buffer> <End> :call search('.\(\s\+$\)\@=', '')<cr>

