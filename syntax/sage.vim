if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Read the Python and RST syntax files
" (we will use the RST syntax highlighting for docstrings)
if version < 600
    source <sfile>:p:h/python.vim
else
    runtime! syntax/python.vim
    unlet b:current_syntax " (otherwise rst.vim does nothing)
    " By default, rst.vim sources various other syntax files in order to color
    " code blocks. This causes a problem because the lisp.vim syntax file
    " overrides iskeyword. rst.vim uses the following global variable to
    " decide which syntax files to source. Since we are only dealing with
    " python code blocks in our context, we set this to python.
    let g:rst_syntax_code_list = ['python']
    syntax include @ReST syntax/rst.vim
    unlet g:rst_syntax_code_list
endif

let b:current_syntax = "sage"

" some new highlight groups
hi Prompt ctermfg=33 guifg=#80a0ff
hi link PyDocString Comment
hi SageDocStringKeywords cterm=bold,underline gui=underline,bold

" By using the nextgroup argument below, we are giving priority to
" pythonDocString over all other groups. This means that a pythonDocString
" can only begin a :
syntax match beginPythonBlock ":$" nextgroup=pythonDocString skipempty skipwhite
hi link beginPythonBlock None

syntax region pythonDocString
    \ start=+[uUr]\='+
    \ end=+'+
    \ contains=sageDoctest,pythonEscape,@Spell,@ReST,SageDocStringKeywords,sageTodo
    \ contained
    \ fold
syntax region pythonDocString
    \ start=+[uUr]\="+
    \ end=+"+ 
    \ contains=sageDoctest,pythonEscape,@Spell,@ReST,SageDocStringKeywords,sageTodo
    \ contained
    \ fold
syntax region pythonDocString
    \ matchgroup=PyDocString
    \ start=+[uUr]\="""+
    \ end=+"""+
    \ contains=sageDoctest,pythonEscape,@Spell,@ReST,SageDocStringKeywords,sageTodo
    \ contained
    \ containedin=pythonRawString
    \ skipempty
    \ skipwhite
    \ keepend
    \ fold
syntax region pythonDocString
    \ matchgroup=PyDocString
    \ start=+[uUr]\='''+
    \ end=+'''+
    \ contains=sageDoctest,pythonEscape,@Spell,@ReST,SageDocStringKeywords,sageTodo
    \ contained
    \ containedin=pythonRawString
    \ skipempty
    \ skipwhite
    \ keepend
    \ fold
syntax region pythonDocString
    \ matchgroup=PyDocString
    \ start=+^[uUr]\="""+
    \ end=+"""+
    \ contains=sageDoctest,pythonEscape,@Spell,@ReST,SageDocStringKeywords,sageTodo
    \ contained
    \ containedin=pythonString
    \ skipempty
    \ skipwhite
    \ keepend
    \ fold
syntax region pythonDocString
    \ matchgroup=PyDocString
    \ start=+^[uUr]\='''+
    \ end=+'''+
    \ contains=sageDoctest,pythonEscape,@Spell,@ReST,SageDocStringKeywords,sageTodo
    \ contained
    \ containedin=pythonString
    \ skipempty
    \ skipwhite
    \ keepend
    \ fold
hi link pythonDocString PyDocString

" clear the pythonDoctest and pythonDoctestValue syntax groups
if hlexists("pythonDoctest")
    syntax clear pythonDoctest
    syntax clear pythonDoctestValue
endif

syntax region sageDoctest
    \ start=+^\s*sage:\s+
    \ end=+\%(^\s*$\|^\s*"""$\)+
    \ contains=ALLBUT,sageDoctest,@ReST,@Spell
    \ contained
    \ containedin=rstLiteralBlock
    \ nextgroup=sageDoctestValue
" hi link sageDoctest Statement

syntax region sageDoctestValue
    \ start=+^\s*\%(sage:\s\|>>>\s\|\.\.\.\)\@!\S\++
    \ end="$"
    \ contains=NONE
    \ contained
    \ containedin=rstLiteralBlock
hi link sageDoctestValue Underlined

syntax match sagePrompt "sage:" containedin=sageDoctest contained
syntax match sagePrompt "....:" containedin=sageDoctest contained
hi link sagePrompt Prompt

syntax case match
syntax keyword sageDocStringKeywords INPUT OUTPUT AUTHORS EXAMPLES TESTS REFERENCES
hi link sageDocStringKeywords SageDocStringKeywords

syntax keyword sageTodo FIXME TODO XXX NOTE
hi link sageTodo Todo

" Look back at least 200 lines to compute the syntax highlighting
syntax sync minlines=200

