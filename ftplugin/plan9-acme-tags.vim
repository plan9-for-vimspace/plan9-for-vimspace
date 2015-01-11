setlocal statusline=%#acmeStatusline#\ acme/tags
setlocal nowrap
setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal nobuflisted
setlocal concealcursor=nc
au BufLeave <buffer> :bdelete
noremap <silent> <buffer> q :bdelete<cr>
noremap <silent> <buffer> $ :call search('.\(\s\+$\)\@=', 'c')<cr>
noremap <silent> <buffer> <End> :call search('.\(\s\+$\)\@=', 'c')<cr>
noremap <silent> <buffer> <CR> :call acme#tags#ApplyTag(expand('<cWORD>'))<cr>
