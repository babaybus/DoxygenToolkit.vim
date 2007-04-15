" DoxygenToolkit.vim
" Brief: Usefull tools for Doxygen (comment, author, license).
" Version: 0.1.17
" Date: 04/15²07
" Author: Mathias Lorente
"
" Note: Number of lines scanned is now configurable. Default value is still 10
"     lines. (Thanks to Spencer Collyer for this improvement).
"
" Note: Bug correction : function that returns null pointer are correctly
"     documented (Thanks to Ronald WAHL for his report and patch).
"
" Note: Remove header and footer from doxygen documentation
"   - Generated documentation with block header/footer activated (see
"     parameters g:DoxygenToolkit_blockHeader and
"     g:DoxygenToolkit_blockFooter) do not integrate header and footer
"     anymore.
"     Thanks to Justin RANDALL for this.
"     Now comments are as following:
"     /* --- My Header --- */             // --- My Header ---
"     /**                                 /// @brief ...
"      *  @brief ...                or    // --- My Footer ---
"      */
"     /* -- My Footer --- */
"
" Note: Changes to customize cinoptions
"   - New option available for cinoptions : g:DoxygenToolkit_cinoptions
"     (default value is still c1C1)
"     Thanks to Arnaud GODET for this. Now comment can have the following
"     look:
"     /**                      /**
"     *       and not only     *
"     */                       */
" Note: Changes for linux kernel comment style
"   - New option are available for brief tag and parameter tag ! Now there is
"     a pre and a post tag for each of these tag.
"   - You can define 'let g:DoxygenToolkit_briefTag_funcName = "yes"' to add
"     the name of commented function between pre-brief tag and post-brief tag.
"   - With these new features you can get something like:
"     /**
"      * @brief MyFunction -
"      *
"      * @param foo:
"      * @param bar:
"      */
" Note: Changes suggested by Soh Kok Hong:
"   - Fixed indentation in comments
"     ( no more /**               /**
"                 *       but      *
"                 */               */     )
" Note: Changes made by Jason Mills:
"   - Fixed \n bug which resulted in comments being screwed up
"   - Added use of doxygen /// comments.
" Note: Changes made by Mathias Lorente on 05/25/04
"   - Fixed filename bug when including doxygen author comment whereas file
"     has not been open directly on commamd line.
"   - Now /// or /** doxygen comments are correctly integrated (except for
"     license).
" Note: Changes made by Mathias Lorente on 08/02/04
"   - Now include only filename in author comment (no more folder...)
"   - Fixed errors with function with no indentation.
"
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
" - Type of comments ( /// or /** ... */ ) :
"   In vim, default comments are : /** ... */. But if you prefer to use ///
"   Doxygen comments just add 'let g:DoxygenToolkit_commentType = "C++"'
"   (without quotes) in your .vimrc file
"
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
" - Assumes that cindent is used. 
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
" let g:DoxygenToolkit_briefTag_pre="@Synopsis  "
" let g:DoxygenToolkit_paramTag_pre="@Param "
" let g:DoxygenToolkit_returnTag="@Returns   "
" let g:DoxygenToolkit_blockHeader="--------------------------------------------------------------------------"
" let g:DoxygenToolkit_blockFooter="----------------------------------------------------------------------------"
" let g:DoxygenToolkit_authorName="Mathias Lorente"
" let g:DoxygenToolkit_licenseTag="My own license\<enter>"   <-- Do not forget
" ending "\<enter>"


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
if !exists("g:DoxygenToolkit_briefTag_pre")
	let g:DoxygenToolkit_briefTag_pre = "@brief "
endif
if !exists("g:DoxygenToolkit_briefTag_post")
	let g:DoxygenToolkit_briefTag_post = ""
endif
if !exists("g:DoxygenToolkit_paramTag_pre")
	let g:DoxygenToolkit_paramTag_pre = "@param "
endif
if !exists("g:DoxygenToolkit_paramTag_post")
	let g:DoxygenToolkit_paramTag_post = " "
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
if !exists("g:DoxygenToolkit_classTag")
	let g:DoxygenToolkit_classTag = "@class "
endif

if !exists("g:DoxygenToolkit_cinoptions")
    let g:DoxygenToolkit_cinoptions = "c1C1"
endif
if !exists("g:DoxygenToolkit_startCommentTag ")
	let g:DoxygenToolkit_startCommentTag = "/** "
	let g:DoxygenToolkit_startCommentBlock = "/* "
endif
if !exists("g:DoxygenToolkit_interCommentTag ")
	let g:DoxygenToolkit_interCommentTag = "* "
