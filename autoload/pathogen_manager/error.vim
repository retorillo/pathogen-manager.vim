let s:cpo = &cpo
set cpo&vim

let g:pathogen_manager#error#messages = {
\ 'NoPathogen' : 'tpope/vim-pathogen is required',
\ 'NoGitExecutable': '"git" executable is not present on your system (g:pathogen_manager#git = %s)',
\ 'NoBundleDirectory': '"bundle" directory is not found on your system (g:pathogen_manager#bundle = %s)',
\ 'AlreadyInstalled': '"%s" is present, specified plugin may be already installed.',
\ 'PatternUnmatched': 'No plugins matched with pattern "%s"',
\ 'AmbiguousPattern': 'Pattern "%s" is ambiguous. Two or more plugins are matched: %s',
\ 'NotGitRepository': 'Not a git repository: %s',
\ }

function! pathogen_manager#error#spreadcall(func, args)
  execute printf('return %s(%s)', a:func, join(map(a:args, 'string(v:val)'), ', '))
endfunction

function! pathogen_manager#error#format(key, ...)
  return printf('PathogenManager: %s', len(a:000) == 0
    \ ? g:pathogen_manager#error#messages[a:key]
    \ : pathogen_manager#error#spreadcall('printf',
    \ extend([g:pathogen_manager#error#messages[a:key]], a:000)))
endfunction

let &cpo = s:cpo
unlet s:cpo
