" DoxygenToolkit.vim
" Brief: Usefull tools for Doxygen (comment, author, license).
" Version: 0.1.8
" Date: 05/17/04
" Author: Mathias Lorente
"
" Note: Changes made by Jason Mills:
"   - Fixed \n bug which resulted in comments being screwed up
"   - Added use of doxygen /// comments.
"
" Actually five purposes have been defined :
"
" Generates a doxygen license comment.  The tag text is configurable.
"
" Generates a doxygen author skeleton.  The tag text is configurable.
"
" Generates a doxygen comment skeleton for a C, C++, or Java function or class,
" including @brief, @param (for each named argument), and @return.  The tag
" text as well as a comment block header and footer are configurable.
" (Consequently, you can have \brief, etc. if you wish, with little effort.)
" 
" Ignore code fragment placed in a block defined by #ifdef ... #endif.  The
" block name must be given to the function.  All of the corresponding blocks
" in all the file will be treated and placed in a new block DOX_SKIP_BLOCK (or
" any other name that you have configured).  Then you have to update
" PREDEFINED value in your doxygen configuration file with correct block name.
" You also have to set ENABLE_PREPROCESSING to YES.
" 
" Generate a doxygen group (begining and ending). The tag text is
" configurable.
"
" Use:
" - License :
"   In vim, place the cursor on the line that will follow doxygen license
"   comment.  Then, execute the command :DoxLic.  This will generate license
"   comment and leave the cursor on the line just after.
"
" - Author :
"   In vim, place the cursor on the line that will follow doxygen author
"   comment.  Then, execute the command :DoxAuthor.  This will generate the
"   skeleton and leave the cursor just after @author tag if no variable
"   define it, or just after the skeleton.
"
" - Function / class comment :
"   In vim, place the cursor on the line of the function header (or returned
"   value of the function) or the class.  Then execute the command :Dox.  This
"   will generate the skeleton and leave the cursor after the @brief tag.
"
" - Ignore code fragment :
"   In vim, if you want to ignore all code fragment placed in a block such as :
"     #ifdef DEBUG
"     ...
"     #endif
"   You only have to execute the command :DoxUndoc(DEBUG) !
"   
" - Group :
"   In vim, execute the command :DoxBlock to insert a doxygen block on the
"   following line.
"
" Limitations:
" - Assumes that the function name (and the following opening parenthesis) is
"   at least on the third line after current cursor position.
" - Not able to update a comment block after it's been written.
" - Blocks delimiters (header and footer) are only included for function
"   comment.
"
"
" Example:
" Given:
" int
"   foo(char mychar,
"       int myint,
"       double* myarray,
"       int mask = DEFAULT)
" { //...
" }
"
" Issuing the :Dox command with the cursor on the function declaration would
" generate
" 
" /**
" * @brief
" *
" * @param mychar
" * @param myint
" * @param myarray
" * @param mask
" *
" * @return
" */
"
"
" To customize the output of the script, see the g:DoxygenToolkit_*
" variables in the script's source.  These variables can be set in your
" .vimrc.
"
" For example, my .vimrc contains:
" let g:DoxygenToolkit_briefTag="@Synopsis  "
" let g:DoxygenToolkit_paramTag="@Param "
" let g:DoxygenToolkit_returnTag="@Returns   "
" let g:DoxygenToolkit_blockHeader="--------------------------------------------------------------------------"
" let g:DoxygenToolkit_blockFooter="----------------------------------------------------------------------------"
" let g:DoxygenToolkit_authorName="Mathias Lorente"
" let g:DoxygenToolkit_licenseTag="My own license\n"   <-- Do not forget
" ending "\n"


" Verify if already loaded
if exists("loaded_DoxygenToolkit")
   "echo 'DoxygenToolkit Already Loaded.'
   finish
endif
let loaded_DoxygenToolkit = 1
"echo 'Loading DoxygenToolkit...'
let s:licenseTag = "Copyright (C) \<enter>"
let s:licenseTag = s:licenseTag . "This program is free software; you can redistribute it and/or\<enter>"
let s:licenseTag = s:licenseTag . "modify it under the terms of the GNU General Public License\<enter>"
let s:licenseTag = s:licenseTag . "as published by the Free Software Foundation; either version 2\<enter>"
let s:licenseTag = s:licenseTag . "of the License, or (at your option) any later version.\<enter>\<enter>"
let s:licenseTag = s:licenseTag . "This program is distributed in the hope that it will be useful,\<enter>"
let s:licenseTag = s:licenseTag . "but WITHOUT ANY WARRANTY; without even the implied warranty of\<enter>"
let s:licenseTag = s:licenseTag . "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\<enter>"
let s:licenseTag = s:licenseTag . "GNU General Public License for more details.\<enter>\<enter>"
let s:licenseTag = s:licenseTag . "You should have received a copy of the GNU General Public License\<enter>"
let s:licenseTag = s:licenseTag . "along with this program; if not, write to the Free Software\<enter>"
let s:licenseTag = s:licenseTag . "Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.\<enter>"

