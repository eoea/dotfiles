" sh Specific 
setlocal tabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal softtabstop=2
setlocal autoindent
setlocal smartindent

if executable('shfmt') 
    setlocal formatprg='shfmt'
    setlocal formatexpr=
endif
