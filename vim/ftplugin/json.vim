if executable('jq')
  autocmd FileType json autocmd BufWritePre <buffer> :%!jq .
endif
