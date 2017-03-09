let s:cpo = &cpo
set cpo&vim

function! pathogen_manager#compare#numasc(nr1, nr2)
  return a:nr1 - a:nr2
endfunction
function! pathogen_manager#compare#numdesc(nr1, nr2)
  return -pathogen_manager#compare#numasc(a:nr1, a:nr2)
endfunction
function! pathogen_manager#compare#strasc(str1, str2)
  let c = 0
  let len1 = len(a:str1)
  let len2 = len(a:str2)
  let maxlen = max([len1, len2])
  while c < maxlen
    let nr1 = c < len1 ? str2nr(a:str1[c]) : 0
    let nr2 = c < len2 ? str2nr(a:str2[c]) : 0
    let diff = pathogen_manager#compare#numasc(nr1, nr2)
    if diff != 0
      return diff
    endif
    let c += 1
  endwhile
  return 0
endfunction
function! pathogen_manager#compare#strdesc(str1, str2)
  return -pathogen_manager#compare#strasc(a:str1, a:str2)
endfunction
function! pathogen_manager#compare#dictasc(dict1, dict2)
  if !has_key(a:dict1, 'sortkey') || !has_key(a:dict2, 'sortkey')
    return 0
  endif
  let key1 = a:dict1.sortkey
  let key2 = a:dict2.sortkey
  if type(key1) == 0 || type(key2) == 0
    return pathogen_manager#compare#numasc(key1, key2)
  else
    return pathogen_manager#compare#strasc(string(key1), string(key2))
  endif
endfunction
function! pathogen_manager#compare#dictdesc(dict1, dict2)
  return -pathogen_manager#compare#dictasc(a:dict1, a:dict2)
endfunction

let &cpo = s:cpo
unlet s:cpo

