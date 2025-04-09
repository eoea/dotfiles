" C++ Specific
setlocal tabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal softtabstop=2
setlocal autoindent
setlocal smartindent

if executable('clang-format') 
    setlocal formatprg='clang-format'
    setlocal formatexpr=
endif
