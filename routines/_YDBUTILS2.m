%YDBUTILS2 ; YottaDB Utilities Routine; 05-07-2021
	;#################################################################
	;#                                                               #
	;# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.  #
	;# All rights reserved.                                          #
	;#                                                               #
	;#   This source code contains the intellectual property         #
	;#   of its copyright holder(s), and is made available           #
	;#   under a license.  If you do not know the terms of           #
	;#   the license, please stop and do not read further.           #
	;#                                                               #
	;#################################################################		
	quit
	;
RunShellCommand(command,return)
	new device,counter,string,currentdevice set counter=0
	set currentdevice=$io
	set device="runshellcommmandpipe"_$job
	open device:(shell="/bin/sh":command=command:readonly)::"pipe"
	use device for  quit:$zeof=1  read string:2 set return($increment(counter))=string quit:'$test
	close device if $get(return(counter))="" kill return(counter)
	use currentdevice
	quit
	;
DirectoryExists(path)
	quit $zsearch(path)]""
	;
FileExists(path)
	quit $zsearch(path)]""
	;
CreateDirectoryTree(path)
	new return,commmand
	set command="mkdir -p "_path
	do RunShellCommand(command,.return)
	if $$DirectoryExists(path) quit 1
	quit 0
	;
GetRoutineList(%ZR,pattern)
	if $get(pattern)="" set pattern="*"
	do SILENT^%RSEL(pattern)
	quit
	;
GetGlobalList(%ZG,pattern)
	if $get(pattern)="" set pattern="*"
	set %ZG=pattern
	do CALL^%GSEL
	zkill %ZG
	quit
	;
ReadFileByLine(file,return)
	new source,line,counter,currentdevice
	set source=file,currentdevice=$io
	open source:(readonly:chset="m")
	for  use source read line:2 quit:$zeof  quit:'$test  do
	. if $zextract(line,$zlength(line))=$char(13) set line=$zextract(line,1,$zlength(line)-1)
	. if $zextract(line,$zlength(line))=$char(10) set line=$zextract(line,1,$zlength(line)-1)
	. set return($increment(counter))=line
	close source use currentdevice
	quit
	;
ReadFileByChunk(file,chunk,return)
	new source,line,counter,currentdevice
	set currentdevice=$io
	set source=file
	open source:(readonly:fixed:recordsize=chunk:chset="m")
	for  use source read line:2 quit:$zeof  quit:'$test  do
	. set return($increment(counter))=line
	close source
	use currentdevice
	quit
	;
WriteFile(file,data)
	new currentdevice set currentdevice=$io
	open file:(newversion)
	new line set line="" for  set line=$o(data(line)) quit:line=""  use file write data(line),!
	close file
	use currentdevice
	quit
	;
UP(string)	quit $zconvert(string,"u")
LOW(string) quit $zconvert(string,"l")
