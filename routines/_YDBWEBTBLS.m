%YDBWEBTBLS ; YottaDB Globals Explorer; 05-07-2021
	;#################################################################
	;#                                                               #
	;# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
	;# All rights reserved.                                          #
	;#                                                               #
	;#   This source code contains the intellectual property         #
	;#   of its copyright holder(s), and is made available           #
	;#   under a license.  If you do not know the terms of           #
	;#   the license, please stop and do not read further.           #
	;#                                                               #
	;#################################################################		
	Q
	;
	;
GETTABLESLIST(I,O)
	new pattern,count
	set pattern=$get(I("data","PATTERN"))
	if pattern["*" set pattern=$translate(pattern,"*")
	new table,return set return=$name(O("data"))
	new list do GetOctoTables(.list)
	if $data(list) do
	. set table=$zextract(pattern,1,$zlength(pattern)-1) for  set table=$order(list(table)) quit:table=""  do
	. . if pattern]"",$zlength(pattern)<$zlength(table),table'[pattern quit
	. . if pattern]"",$zlength(pattern)>$zlength(table),pattern'[table quit
	. . if pattern]"",$zlength(pattern)=$zlength(table),pattern'=table quit
	. . if $increment(count)
	. . set @return@("TABLELIST",count,"T")=table
	set @return@("TABLETOTAL")=$get(count,0)
	Q
	;
EXECUTESQL(I,O)
	new statement,result
	set statement=$get(I("data","STATEMENT"))_";"
	new filecontent
	set filecontent(1)=statement
	new sqlFile set sqlFile="OCTO_SQL_"_$job_".sql"
	new SQLresult set SQLresult="OCTO_SQL_result_"_$job_".txt"
	do DeleteFile^%YDBUTILS(sqlFile)
	do WriteFile^%YDBUTILS(sqlFile,.filecontent)
	do RunShellCommand^%YDBUTILS("$ydb_dist/plugin/octo/bin/octo -f "_sqlFile_" > "_SQLresult)
	do DeleteFile^%YDBUTILS(sqlFile)
	do ReadFileByChunk^%YDBUTILS(SQLresult,4080,.result)
	do DeleteFile^%YDBUTILS(SQLresult)
	new line,row,piece,i,field,output,max
	set piece=1,row=1,field="",max=0
	set line="" for  set line=$order(result(line)) quit:line=""  do
	. for I=1:1:$zlength(result(line)) do
	. . if $zextract(result(line),I)=$C(10) set output(row,piece)=field set row=row+1,piece=1,field="" set:max<row max=row quit
	. . if $zextract(result(line),I)="|" set output(row,piece)=field set piece=piece+1,field="" quit
	. . set field=field_$zextract(result(line),I)
	if $data(output) do
	. new last
	. set last=$order(output(""),-1) for I=1:1:max set output(last,I)=$get(output(last,I))
	merge O("data","RESULT")=output
	set O("data","STATUS")="true"
	quit
	;
GetOctoTables(list)
	new input,output
	set input("data","STATEMENT")="select c.relname from pg_catalog.pg_class c"
	do EXECUTESQL(.input,.output)
	new last set last=$order(output("data","RESULT",""),-1)
	kill output("data","RESULT",last)
	new row set row="" for  set row=$order(output("data","RESULT",row)) quit:row=""  do
	. if output("data","RESULT",row,1)]"" set list(output("data","RESULT",row,1))=""
	quit