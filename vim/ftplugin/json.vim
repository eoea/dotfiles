if executable('jq')
  autocmd FileType json autocmd BufWritePre <buffer> silent! :%!jq .
endif
