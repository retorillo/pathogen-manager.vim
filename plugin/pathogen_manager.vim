if exists('g:pathogen_manager#version')
  finish
endif
let g:pathogen_manager#version = '1.0'

let s:cpo = &cpo
set cpo&vim

command!
  \ -nargs=+
  \ -bang
  \ PathogenInstall
  \ call pathogen_manager#install(!empty('<bang>'), <f-args>)

command!
  \ -nargs=+
  \ -bang
  \ -complete=customlist,pathogen_manager#complete#reponame
  \ PathogenUninstall
  \ call pathogen_manager#uninstall(!empty('<bang>'), <f-args>)

command!
  \ -nargs=*
  \ -bang
  \ -complete=customlist,pathogen_manager#complete#reponame
  \ PathogenUpdate
  \ call pathogen_manager#update(!empty('<bang>'), '<args>')

command!
  \ -nargs=*
  \ -bang
  \ -complete=customlist,pathogen_manager#complete#reponame
  \ PathogenList
  \ call pathogen_manager#list(!empty('<bang>'), '<args>')

command!
  \ -nargs=+
  \ -complete=customlist,pathogen_manager#complete#reponame
  \ PathogenUse
  \ call pathogen_manager#use(<f-args>)

let &cpo = s:cpo
unlet s:cpo

