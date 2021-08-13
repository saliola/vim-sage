### A vim plugin for working with SageMath (sagemath.org)

> Warning: some features of this plugin depend on
> [tmux](https://tmux.github.io/) and (perhaps) Tim Pope's
> [vim-tbone](https://github.com/tpope/vim-tbone)
> plugin, namely the commands that send text to tmux panes.

Syntax highlighting:

- Uses the default syntax highlighting for python files, except that the
  docstrings use some RST highlighting
- This is done by creating a syntax file in after

Send sage doctest to a tmux pane (default: right):

- `<Leader>s` copies the doctest that begins at the current line
  and pastes it into the tmux pane at the right (if the current
  line does not begin with `sage:`, then the line is ignored).

Folding:

- modified the standard python folding to fold documentation strings

TODO:

- use vim's make to launch doctests and open errors in a quickfix window (FIXME)
- move file type detection to here from .vimrc
- move syntax file from under after; it should just load the python syntax
- improve support for working with the compiler
