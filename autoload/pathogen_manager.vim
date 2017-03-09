let s:cpo = &cpo
set cpo&vim

let s:windows = has('win64') || has('win32') || has('win16') || has('win95')

if !exists('g:pathogen_manager#bundle')
  let g:pathogen_manager#bundle = s:windows ? '~/vimfiles/bundle' : '~/.vim/bundle'
endif

let g:pathogen_manager#spinner = ['.  ', '.: ', '.:.', ' :.', '  .', ' :.', '.:.', '.: ']

let s:spin = 0
let s:spinmsg = ''
function! pathogen_manager#spinner(msg)
  let s:spin = (s:spin + 1) % len(g:pathogen_manager#spinner)
  redraw
  if a:msg == '!'
    echo g:pathogen_manager#spinner[s:spin] s:spinmsg
  elseif !empty(a:msg)
    echo g:pathogen_manager#spinner[s:spin] a:msg
    let s:spinmsg = a:msg
  else
    echo
    let s:spinmsg = ''
    let s:spin = 0
  endif
endfunction
function! pathogen_manager#checkreq()
  if !exists('*pathogen#surround')
    throw pathogen_udpate#error#format('NoPathogen')
  endif
  if !executable(g:pathogen_manager#shell#git)
    throw pathogen_manager#error#format('NoGitExecutable', g:pathogen_manager#shell#git)
  endif
  if !isdirectory(expand(g:pathogen_manager#bundle))
    throw pathogen_manager#error#format('NoBundleDirectory', g:pathogen_manager#bundle)
  endif
endfunction
function! pathogen_manager#dir2name(dir)
  return fnamemodify(a:dir, ':t')
endfunction
function! pathogen_manager#repodirs()
  let globpath = pathogen_manager#path#join(expand(g:pathogen_manager#bundle), '*')
  let names = []
  for d in filter(split(glob(globpath), '\v\r?\n'), 'isdirectory(v:val)')
    call add(names, d)
  endfor
  return names
endfunction
function! pathogen_manager#repos(pattern, sortkey)
  let sortdesc = a:sortkey =~ '^!'
  let sortkey = sortdesc ? a:sortkey[1:] : a:sortkey
  let repos = []
  for d in pathogen_manager#repodirs()
    let name = pathogen_manager#dir2name(d)
    if name !~ a:pattern
      continue
    endif
    call pathogen_manager#spinner(printf('Gathering information from %s', name))
    let gitd = pathogen_manager#path#join(d, '.git')
    if !isdirectory(gitd)
      let repo = {
        \ 'name': name,
        \ 'git': 0,
        \ 'path': d,
        })
    else
      let branch = pathogen_manager#git#branchinfo(d)['current']
      call pathogen_manager#spinner('!')
      let origin = pathogen_manager#git#show(d, 'origin/master', 'H')
      call pathogen_manager#spinner('!')
      let head = pathogen_manager#git#show(d, 'HEAD', 'H', 'at', 'ai', 'ar')
      let repo = {
        \ 'name': name,
        \ 'origin': origin.H,
        \ 'path': d,
        \ 'git': 1,
        \ 'branch': branch,
        \ 'url': pathogen_manager#git#config(d, 'remote.origin.url'),
        \ 'sha1': head.H,
        \ 'date': !empty(head.ai) ? printf('%s (%s)', head.ai, head.ar) : '',
        \ 'unix': str2nr(head.at),
        \ }
    endif
    let repo['sortkey'] = repo[sortkey]
    call add(repos, repo)
  endfor
  call pathogen_manager#spinner('')
  return sort(repos, sortdesc
     \ ? function('pathogen_manager#compare#dictdesc')
     \ : function('pathogen_manager#compare#dictasc'))
endfunction
function! pathogen_manager#install(bang, url)
  call pathogen_manager#checkreq()
  let clonedir = pathogen_manager#path#join(expand(g:pathogen_manager#bundle),
    \ pathogen_manager#git#url2name(a:url))
  if !a:bang && isdirectory(clonedir)
    throw pathogen_manager#error#format('AlreadyInstalled', clonedir)
  endif
  call pathogen_manager#git#clone(expand(a:url), clonedir, a:bang)
  if isdirectory(clonedir)
    call pathogen#surround(clonedir)
    for p in split(glob(pathogen_manager#path#join(clonedir, 'plugin', '*.vim')), '\v\r?\n')
      execute printf('source %s', p)
    endfor
  endif
endfunction
function! pathogen_manager#uninstall(bang, pattern)
  call pathogen_manager#checkreq()
  let repos = pathogen_manager#repos(a:pattern, 'name')
  if empty(repos)
    throw pathogen_manager#error#format('PatternUnmatched', a:pattern)
  endif
  if !a:bang
    let reponames = map(copy(repos), 'v:val.name')
    let msg = printf('The following plugins will be removed: %s', join(reponames, ','))
    if confirm(msg, "&YES\n&NO", 2, 'Q') == 2
      return
    endif
  endif
  let factory = []
  for r in repos
    if !empty(factory)
      call add(factory, 'THEN')
    endif
    call add(factory, [
      \ 'RM  '.r['path'], 'AND',
      \ 'ECHO '.printf('%s was successfully uninstalled.', r['name']),
      \ ])
  endfor
  call pathogen_manager#shell#execute(factory)
endfunction
function! pathogen_manager#update(bang, pattern)
  call pathogen_manager#checkreq()
  let repos = map(filter(pathogen_manager#repos(a:pattern, 'name'), 'v:val.git'), 'v:val.path')
  call pathogen_manager#git#pull(repos, a:bang)
endfunction
function! pathogen_manager#list(bang, pattern)
  call pathogen_manager#checkreq()
  let repos = pathogen_manager#repos(a:pattern, !a:bang ? 'name' : '!unix')
  if empty(repos)
    throw pathogen_manager#error#format('PatternUnmatched', a:pattern)
  endif
  for repo in repos
    echohl Identifier
    echomsg repo.name
    echohl None
    echomsg 'path : ' . fnamemodify(repo.path, ':~')
    if repo.git
      if !empty(repo.url)
        echomsg 'url  : ' . repo.url
      endif
      echomsg printf('head : %s(%s)', repo.sha1, repo.branch)
      if !empty(repo.origin) && repo.origin != repo.sha1
        echohl WarningMsg
        echomsg printf('     ! %s(origin/master)', repo.origin)
        echohl None
      endif
      echomsg 'date : ' . repo.date
    endif
  endfor
endfunction
function! pathogen_manager#use(pattern, ...)
  if len(a:000) == 1
    let branch = a:000[0]
    let commit = ''
  elseif len(a:000) == 2
    let branch = a:000[0]
    let commit = a:000[1]
  else
    throw pathogen_manager#error#format('ArgumentInvalid',
      \ 'pathogen_manager#use', a:000)
  endif
  let repos = pathogen_manager#repos(a:pattern, 'name')
  if empty(repos)
    throw pathogen_manager#error#format('PatternUnmatched', a:pattern)
  elseif len(repos) > 1
    throw pathogen_manager#error#format('AmbiguousPattern', a:pattern,
      \ join(map(repos, 'v:val.name'), ', '))
  elseif !repos[0].git
    throw pathogen_manager#error#format('NotGitRepository', repos[0].path)
  endif
  call pathogen_manager#git#use(repos[0].path, branch, commit)
endfunction

let &cpo = s:cpo
unlet s:cpo
