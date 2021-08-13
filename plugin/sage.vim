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

    vrange = list(vim.current.buffer.range(line1, line2))
    num_lines = line2 - line1 + 1

    # remove whitespace and docstring indicators, ignoring non-docstring lines
    new_range = []
    for (i, line) in enumerate(vrange):
        for indicator in ('sage: ', '....: '):
            if line.lstrip(' ').startswith(indicator):
                indent_level = line.index(indicator)
                line = line[indent_level + len(indicator):]
                new_range.append(line)
    vrange = new_range

    # compute the pane id; this requires the vim-tbone plugin
    # (if no pane is specified, the 'right' pane is used);
    if pane_id == '':
        pane_id = 'right'
    pane_id = vim.eval("tbone#pane_id('%s')" % pane_id)

    # send the commands via tmux
    if len(vrange) == 0:
        args = ['tmux', 'send-keys', '-t', pane_id]
        subprocess.call(args + ["Enter"])
    elif num_lines == 1:
        args = ['tmux', 'send-keys', '-t', pane_id]
        subprocess.call(args + [vrange[0], "Enter"])
    else:
        lines = "\n".join(line for line in vrange) + "\n"
        subprocess.call(['tmux', 'set-buffer', lines])
        subprocess.call(['tmux', 'paste-buffer', '-p', '-t', pane_id])
        subprocess.call(['tmux', 'send-keys', '-t', pane_id, "Enter"])

    # move cursor down the appropriate number of lines
    (row, col) = vim.current.window.cursor
    new_row_num = min(row + num_lines, len(vim.current.buffer))
    vim.current.window.cursor = (new_row_num, 0)
EOL

command! -nargs=? -range -complete=custom,tbone#complete_panes SageDoctestTwrite
    \ execute ":python3 sage_doctest_tmux_writer(<line1>, <line2>, \"<args>\")"

nnoremap <Leader>s :SageDoctestTwrite right<CR>
vnoremap <Leader>s :SageDoctestTwrite right<CR>

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
