let s:cpo = &cpo
set cpo&vim

function! pathogen_manager#git#url2name(url)
  return substitute(fnamemodify(a:url, ':t'), '\.git$', '', '')
endfunction
function! pathogen_manager#git#clone(url, clonepath, force)
  let commands = []
  if a:force
    call add(commands, 'RM'.a:clonepath)
    call add(commands, 'AND')
  endif
  call add(commands, printf('git clone -v %s %s',
    \ shellescape(a:url), shellescape(a:clonepath)))
  call pathogen_manager#shell#execute(commands)
endfunction
function! pathogen_manager#git#pull(dirs, force)
  let commands = []
  for d in a:dirs
    if !empty(commands)
      call add(commands, 'THEN')
    endif
    if !a:force
      call add(commands, [
        \ 'ECHO'.printf('Updating %s', pathogen_manager#git#url2name(d)),
        \ 'AND',
        \ 'CD'.d,
        \ 'AND',
        \ 'git fetch --all',
        \ 'AND',
        \ 'git merge FETCH_HEAD',
        \ ])
    else
      call add(commands, [
        \ 'ECHO'.printf('Forcely Updating %s', pathogen_manager#git#url2name(d)),
        \ 'AND',
        \ 'CD'.d,
        \ 'AND',
        \ 'git fetch --all',
        \ 'AND',
        \ 'git reset --hard FETCH_HEAD',
        \ 'AND',
        \ 'git clean -df',
        \ ])
    endif
  endfor
  call pathogen_manager#shell#execute(commands)
endfunction
function! pathogen_manager#git#config(dir, key)
  return substitute(pathogen_manager#shell#system([
    \ 'CD'.a:dir,
    \ 'AND',
    \ printf('git config --get %s', shellescape(a:key)),
    \ ]), '\v\s*\r?\n$', '', '')
endfunction
function! pathogen_manager#git#show(dir, object, ...)
  let lines = pathogen_manager#shell#lines([
    \ 'CD'.a:dir,
    \ 'AND',
    \ printf('git show -s --pretty=tformat:"%s" %s',
    \   join(map(copy(a:000), '"%".v:val'), '%n'),
    \   shellescape(a:object)),
    \ 'THEN',
    \ 'ERRNO',
    \ ])
  let error = len(lines) <= 1 || str2nr(lines[len(lines) - 1]) != 0
  let dict = {}
  let len = len(a:000)
  let i = 0
  while i < len
    let dict[a:000[i]] = error ? '' : lines[i]
    let i += 1
  endwhile
  return dict
endfunction
function! pathogen_manager#git#branchinfo(dir)
  let lines = pathogen_manager#shell#lines([
    \ 'CD'.a:dir,
    \ 'AND',
    \ 'git branch --all',
    \ 'THEN',
    \ 'ERRNO'
    \ ])
  if len(lines) <= 1 || str2nr(lines[len(lines) - 1]) != 0
    return []
  endif
  let all = []
  let current = ''
  for l in lines[: len(lines) - 2]
    if l =~ '^\*'
      let current = substitute(l, '^\*\s*', '', '')
      call add(all, current)
    else
      call add(all, substitute(l, '^\s*', '', ''))
    endif
  endfor
  return { 'current': current, 'all': all  }
endfunction
function! pathogen_manager#git#use(dir, branch, commit)
  let commands = [ 'CD'.a:dir ]
  if !empty(a:branch)
    call extend(commands, [
      \ 'AND',
      \ printf('git checkout %s', shellescape(a:branch)),
      \ ])
  endif
  if !empty(a:commit)
    call extend(commands, [
      \ 'AND',
      \ printf('git reset --hard %s', shellescape(a:commit)),
      \ 'AND',
      \ 'git clean -df',
      \ ])
  endif
  call pathogen_manager#shell#execute(commands)
endfunction

let &cpo = s:cpo
unlet s:cpo
