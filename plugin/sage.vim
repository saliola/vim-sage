" File: sage.vim
" Author: Franco Saliola <saliola@gmail.com>
" Description: Some vim mappings to work with vim/sage in a tmux split;
" the default pane most tmux commands is "right"

" {{{ SageDoctestTwrite

if has("python3")
python3 << EOL
def sage_doctest_tmux_writer(pane_id):
    r"""
    Paste the Sage doctest beginning at the current line into the tmux pane
    ``pane_id`` (default: right); move the cursor to the line immediately
    following the end of the doctest.

    If the current line does not start with "sage:", then the line is ignored,
    but the cursor is moved down one line.
    """
    import vim, subprocess

    if pane_id == '':
        pane_id = "right"

    (linenum, colnum) = vim.current.window.cursor
    if vim.current.line.lstrip(" ").startswith("sage: "):
        lines = [vim.current.line]
        lineindex = linenum
        while vim.current.buffer[lineindex].lstrip(" ").startswith("....:"):
            lines.append(vim.current.buffer[lineindex])
            lineindex += 1
    else:
        lines = []
        lineindex = linenum

    # remove whitespace and doctest indicators, ignoring non-doctest lines
    doctest = []
    for (i, line) in enumerate(lines):
        for indicator in ('sage: ', '....: '):
            if line.lstrip(' ').startswith(indicator):
                indent_level = line.index(indicator)
                line = line[indent_level + len(indicator):]
                doctest.append(line)
    doctest = "\n".join(line for line in doctest) + "\n"

    if len(lines) == 1:
        subprocess.call(['tmux', 'send-keys', '-t', pane_id, doctest])
    elif len(lines) > 1:
        subprocess.call(['tmux', 'set-buffer', doctest])
        subprocess.call(['tmux', 'paste-buffer', '-p', '-t', pane_id])
        subprocess.call(['tmux', 'send-keys', '-t', pane_id, "Enter"])

    # move cursor down the appropriate number of lines
    vim.current.window.cursor = (min(lineindex + 1, len(vim.current.buffer)), 0)
EOL

command! -nargs=? SageDoctestTwrite execute ":python3 sage_doctest_tmux_writer(\"<args>\")"

nnoremap <Leader>s :SageDoctestTwrite<CR>

endif
" }}}
" SageAttach {{{

function! SageAttachCommand(target)
    let target = a:target == '' ? "right" : a:target
    execute ":Tmux send-keys -t " . target . " " . shellescape("%attach " . expand("%:p")) . " Enter"
endfunction
command! -nargs=? SageAttach :call SageAttachCommand("<args>")

" }}} SageAttach
" Run doctests of current function {{{

" TODO: write this function

" }}} Run doctests of current function
