### A vim plugin for working with SageMath (sagemath.org)

> Warning: some features of this plugin depend on
> [tmux](https://tmux.github.io/) and Tim Pope's
> [vim-tbone](https://github.com/tpope/vim-tbone)
> plugin, namely the commands that send text to tmux panes.

Syntax highlighting:

- Uses the default syntax highlighting for python files, except that the
  docstrings use some RST highlighting
- This is done by creating a syntax file in after

Folding:

- modified the standard python folding to fold documentation strings

TODO:

- use vim's make to launch doctests and open errors in a quickfix window (FIXME)
- move file type detection to here from .vimrc
- move syntax file from under after; it should just load the python syntax
- improve support for working with the compiler