endif
if !exists("g:DoxygenToolkit_endCommentTag ")
	let g:DoxygenToolkit_endCommentTag = "*/"
	let g:DoxygenToolkit_endCommentBlock = " */"
endif
if exists("g:DoxygenToolkit_commentType")
	if ( g:DoxygenToolkit_commentType == "C++" )
		let g:DoxygenToolkit_startCommentTag = "/// "
		let g:DoxygenToolkit_interCommentTag = "/// "
		let g:DoxygenToolkit_endCommentTag = ""
		let g:DoxygenToolkit_startCommentBlock = "// "
		let g:DoxygenToolkit_endCommentBlock = ""
	endif
else
	let g:DoxygenToolkit_commentType = "C"
endif

if !exists("g:DoxygenToolkit_ignoreForReturn")
	let g:DoxygenToolkit_ignoreForReturn = "inline static virtual void"
else
	let g:DoxygenToolkit_ignoreForReturn = g:DoxygenToolkit_ignoreForReturn . " inline static virtual void"
endif

" Maximum number of lines to check for function parameters
if !exists("g:DoxygenToolkit_maxFunctionProtoLines")
	let g:DoxygenToolkit_maxFunctionProtoLines = 10
endif

" Add name of function after pre brief tag if you want
if !exists("g:DoxygenToolkit_briefTag_funcName")
	let g:DoxygenToolkit_briefTag_funcName = "no"
endif


