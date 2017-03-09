# pathogen-manager.vim

Provide utilities for [tope/vim-pathogen](https://github.com/tpope/vim-pathogen/)

Works on Linux, Windows, and Mac OS.

## Commands

### PathogenInstall

```viml
" Install new plugin from Git repository
:PathogenInstall https://github.com/retorillo/istanbul.vim.git
" Force to re-install package from Git repository
:PathogenInstall! https://github.com/retorilo/istanbul.vim.git
```

PathogenInstall try to load newly installed scripts,
so general and standalone plugins may work fine at once.

But, some complex plugins might not completely activated.
I recommend to restart vim after installation.

### PathogenUninstall

```viml
" Uninstall plugin
:PathogenUninstall istanbul
" Uninstall plugin without prompt
:PathogenUninstall! istanbul
```

PathogenUninstall only remove plugin directory.
Loaded resources(functions, variables, etc.) never be released.
To apply this changes, please restart vim.

### PathogenUpdate

```viml
" Update all plugins on bundle directory
:PathogenUpdate
" Force to update all plugins on bundle directory
:PathogenUpdate!

" Update only if specified pattern is matched
:PathogenUpdate ^vim-airline
" Same as the above, but force to update
:PathogenUpdate! ^vim-airline
```

### PathogenList

```viml
" List all plugins on bundle directory
:PathogenList
" List plugins only if matched
:PathogenList ^vim-airline
" By default, ascendingly sort by name,
" with bang(!), descendingly sort by HEAD commit date.
:PathogenList!
```

## PathogenUse

```viml
" Change HEAD to commit b420ded on branch master
:PathogenUse vim-table-mode master b420ded
" Change HEAD to most recent commit on branch master
:PathogenUse vim-table-mode master FETCH_HEAD
" Change HEAD to previous commit on branch master
:PathogenUse vim-table-mode master HEAD^
" Change HEAD to local branch
:PathogenUse vim-table-mode local
```

## Options

The following variables may help to solve your environment-specific problems.

| Variable                      | Unix default    | Windows default     |
|-------------------------------|-----------------|---------------------|
| g:pathogen_manager#bundle      | '~/.vim/bundle' | '~/vimfile/bundle'  |
| g:pathogen_manager#shell#git   | 'git'           | 'git'               |
| g:pathogen_manager#shell#and   | '&&'            | '&&'                |
| g:pathogen_manager#shell#then  | ';'             | '&'                 |
| g:pathogen_manager#shell#cd    | 'cd %s'         | 'cd %s'             |
| g:pathogen_manager#shell#rm    | 'rm -rf %s'     | 'del /F /S %s'      |
| g:pathogen_manager#shell#group | ['(', ')']      | ['(', ')']          |
| g:pathogen_manager#shell#errno | 'echo $?'       | 'if errorlevel ...' |

## License

The MIT License

Copyright (C) 2017 Retorillo
