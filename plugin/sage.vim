" File: sage.vim
" Author: Franco Saliola <saliola@gmail.com>
" Description: Some vim mappings to work with vim/sage in a tmux split;
" the default pane most tmux commands is "right"

" {{{ SageDoctestTwrite
" Requires: Tim Pope's vim-tbone plugin

if has("python3")
python3 << EOL
def sage_doctest_tmux_writer(line1, line2, pane_id):
    r"""
    Paste a sage doctest into a tmux pane.

    Lines that don't start with "sage:" or "....:" are ignored (that is, the
    lines corresponding to the expected output are ignored).
    """
    import vim, subprocess

    range = list(vim.current.buffer.range(line1,line2))

    # remove whitespace and docstring indicators, ignoring non-docstring lines
    new_range = []
    for (i, line) in enumerate(range):
        for indicator in ('sage: ', '....: '):
            if line.lstrip(' ').startswith(indicator):
                indent_level = line.index(indicator)
                line = line[indent_level + len(indicator):]
                new_range.append(line)
    range = new_range

    # use %cpaste if there is more than one line
    if line1 != line2:
        range = ['%cpaste'] + range + ['C-d']

    # compute the pane id (if no pane is specified, the 'right' pane is used);
    # this requires the vim-tbone plugin
    if pane_id == '':
        pane_id = 'last'
    pane_id = vim.eval("tbone#pane_id('%s')" % pane_id)

    # send the commands
    args = ['tmux', 'send-keys', '-t', pane_id]
    for line in range:
        subprocess.call(args + [line, "Enter"])
EOL

command! -nargs=? -range -complete=custom,tbone#complete_panes SageDoctestTwrite
    \ execute ":python3 sage_doctest_tmux_writer(<line1>, <line2>, \"<args>\")"

nnoremap <S-CR> :SageDoctestTwrite right<CR><CR>

endif
" }}}
" SageAttach {{{
" Requires: Tim Pope's vim-tbone plugin

function! SageAttachCommand(target)
    let target = a:target == '' ? "right" : a:target
    execute ":Tmux send-keys -t " . tbone#pane_id(target) . " " . shellescape("%attach " . expand("%:p")) . " Enter"
endfunction
command! -nargs=? -complete=custom,tbone#complete_panes SageAttach :call SageAttachCommand("<args>")

" }}} SageAttach
" Run doctests of current function {{{
" Requires: Tim Pope's vim-tbone plugin

" TODO: write this function

" }}} Run doctests of current function