" Common standard constants
if !exists("g:DoxygenToolkit_briefTag")
   let g:DoxygenToolkit_briefTag = "@brief "
endif
if !exists("g:DoxygenToolkit_paramTag")
   let g:DoxygenToolkit_paramTag = "@param "
endif
if !exists("g:DoxygenToolkit_returnTag")
   let g:DoxygenToolkit_returnTag = "@return "
endif
if !exists("g:DoxygenToolkit_blockHeader")
   let g:DoxygenToolkit_blockHeader = ""
endif
if !exists("g:DoxygenToolkit_blockFooter")
   let g:DoxygenToolkit_blockFooter = ""
endif
if !exists("g:DoxygenToolkit_licenseTag")
  let g:DoxygenToolkit_licenseTag = s:licenseTag
endif
if !exists("g:DoxygenToolkit_fileTag")
   let g:DoxygenToolkit_fileTag = "@file "
endif
if !exists("g:DoxygenToolkit_authorTag")
   let g:DoxygenToolkit_authorTag = "@author "
endif
if !exists("g:DoxygenToolkit_dateTag")
   let g:DoxygenToolkit_dateTag = "@date "
endif
if !exists("g:DoxygenToolkit_undocTag")
   let g:DoxygenToolkit_undocTag = "DOX_SKIP_BLOCK"
endif
if !exists("g:DoxygenToolkit_blockTag")
   let g:DoxygenToolkit_blockTag = "@name "
endif


""""""""""""""""""""""""""
" Doxygen comment function 
""""""""""""""""""""""""""
function! <SID>DoxygenCommentFunc()
   " modif perso
   
   let l:argBegin = "\("
   let l:argEnd = "\)"
   let l:argSep = ','
   let l:sep = "\ "
   let l:voidStr = "void"

   let l:classDef = 0

   " Make comment tag.
   let l:comTag = MakeIndent() . "/// "
   
   " Store function in a buffer
   let l:lineBuffer = getline(line("."))
   mark d
   let l:count=1
   " Return of function can be defined on other line than the one the function
   " is defined.
   while ( l:lineBuffer !~ l:argBegin && l:count < 4 )
     " This is probbly a class (or something else definition)
     if ( l:lineBuffer =~ "{" )
       let l:classDef = 1
       break
     endif
     exec "normal j"
     let l:line = getline(line("."))
     let l:lineBuffer = l:lineBuffer . l:line
     let l:count = l:count + 1
   endwhile
   if ( l:classDef == 0 )
     if ( l:count == 4 )
       return
     endif
     " Get the entire function
     let l:count = 0
     while ( l:lineBuffer !~ l:argEnd && l:count < 10 )
       exec "normal j"
       let l:line = getline(line("."))
       let l:lineBuffer = l:lineBuffer . l:line
       let l:count = l:count + 1
     endwhile
     " Function definition seem to be too long...
     if ( l:count == 10 )
       return
     endif
   endif

   " Start creating doxygen pattern
   exec "normal `d" 
"  exec "normal O/**" . g:DoxygenToolkit_blockHeader . "\n" . g:DoxygenToolkit_briefTag . "\n"
"  exec "normal ^c$" . g:DoxygenToolkit_blockFooter . "*/"
   exec "normal k"
   call AppendText(l:comTag . g:DoxygenToolkit_blockHeader)
   call AppendText(l:comTag . g:DoxygenToolkit_briefTag)
   call AppendText(l:comTag . g:DoxygenToolkit_blockFooter)
   exec "normal k"
   mark d

   " Class definition, let's start with brief tag
   if ( l:classDef == 1 )
     startinsert!
     return
   endif

   " Add return tag if function do not return void
   let l:beginPos = match(l:lineBuffer, l:voidStr)
   let l:beginArgPos = match(l:lineBuffer, l:argBegin)
   let l:firstSpace = match(l:lineBuffer, ' ')    " return seomething only if there is space before parenthesis
   if ( ( l:beginPos == -1 || l:beginPos > l:beginArgPos ) && ( l:firstSpace != -1 && l:firstSpace < l:beginArgPos ) )
