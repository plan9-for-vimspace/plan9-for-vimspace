" vim: set fdm=marker :
"
" plan9/address.vim
"
" parse and manipulate addresses like those found in acme and sam

" s:SimpleAddress(address): compiles a simple address into viml {{{1
function! s:SimpleAddress(address, idx)
    " get our direction in the compound address
    if a:address[0] == "-" 
	let direction = "back"
    else
	let direction = "forward"
    endif 
    " strip direction marks  
    if a:address[0] =~ "[-+]"
	let address = a:address[1:]
    else
	let address = a:address
    endif 

    " compile addresses according to their type 
    if address[0] == "#" " character position
	let instructions = []
	if a:idx == 0
	    call add(instructions, "normal gg")
	endif

	let a_char = address[1:]
	if direction == "forward"
	    " we use :go to move to the byte a_char in the buffer. 
	    " if a:idx was 0, we start from byte 0, otherwise we need to
	    " calculate the current byte to add to a_char.
	    " the `line2byte(...` part is wrapped in eval because :go doesn't
	    " allow functions in the arguments.
	    call extend(instructions, 
			\['exe "go ". eval("line2byte(line(\".\")) - 1 + col(\".\") - 1 + '. a_char . '")' ])
	elseif direction == "back"
	    call extend(instructions, 
			\['exe "go ". eval("line2byte(line(\".\")) - 1 + col(\".\") - '. a_char . '")' ])
	endif
	return instructions 
    elseif address[0] == "0" " beggining of file 
	return ["normal gg"] 
    elseif address[0] == "$" " end of file 
	return ["normal G$"] 
    elseif address[0] == "/" " forwards search 
	let instructions = []
	if a:idx == 0
	    call add(instructions, "normal gg")
	endif
	if direction == "forward"
	    call extend(instructions, ["call search('". address[1:-2] . "')"])
	else
	    " :-/string/
	    " this is an old (but neat) idiom, documented in the sam paper [1]
	    " [1]: http://plan9.bell-labs.com/sys/doc/sam/sam.html
	    call extend(instructions, ["call search('" . address[1:-2] . "', 'b')"])
	endif 
	return instructions " 
    elseif address[0] == "?" " backwards search 
	let instructions = []
	if a:idx == 0
	    call add(instructions, "normal G$")
	endif
	call extend(instructions, ["call search('" . address[1:-2] . "', 'b')"])
	return instructions 
    endif 

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

    if len(l:a_data) > 1
	" tokenize 
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

	" compile tokens 
	for token in tokens
	    let idx = index(tokens, token)
	    call extend(instructions, s:SimpleAddress(token, idx))
	endfor 
    endif

    return instructions 
endfunction

" Do(address): Execute the viml compiled for an address {{{1
function! plan9#address#Do(address)
    for instruction in plan9#address#Compile(a:address)
	exe instruction
    endfor
endfunction

" Build(expr, mods): build a plan9 address from a vim location {{{1
"
" expr can be any value line() can take as an argument
" mods are filename modifiers, as in expand()
function! plan9#address#Build(expr, mods)
    let l:line = line(a:expr)
    let l:col = col(a:expr)
        
    let path = expand("%".a:mods)

    let address = ""
    if l:line > 1
	let address = line
    endif
    if l:col > 1
	let address = join(filter([address, "#".l:col], 'v:val != ""'), "+")
    endif

    return join(filter([path, address], 'v:val != ""'), ":")
endfunction

" BuildFromSelection(mods): build a plan9 address from the selected text {{{1
"
" mods are filename modifiers, as in expand()
function! plan9#address#BuildFromSelection(mods)
    let path = expand("%".a:mods)
    return join([path, "/".getreg("*")."/"], ":")
endfunction 

" Tests: {{{1 
" must ':cd' into this folder for these to work
"
" address.vim:12
" address.vim:#24
" address.vim:35+#5
" address.vim:/function/
" address.vim:?plan9?
" address.vim:-/plan9/
" address.vim:20-/function/
" address.vim:20+?function?
