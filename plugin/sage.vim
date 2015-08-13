" File: sage.vim
" Author: Franco Saliola <saliola@gmail.com>
" Description: Sage

" {{{ SageDoctestTwrite
" Requires: Tim Popoe's vim-tbone plugin

if has("python")
python << EOL
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

    # compute the pane; if no pane is specified, use the 'last' used pane
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
    \ execute ":python sage_doctest_tmux_writer(<line1>, <line2>, \"<args>\")"

nnoremap <LocalLeader>st :SageDoctestTwrite<CR>
vnoremap <LocalLeader>st :SageDoctestTwrite<CR>

endif
" }}}
" Sage compuation fie {{{ "

function! EditNewSageComputationsFile()
    if isdirectory("computations")
        :call EditNewDatestampedFile('computations/computations', 'sage')
    else
        :call EditNewDatestampedFile('computations', 'sage')
    endif
endfunction
command! SageNewComputationsFile :call EditNewSageComputationsFile()

function! EditNewestSageComputationsFile()
    if isdirectory("computations")
        let file = system("ls -1 computations/computations.* | tail -1")
    else
        let file = system("ls -1 computations.* | tail -1")
    endif
    execute 'tabnew '.file
endfunction
command! SageNewestComputationsFile :call EditNewestSageComputationsFile()

function! EditMRUSageComputationsFile()
    if isdirectory("computations")
        let file = system("ls -tr1 computations/computations.* | tail -1")
    else
        let file = system("ls -tr1 computations.* | tail -1")
    endif
    execute 'tabnew '.file
endfunction
command! SageMRUComputationsFile :call EditMRUSageComputationsFile()

" }}} Sage compuation fie "
" Sage attach current file {{{ "
" Requires: Tim Popoe's vim-tbone plugin

function! SageAttachCommand(target)
    execute ":Tmux send-keys -t " . tbone#pane_id(a:target) . " " . shellescape("%attach " . expand("%:p")) . " Enter"
endfunction
command! -nargs=1 -complete=custom,tbone#complete_panes SageAttach :call SageAttachCommand("<args>")

" }}} Sage attach current file "