""""""""""""""""""""""""""
" Doxygen comment function 
""""""""""""""""""""""""""
function! <SID>DoxygenCommentFunc()
	" Store indentation
	let l:oldcinoptions = &cinoptions
	" Set new indentation
	let &cinoptions=g:DoxygenToolkit_cinoptions
	
	let l:argBegin = "\("
	let l:argEnd = "\)"
	let l:argSep = ','
	let l:sep = "\ "
	let l:voidStr = "void"

	let l:classDef = 0

	" Save standard comment expension
	let l:oldComments = &comments
	let &comments = ""

	" Store function in a buffer
	let l:lineBuffer = getline(line("."))
	mark d
	let l:count=1
	" Return of function can be defined on other line than the one of the 
	" function.
	while ( l:lineBuffer !~ l:argBegin && l:count < 4 )
		" This is probbly a class (or something else definition)
		if ( l:lineBuffer =~ "{" || l:lineBuffer =~ ";" )
			let l:classDef = 1
			break
		endif
		exec "normal j"
		let l:line = getline(line("."))
		let l:lineBuffer = l:lineBuffer . ' ' . l:line
		let l:count = l:count + 1
	endwhile
	if ( l:classDef == 0 )
		if ( l:count == 4 )
			" Restore standard comment expension
			let &comments = l:oldComments 
			" Restore indentation
			let &cinoptions = l:oldcinoptions
			return
		endif
		" Get the entire function
		let l:count = 0
		while ( l:lineBuffer !~ l:argEnd && l:count < g:DoxygenToolkit_maxFunctionProtoLines )
			exec "normal j"
			let l:line = getline(line("."))
			let l:lineBuffer = l:lineBuffer . ' ' . l:line
			let l:count = l:count + 1
		endwhile
		" Function definition seem to be too long...
		if ( l:count == g:DoxygenToolkit_maxFunctionProtoLines )
			" Restore standard comment expension
			let &comments = l:oldComments 
			" Restore indentation
			let &cinoptions = l:oldcinoptions
			return
		endif
	endif

	" Start creating doxygen pattern
	exec "normal `d" 
	if ( g:DoxygenToolkit_blockHeader != "" )
		exec "normal O" . g:DoxygenToolkit_startCommentBlock . g:DoxygenToolkit_blockHeader . g:DoxygenToolkit_endCommentBlock
		exec "normal o" . g:DoxygenToolkit_startCommentTag . g:DoxygenToolkit_briefTag_pre
	else
		if ( g:DoxygenToolkit_commentType == "C++" )
			exec "normal O" . g:DoxygenToolkit_startCommentTag . g:DoxygenToolkit_briefTag_pre
		else
			exec "normal O" . g:DoxygenToolkit_startCommentTag
			exec "normal o" . g:DoxygenToolkit_interCommentTag . g:DoxygenToolkit_briefTag_pre
		endif
	endif
	mark d
	if ( g:DoxygenToolkit_endCommentTag != "" )
		exec "normal o" . g:DoxygenToolkit_endCommentTag
	endif
	if ( g:DoxygenToolkit_blockFooter != "" )
		exec "normal o" . g:DoxygenToolkit_startCommentBlock . g:DoxygenToolkit_blockFooter . g:DoxygenToolkit_endCommentBlock
	endif
	exec "normal `d"

	" Class definition, let's start with brief tag
	if ( l:classDef == 1 )
		" Restore standard comment expension
		let &comments = l:oldComments 
		" Restore indentation
		let &cinoptions = l:oldcinoptions

		startinsert!
		return
	endif

	" Replace tabs by space
	let l:lineBuffer = substitute(l:lineBuffer, "\t", "\ ", "g")

	" Delete recursively all double spaces
	while ( match(l:lineBuffer, "\ \ ") != -1 )
		let l:lineBuffer = substitute(l:lineBuffer, "\ \ ", "\ ", "g")
	endwhile

	" Delete space just after and just before parenthesis
	" Remove space between function name and opening paenthesis
	let l:lineBuffer = substitute(l:lineBuffer, "(\ ", "(", "")
	let l:lineBuffer = substitute(l:lineBuffer, "\ )", ")", "")
	let l:lineBuffer = substitute(l:lineBuffer, "\ (", "(", "")

	" Delete first space (if any)
	if ( match(l:lineBuffer, ' ') == 0 )
		let l:lineBuffer = strpart(l:lineBuffer, 1)
	endif

	" Add function name if requiered
	if ( g:DoxygenToolkit_briefTag_funcName =~ "yes" )
		let l:beginP = 0
		let l:currentP = -1
		let l:endP = match( l:lineBuffer, l:argBegin )
		while ( l:currentP < l:endP )
			let l:beginP = l:currentP + 1
			let l:currentP = match( l:lineBuffer, '[&*[:space:]]', l:beginP )
			if ( l:currentP == -1 )
				let l:currentP = l:endP
			endif
		endwhile
		let l:name = strpart( l:lineBuffer, l:beginP, l:endP - l:beginP )
		exec "normal A" . l:name
	endif

	" Now can add brief post tag
	exec "normal A" . g:DoxygenToolkit_briefTag_post

	" Add return tag if function do not return void
	let l:beginArgPos = match(l:lineBuffer, l:argBegin)
	let l:beginP = 0	" Name can start at the beginning of l:lineBuffer, it is usually between whitespaces or space and parenthesis
	let l:endP = 0
	let l:returnFlag = -1	" At least one name (function name) do not correspond to the list of ignored values.
	while ( l:endP != l:beginArgPos )
		" look for  * or & (pointer or reference)
		let l:endP = match(l:lineBuffer, '[&*]', l:beginP )
		if ( l:endP > l:beginArgPos || l:endP == -1 )
			" not found --> look for whitespace
			let l:endP = match(l:lineBuffer, '\s', l:beginP )
			if ( l:endP > l:beginArgPos || l:endP == -1 )
				let l:endP = l:beginArgPos
			endif
		else
			" found * or & -- so we have a return value
			let l:returnFlag = l:returnFlag + 1
		endif
		let l:name = strpart(l:lineBuffer, l:beginP, l:endP - l:beginP)
		let l:beginP = l:endP + 1
		" Hack, because of '~' is not correctly interprated by match... if you
		" have a solution, send me it !
		if ( l:name[0] != '~' && matchstr(g:DoxygenToolkit_ignoreForReturn, "\\<" . l:name . "\\>") != l:name )
			let l:returnFlag = l:returnFlag + 1
		endif
	endwhile
	if ( l:returnFlag >= 1 )	
		exec "normal o" . g:DoxygenToolkit_interCommentTag
		exec "normal o" . g:DoxygenToolkit_interCommentTag . g:DoxygenToolkit_returnTag
	endif

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
		" Restore standard comment expension
		let &comments = l:oldComments 
		" Restore indentation
		let &cinoptions = l:oldcinoptions

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
				" Restore standard comment expension
				let &comments = l:oldComments 
				" Restore indentation
				let &cinoptions = l:oldcinoptions
				
				startinsert!
				break
			endif
			exec "normal o" . g:DoxygenToolkit_interCommentTag . g:DoxygenToolkit_paramTag_pre . l:strBuf . g:DoxygenToolkit_paramTag_post
			let l:beginP = l:endP + 2
			let l:argList = 1
		endif
	endwhile

	" Add blank line if necessary
	if ( l:argList != 0 )
		exec "normal `do" . g:DoxygenToolkit_interCommentTag
	endif

	" move the cursor to the correct position (after brief tag)
	exec "normal `d"
	 
	" Restore standard comment expension
	let &comments = l:oldComments 
	" Restore indentation
	let &cinoptions = l:oldcinoptions

	startinsert!
