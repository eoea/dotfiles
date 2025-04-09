" Go Specific
setlocal autoindent
setlocal smartindent

if executable('gofmt')
    setlocal formatprg='gofmt'
    setlocal formatexpr=
endif
