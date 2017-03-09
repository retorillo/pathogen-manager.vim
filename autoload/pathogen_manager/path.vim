let s:keepcpo = &cpo
set cpo&vim

let s:windows = has('win64') || has('win32') ||  has('win16') || has('win95')
let s:sep = s:windows ? '\' : '/'

function! pathogen_manager#path#sep(path)
  let sep = matchstr(a:path, '[\\/]')
  return strlen(sep) > 0 ? sep : s:sep
endfunction

function! pathogen_manager#path#join(...)
  let parts = []
  for part in a:000
    if len(parts) == 0
      let sep = pathogen_manager#path#sep(part)
    endif
    call add(parts, substitute(substitute(part, '[\\/]', sep, 'g'), '[\\/]$', '', ''))
  endfor
  return join(parts, sep)
endfunction

let &cpo = s:keepcpo
unlet s:keepcpo
