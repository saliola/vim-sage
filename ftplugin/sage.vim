" Folding for Python files
" Last Change: 2010 December 11
" Author: Franco Saliola
"
" Heavily modified version of Jurjen Bos's script:
"     http://www.vim.org/scripts/script.php?script_id=2527
"
" Principles:
" - support for cython: cdef, cpdef, ....
" - a (decorated) class/def starts a fold
" - docstrings should be folded:
"   - docstrings at the beginning of a file are folded
"   - a triple quote following a class/def starts a fold
"   - a raw triple quote that begins a line starts a fold
"   - a single triple quote that begins a line ends a fold
"   - a single triple quote ends a fold
"   unless it follows an import statement.
" - comments preceeding a class/def (with the same indentation)
"   are not folded
" - fold import/include statements (include statements in cython)
" - empty lines are linked to the previous fold (can be toggled),
"
" Problems:
" - all lines between one function definition and the next get folded

" Matching class and function definitions:
" - classes are supposed to contain a colon on the same line
" - function definitions are *not* required to have a colon to allow
"   for for multiline defs. (If you disagree, use the pattern
"   '^\s*\(class\|def\)\s.*:' instead.)
let s:defpat = '^\s*\(@\|\(class\|cdef\|cpdef\|def\)\s.*\)'

" Pattern for matching docstrings
let s:docstringbegin = "^\\s*[uUr]*[\"']\\{3}"
let s:docstringend = "^\\s*[\"']\\{3}\\s*$"

" Pattern for matching imports/includes
let s:importpat = '^\(from\s.*import\|^import\s\|^include\)'

" Pattern for matching "section headers"
let s:sectionpat = '^#####'

" initial set up
setlocal foldmethod=expr
setlocal foldexpr=GetPythonFold(v:lnum)
setlocal foldtext=PythonFoldText()

function! PythonFoldText()
    " text to be shown in place of folded text
    let fs = v:foldstart
    let line = getline(fs)
    if line =~ s:docstringbegin
        let nnum = nextnonblank(fs + 1)
        let line = line." ".matchstr(getline(nextnonblank(nnum)), '^\s*\zs.*\ze$')
    elseif line =~ "^\\s\\+[\"']\\{1,3}"
        let line = line." ".matchstr(nextline, "^\\s\\+[\"']\\{1,3}\\zs.\\{-}\\ze['\"]\\{0,3}$")
    else
        while getline(fs) =~ '^\s*@' | let fs = nextnonblank(fs + 1)
        endwhile
        let line = getline(fs)
        let nnum = nextnonblank(fs + 1)
        let nextline = getline(nnum)
        "get the document string: next line is ''' or """
        if nextline =~ "^\\s\\+r*[\"']\\{3}\\s*$"
            let line = line . " " . matchstr(getline(nextnonblank(nnum + 1)), '^\s*\zs.*\ze$')
        "next line starts with qoutes, and has text
        elseif nextline =~ "^\\s\\+[\"']\\{1,3}"
            let line = line." ".matchstr(nextline, "^\\s\\+[\"']\\{1,3}\\zs.\\{-}\\ze['\"]\\{0,3}$")
        elseif nextline =~ '^\s\+pass\s*$'
            let line = line . ' pass'
        endif
    endif
    "compute the width of the visible part of the window (see Note above)
    let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
    let size = 1 + v:foldend - v:foldstart
    "compute expansion string
    let spcs = '----------------'
    while strlen(spcs) < w | let spcs = spcs . spcs
    endwhile
    "expand tabs (mail me if you have tabstop>10)
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')
    return strpart(line.spcs, 0, w-strlen(size)-3).' '.size.' lines'
endfunction

function! GetPythonFold(lnum)
    " Determine the fold level of the line numbered lnum (see
    " "Principles" above)
    let line = getline(a:lnum)
    let ind = indent(a:lnum)

    " by default, the fold level is the same as that of the previous line
    let foldlevel = "="

    " - lines that begin with ^##### (section header) should not be folded
    if line =~ s:sectionpat
        let foldlevel = '0'

    " - a (decorated) class/def starts a fold
    elseif line =~ s:defpat
        " check to see if this is decorated
        if getline(prevnonblank(a:lnum-1)) !~ '^\s*@'
            let n = a:lnum
            while getline(n) =~ '^\s*@' | let n = nextnonblank(n + 1)
            endwhile
            if getline(n) =~ s:defpat
                let foldlevel = ">".(ind/&shiftwidth+1)
            endif
        endif

    " - docstrings should be folded
    elseif line =~ s:docstringbegin
        " - docstrings at the beginning of a file are folded
        if a:lnum == 1
            let foldlevel = 1
        " - a triple quote following a line ending with a colon starts a fold
        elseif getline(prevnonblank(a:lnum-1)) =~ ":$"
            let foldlevel = "a1"
        " - a raw triple quote that begins a line starts a fold
        elseif line =~ "^[uUr][\"']\\{3}"
            let foldlevel = ">1"
        " - a single triple quote ends a fold
        elseif line =~ s:docstringend
            let foldlevel = "s1"
        endif


    " - comments preceeding a class/def (with the same indentation)
    "   (check to see if the next non-empty, non-comment line is a
    "   class/def/decorator)
    elseif line =~ '^\s*#'
        if getline(a:lnum-1) =~ '^\s*#' && indent(a:lnum-1) == ind
            return "="
        else
            let n = nextnonblank(a:lnum+1)
            while n>0 && getline(n) =~'^\s*#'
                let n = nextnonblank(n+1)
            endwhile
            let nextline = getline(n)
            if (nextline =~ s:defpat || nextline =~ '^\s*@') && ind == indent(n)
                let foldlevel = (ind/&shiftwidth)
            endif
        endif

    " - fold import/include statements (include statements in cython)
    elseif line =~ s:importpat
        let foldlevel = "1"

    " - empty lines are linked to the previous fold (can be toggled),
    "   unless it follows an import statement.
    "   change '=' to -1 if you want empty lines/comment out of a fold
    elseif line == ''
        " if the previous line is an import, then end the fold
        if getline(prevnonblank(a:lnum-1)) =~ s:importpat
            let foldlevel = '<1'
        else
            let foldlevel = '='
        endif

    endif

    " everything else
    return foldlevel

endfunction
