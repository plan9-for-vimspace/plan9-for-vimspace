" vim: set fdm=marker :
"
" plan9/address.vim
"
" parse and manipulate addresses like those found in acme and sam

" s:SimpleAddress(address): compiles a simple address into viml {{{1
function! s:SimpleAddress(address, idx)
    " direction in compound address {{{2
    if a:address[0] == "-" 
	let direction = "back"
    else
	let direction = "forward"
    endif "}}}2
    " strip direction marks {{{2 
    if a:address[0] =~ "[-+]"
	let address = a:address[1:]
    else
	let address = a:address
    endif "}}}2

    " compile addresses according to their type "{{{2
    if address[0] == "#" " character position {{{3
	let instructions = []
	if a:idx == 0
	    call add(instructions, "normal gg")
	endif

	let a_char = address[1:]
	if direction == "forward"
	    call extend(instructions, [
			\"let byte = line2byte(line('.')) - 1 + getpos('.')[2] - 1 + ". a_char,
			\'exe "go ". byte',
			\"unlet byte" 
		    \])
	elseif direction == "back"
	    call extend(instructions,  [
			\"let byte = line2byte(line('.')) - 1 + getpos('.')[2] -  ". a_char, 
			\'exe "go ". byte', 
			\"unlet byte"
		    \])
	endif
	return instructions "}}}3
    elseif address[0] == "0" " beggining of file {{{3
	return ["normal gg"] "}}}3
    elseif address[0] == "$" " end of file {{{3
	return ["normal G$"] "}}}3
    elseif address[0] == "/" " forwards search {{{3
	let instructions = []
	if a:idx == 0
	    call add(instructions, "normal gg")
	endif
	if direction == "forward"
	    call extend(instructions, ["call search('". address[1:-2] . "')"])
	else
	    " this is an old idiom, documented in the sam paper [1]
	    " [1]: http://plan9.bell-labs.com/sys/doc/sam/sam.html
	    call extend(instructions, ["call search('" . address[1:-2] . "', 'b')"])
	endif 
	return instructions " }}}3
    elseif address[0] == "?" " backwards search {{{3
	let instructions = []
	if a:idx == 0
	    call add(instructions, "normal G$")
	endif
	call extend(instructions, ["call search('" . address[1:-2] . "')"])
	return instructions "}}}3
    endif " }}}2

    " if all else fails, we have a line number
    return [address]
endfunction

" Compile(address): compile a plan9 address into viml {{{1
function! plan9#address#Compile(address)
    let l:a_data = split(a:address, ":", 1)

    let instructions = []
    " the file the address references
    if filereadable(l:a_data[0])
	let l:filename = l:a_data[0]
	if !buffer_exists(l:filename)
	    call add(instructions, "botright split " . l:filename)
	else
	    call add(instructions, "buffer " . l:filename)
	endif
    endif

    let l:addr_chars = split(l:a_data[1], '\zs')
    let tokens = []
    let c_token = ''
    for i in l:addr_chars
	if i =~ '[+-]'
	    call add(tokens, c_token)
	    " call add(tokens, i)
	    let c_token = ''
	endif
	let c_token = c_token . i
    endfor
    call add(tokens, c_token) "complete the list with the remainder

    for token in tokens
	let idx = index(tokens, token)
	call extend(instructions, s:SimpleAddress(token, idx))
    endfor

    return instructions 
endfunction

" Do(address): Execute the viml compiled for an address {{{1
function! plan9#address#Do(address)
    for instruction in plan9#address#Compile(a:address)
	exe instruction
    endfor
endfunction

" Build(...): build a plan9 address from a vim location {{{1
function! plan9#address#Build(...)
endfunction
