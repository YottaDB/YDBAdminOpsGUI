%YDBUTILS1 ; YottaDB Utilities Routine; 05-07-2021
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
RoutinePaths(directory)
	new zro,piece,I,count,path
	set zro=$zroutines
	set count=1
	kill directory	
	for  quit:($zextract(zro)'=" ")  set zro=$zextract(zro,2,$zlength(zro))
	for I=1:1:$zlength(zro," ") set piece=$zpiece(zro," ",I) do
	. quit:$zpiece(piece,".",2)="so"
	. quit:$zpiece(piece,".",2)="o"
	. if piece["(",piece[")" set path=$zpiece($zpiece(piece,"(",2),")")
	. if piece["(" set path=$zpiece(piece,"(",2)
	. if piece[")" set path=$zpiece(piece,")")
	. if piece'[")",piece'["("  set path=piece
	. if $$DirectoryExists^%YDBUTILS(path) set directory(count)=path
	. set count=count+1
	quit
	;
DeleteFile(file)
	open file
	close file:(delete)
	quit
	;
