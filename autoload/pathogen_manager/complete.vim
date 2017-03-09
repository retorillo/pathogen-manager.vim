let s:cpo = &cpo
set cpo&vim

function! pathogen_manager#complete#wordcount(lead, line, pos)
  let head = a:line[: a:pos - 1 - len(a:lead)]
  " TODO: support quote-string
  let head = substitute(head, '\\\s', '_', 'g')
  return len(split(head, '\v\s+'))
endfunction

function! pathogen_manager#complete#reponame(lead, line, pos)
  let candidates = []
  let wordcount = pathogen_manager#complete#wordcount(a:lead, a:line, a:pos)
  for d in pathogen_manager#repodirs()
    let name = pathogen_manager#dir2name(d)
    if wordcount == 1
      " TODO: Revise replace patterns
      if name =~ '\v^(\^)?'.substitute(a:lead, '[.()[\]^$?]', '\\\0', 'g')
        call add(candidates, '^'.substitute(name, '\v(\s|[.^$?])', '\\\0', 'g'). '$')
      endif
    endif
  endfor
  return candidates
endfunction

let &cpo = s:cpo
unlet s:cpo