endfunction


""""""""""""""""""""""""""
" Doxygen license comment
""""""""""""""""""""""""""
function! <SID>DoxygenLicenseFunc()
	" Store indentation
	let l:oldcinoptions = &cinoptions
	" Set new indentation
	let &cinoptions=g:DoxygenToolkit_cinoptions

	" Test authorName variable
	if !exists("g:DoxygenToolkit_authorName")
		let g:DoxygenToolkit_authorName = input("Enter name of the author (generally yours...) : ")
	endif
	mark d
	let l:date = strftime("%Y")
	exec "normal O/*\<Enter>" . g:DoxygenToolkit_licenseTag
	exec "normal ^c$*/"
	if ( g:DoxygenToolkit_licenseTag == s:licenseTag )
		exec "normal %jA" . l:date . " - " . g:DoxygenToolkit_authorName
	endif
	exec "normal `d"

	" Restore indentation
	let &cinoptions = l:oldcinoptions
endfunction


""""""""""""""""""""""""""
" Doxygen author comment
""""""""""""""""""""""""""
function! <SID>DoxygenAuthorFunc()
	" Save standard comment expension
	let l:oldComments = &comments
	let &comments = ""
	" Store indentation
	let l:oldcinoptions = &cinoptions
	" Set new indentation
	let &cinoptions=g:DoxygenToolkit_cinoptions

	" Test authorName variable
	if !exists("g:DoxygenToolkit_authorName")
		let g:DoxygenToolkit_authorName = input("Enter name of the author (generally yours...) : ")
	endif

	" Get file name
	let l:fileName = expand('%:t')

	" Begin to write skeleton
	exec "normal O" . g:DoxygenToolkit_startCommentTag
	exec "normal o" . g:DoxygenToolkit_interCommentTag . g:DoxygenToolkit_fileTag . l:fileName
	exec "normal o" . g:DoxygenToolkit_interCommentTag . g:DoxygenToolkit_briefTag_pre
	mark d
	exec "normal o" . g:DoxygenToolkit_interCommentTag . g:DoxygenToolkit_authorTag . g:DoxygenToolkit_authorName
	let l:date = strftime("%Y-%m-%d")
	exec "normal o" . g:DoxygenToolkit_interCommentTag . g:DoxygenToolkit_dateTag . l:date
	if ( g:DoxygenToolkit_endCommentTag == "" )
		exec "normal o" . g:DoxygenToolkit_interCommentTag
	else
		exec "normal o" . g:DoxygenToolkit_endCommentTag
	endif

	" Replace the cursor to the rigth position
	exec "normal `d"

	" Restore standard comment expension
	let &comments = l:oldComments
	" Restore indentation
	let &cinoptions = l:oldcinoptions
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
		if ( g:DoxygenToolkit_endCommentTag == "" )
			exec "normal o#endif // " . g:DoxygenToolkit_undocTag 
		else
			exec "normal o#endif /* " . g:DoxygenToolkit_undocTag . " */"
		endif
	endwhile

	exec "normal `d"
endfunction



""""""""""""""""""""""""""
" DoxygenBlockFunc
""""""""""""""""""""""""""
function! <SID>DoxygenBlockFunc()
	" Save standard comment expension
	let l:oldComments = &comments
	let &comments = ""
	" Store indentation
	let l:oldcinoptions = &cinoptions
	" Set new indentation
	let &cinoptions=g:DoxygenToolkit_cinoptions

	exec "normal o" . g:DoxygenToolkit_startCommentTag
	exec "normal o" . g:DoxygenToolkit_interCommentTag . g:DoxygenToolkit_blockTag
	mark d
	exec "normal o" . g:DoxygenToolkit_interCommentTag . "@{ " . g:DoxygenToolkit_endCommentTag
	exec "normal o" . g:DoxygenToolkit_startCommentTag . " @} " . g:DoxygenToolkit_endCommentTag
	exec "normal `d"
	
	" Restore standard comment expension
	let &comments = l:oldComments
	" Restore indentation
	let &cinoptions = l:oldcinoptions
	startinsert!
endfunction


"function! AppendText(text)
"	call append(line("."), a:text)
"	exec "normal j" 
"endfunction

"
" Returns the indentations level for a line
" MakeIndent([lineNum])
"
"function! MakeIndent(...)
"	let line = getline(".")
"	if a:0 == 1 
"		let line = getline(a:1)
"	endif
"	return matchstr(line, '^\s*')
"endfunction

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