"     exec "normal o\n" . g:DoxygenToolkit_returnTag
     call AppendText(l:comTag . g:DoxygenToolkit_returnTag)
   endif

   " Delete space just after and just before parenthesis
   let l:lineBuffer = substitute(l:lineBuffer, "\t", "\ ", "g")
   let l:lineBuffer = substitute(l:lineBuffer, "(\ ", "(", "")
   let l:lineBuffer = substitute(l:lineBuffer, "\ )", ")", "")

   while ( match(l:lineBuffer, "\ \ ") != -1 )
     let l:lineBuffer = substitute(l:lineBuffer, "\ \ ", "\ ", "g")
   endwhile

   " Looking for argument name in line buffer
   exec "normal `d"
   let l:argList = 0    " ==0 -> no argument, !=0 -> at least one arg
   
   let l:beginP = 0
   let l:endP = 0
   let l:prevBeginP = 0

   " Arguments start after opening parenthesis
   let l:beginP = match(l:lineBuffer, l:argBegin, l:beginP) + 1
   let l:prevBeginP = l:beginP
   let l:endP = l:beginP

   " Test if there is something into parenthesis
   let l:beginP = l:beginP
   if ( l:beginP == match(l:lineBuffer, l:argEnd, l:beginP) )
     startinsert!
     return
   endif

   " Enter into main loop
   while ( l:beginP > 0 && l:endP > 0 )

     " Looking for arg separator
     let l:endP1 = match(l:lineBuffer, l:argSep, l:beginP)
     let l:endP = match(l:lineBuffer, l:argEnd, l:beginP)
     if ( l:endP1 != -1 && l:endP1 < l:endP )
       let l:endP = l:endP1
     endif
     let l:endP = l:endP - 1

     if ( l:endP > 0 )
      let l:strBuf = ReturnArgName(l:lineBuffer, l:beginP, l:endP)
      " void parameter
      if ( l:strBuf == l:voidStr )
        startinsert!
        break
      endif
"      exec "normal o" . g:DoxygenToolkit_paramTag . l:strBuf
       call AppendText(l:comTag . g:DoxygenToolkit_paramTag . l:strBuf)
      let l:beginP = l:endP + 2
      let l:argList = 1
     endif
   endwhile

   " Add blank line if necessary
   if ( l:argList != 0 )
     exec "normal `do"
   endif
   
   " move the cursor to the correct position (after brief tag)
   exec "normal `d"
    startinsert!
endfunction


""""""""""""""""""""""""""
" Doxygen license comment
""""""""""""""""""""""""""
function! <SID>DoxygenLicenseFunc()
  " Test authorName variable
  if !exists("g:DoxygenToolkit_authorName")
    let g:DoxygenToolkit_authorName = input("Enter name of the author (generally yours...) : ")
  endif
  mark d
  let l:date = strftime("%Y")
"  exec "normal O/**\n" . g:DoxygenToolkit_licenseTag
  exec "normal O/*\<Enter>" . g:DoxygenToolkit_licenseTag
  exec "normal ^c$*/"
  if ( g:DoxygenToolkit_licenseTag == s:licenseTag )
    exec "normal %jA" . l:date . " - " . g:DoxygenToolkit_authorName
  endif
  exec "normal `d"
endfunction


""""""""""""""""""""""""""
" Doxygen author comment
""""""""""""""""""""""""""
function! <SID>DoxygenAuthorFunc()
  " Test authorName variable
  if !exists("g:DoxygenToolkit_authorName")
    let g:DoxygenToolkit_authorName = input("Enter name of the author (generally yours...) : ")
  endif

  " Get file name
  let l:beginP = 0
  let l:prevBeginP = 0
  while ( l:beginP != -1 )
    let l:prevBeginP = l:beginP
    let l:beginP = match(argv(0), '/', l:prevBeginP + 1)
  endwhile
  let l:fileName = strpart(argv(0), l:prevBeginP)
  
  " Begin to write skeleton
"  exec "normal O/**\n" . g:DoxygenToolkit_fileTag . l:fileName
  exec "normal O"
  call AppendText("///")
  call AppendText("/// " . g:DoxygenToolkit_fileTag . l:fileName)
"  exec "normal o" . g:DoxygenToolkit_briefTag
  call AppendText("/// " . g:DoxygenToolkit_briefTag)
  " Deplace mark to brief if author name is defined
  mark d
"  exec "normal o" . g:DoxygenToolkit_authorTag . g:DoxygenToolkit_authorName
  call AppendText("/// " . g:DoxygenToolkit_authorTag . g:DoxygenToolkit_authorName)
  let l:date = strftime("%Y-%m-%d")
"  exec "normal o" . g:DoxygenToolkit_dateTag . l:date ."\n"
  call AppendText("/// " . g:DoxygenToolkit_dateTag . l:date)
  call AppendText("///")
"  exec "normal ^c$*/"

  " Replace the cursor to the rigth position
  exec "normal `d"
  startinsert!
