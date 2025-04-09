" Python Specific
if executable('black') 
    set formatprg=black\ -q\ 2>/dev/null\ -
    setlocal formatexpr=
endif
