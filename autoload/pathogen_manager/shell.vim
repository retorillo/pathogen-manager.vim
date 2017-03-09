let s:cpo = &cpo
set cpo&vim

let s:windows = has('win64') || has('win32') || has('win16') || has('win95')

if !exists('g:pathogen_manager#shell#group')
  let g:pathogen_manager#shell#group = ['(', ')']
endif
if !exists('g:pathogen_manager#shell#and')
  let g:pathogen_manager#shell#and = '&&'
endif
if !exists('g:pathogen_manager#shell#then')
  let g:pathogen_manager#shell#then = s:windows ? '&' : ';'
endif
if !exists('g:pathogen_manager#shell#rm')
  let g:pathogen_manager#shell#rm = s:windows ? 'del /F /S %s' : 'rm -rf %s'
endif
if !exists('g:pathogen_manager#shell#cd')
  let g:pathogen_manager#shell#cd = 'cd %s'
endif
if !exists('g:pathogen_manager#shell#echo')
  let g:pathogen_manager#shell#echo = 'echo %s'
endif
if !exists('g:pathogen_manager#shell#git')
  let g:pathogen_manager#shell#git = 'git'
endif
if !exists('g:pathogen_manager#shell#errno')
  let g:pathogen_manager#shell#errno = s:windows
    \ ? 'if errorlevel 1 (echo 1) else echo 0'
    \ : 'echo $?'
endif
function! pathogen_manager#shell#execute(factory)
  execute '!'.pathogen_manager#shell#build(a:factory)
endfunction
function! pathogen_manager#shell#lines(factory)
  return split(pathogen_manager#shell#system(a:factory), '\v\r?\n')
endfunction
function! pathogen_manager#shell#system(factory)
  return system(pathogen_manager#shell#build(a:factory))
endfunction
function! pathogen_manager#shell#build(factory)
  let commands = []
  call add(commands, g:pathogen_manager#shell#group[0])
  for f in a:factory
    if type(f) == 3
      call add(commands, g:pathogen_manager#shell#group[0])
      call add(commands, pathogen_manager#shell#build(f))
      call add(commands, g:pathogen_manager#shell#group[1])
    elseif f =~ '^git\s'
      call add(commands, substitute(f, '^git', g:pathogen_manager#shell#git, ''))
    elseif f =~ '^RM'
      let rmfile = substitute(f, '\v(^RM\s*|\s*$)', '', 'g')
      call add(commands, printf(g:pathogen_manager#shell#rm, shellescape(rmfile)))
    elseif f =~ '^ECHO'
      let echomsg = substitute(f, '\v(^ECHO\s*|\s*$)', '', 'g')
      call add(commands, printf(g:pathogen_manager#shell#echo, shellescape(echomsg)))
    elseif f =~ '^CD'
      let chdir = fnamemodify(substitute(f, '\v(^CD\s*|\s*$)', '', 'g'), ':p')
      call add(commands, printf(g:pathogen_manager#shell#cd, shellescape(chdir)))
    elseif f == 'AND'
      call add(commands, g:pathogen_manager#shell#and)
    elseif f == 'THEN'
      call add(commands, g:pathogen_manager#shell#then)
    elseif f == 'ERRNO'
      call add(commands, g:pathogen_manager#shell#errno)
    else
      call add(commands, f)
    endif
    unlet! f
  endfor
  call add(commands, g:pathogen_manager#shell#group[1])
  return join(commands, ' ')
endfunction

let &cpo = s:cpo
unlet s:cpo