endfunction


""""""""""""""""""""""""""
" Doxygen undocument function
""""""""""""""""""""""""""
function! <SID>DoxygenUndocumentFunc(blockTag)
	let l:search = "#ifdef " . a:blockTag
  " Save cursor position and go to the begining of the file
  mark d
  exec "normal gg"

	while ( search(l:search, 'W') != 0 )
    exec "normal O#ifndef " . g:DoxygenToolkit_undocTag
    exec "normal j^%"
"    exec "normal o#endif /* " . g:DoxygenToolkit_undocTag . " */"
    exec "normal o#endif // " . g:DoxygenToolkit_undocTag 
  endwhile

  exec "normal `d"
endfunction



""""""""""""""""""""""""""
" DoxygenBlockFunc
""""""""""""""""""""""""""
function! <SID>DoxygenBlockFunc()
  exec "normal o/**\<enter>" . g:DoxygenToolkit_blockTag
  mark d
  exec "normal o@{ */\<enter>/** @} */"
  exec "normal `d"
  startinsert!
endfunction

function! AppendText(text)
  call append(line("."), a:text)
  exec "normal j" 
endfunction

"
" Returns the indentations level for a line
" MakeIndent([lineNum])
"
function! MakeIndent(...)
   let line = getline(".")
   if a:0 == 1 
      let line = getline(a:1)
   endif
   return matchstr(line, '^\s*')
endfunction

""""""""""""""""""""""""""
" Extract the name of argument
""""""""""""""""""""""""""
function ReturnArgName(argBuf, beginP, endP)
  
  " Name of argument is at the end of argBuf if no default (id arg = 0)
  let l:equalP = match(a:argBuf, "=", a:beginP)
  if ( l:equalP == -1 || l:equalP > a:endP )
    " Look for arg name begining
    let l:beginP = a:beginP 
    let l:prevBeginP = l:beginP
    while ( l:beginP < a:endP && l:beginP != -1 )
      let l:prevBeginP = l:beginP
      let l:beginP = match(a:argBuf, " ", l:beginP + 1)
    endwhile
    let l:beginP = l:prevBeginP
    let l:endP = a:endP
  else
    " Look for arg name begining
    let l:addPos = 0
    let l:beginP = a:beginP
    let l:prevBeginP = l:beginP
    let l:doublePrevBeginP = l:prevBeginP
    while ( l:beginP < l:equalP && l:beginP != -1 )
      let l:doublePrevBeginP = l:prevBeginP
      let l:prevBeginP = l:beginP + l:addPos
      let l:beginP = match(a:argBuf, " ", l:beginP + 1)
      let l:addPos = 1
    endwhile

    " Space just before equal
    if ( l:prevBeginP == l:equalP )
      let l:beginP = l:doublePrevBeginP
      let l:endP = l:prevBeginP - 2
    else
      " No space just before so...
      let l:beginP = l:prevBeginP
      let l:endP = l:equalP - 1
    endif
  endif
  
  " We have the begining position and the ending position...
  let l:newBuf = strpart(a:argBuf, l:beginP, l:endP - l:beginP + 1)

  " Delete leading '*' or '&'
  if ( match(l:newBuf, "*") == 1 || match(l:newBuf, "&") == 1 )
    let l:newBuf = strpart(l:newBuf, 2)
  endif

  " Delete tab definition ([])
  let l:delTab = match(newBuf, "[") 
  if ( l:delTab != -1 )
    let l:newBuf = strpart(l:newBuf, 0, l:delTab)
  endif

  " Eventually clean argument name...
  let l:newBuf = substitute(l:newBuf, " ", "", "g")
  return l:newBuf

endfunction



""""""""""""""""""""""""""
" Shortcuts...
""""""""""""""""""""""""""
command! -nargs=0 Dox :call <SID>DoxygenCommentFunc()
command! -nargs=0 DoxLic :call <SID>DoxygenLicenseFunc()
command! -nargs=0 DoxAuthor :call <SID>DoxygenAuthorFunc()
command! -nargs=1 DoxUndoc :call <SID>DoxygenUndocumentFunc(<q-args>)
command! -nargs=0 DoxBlock :call <SID>DoxygenBlockFunc()
