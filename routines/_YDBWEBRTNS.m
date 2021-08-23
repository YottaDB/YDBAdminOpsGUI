%YDBWEBRTNS ; YottaDB Routines Explorer; 05-07-2021
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
	Q
	;
	;
GETROUTINESLIST(I,O)
	new pattern,sysrtns
	set pattern=$get(I("data","PATTERN"))
	set sysrtns=$get(I("data","SYS"))
	if pattern="" set pattern="*"
	new routines,response set response=$name(O("data"))
	do GetRoutineList^%YDBUTILS(.routines,pattern)
	new paths,id,counter,octoroutines set octoroutines=0
	set id="" for  set id=$order(routines(id)) quit:id=""  do
	. if $zextract(id)="%",sysrtns="false" set octoroutines=octoroutines+1 quit
	. if $increment(counter) do
	. . set @response@("RLIST",counter,"r")=id
	. . set @response@("RLIST",counter,"p")=routines(id)
	. . if routines(id)]"" set paths(routines(id))=""
	set @response@("RTOTAL")=$get(routines,0)-octoroutines
	set id="",counter=0 for  set id=$order(paths(id)) quit:id=""  do
	. if $increment(counter) set @response@("PLIST",counter)=id
	quit
	;
	;
POPULATEROUTINE(I,O)
	new routine,path,response
	set response=$name(O("data"))
	set routine=$get(I("data","RTN"))
	set path=$get(I("data","PATH"))
	new file,fullpath
	set fullpath=path
	if $zextract(routine)="%" set fullpath=fullpath_"_"_$zextract(routine,2,$zlength(routine))_".m"
	else  set fullpath=fullpath_routine_".m"
	if $$FileExists^%YDBUTILS(fullpath) do  if 1
	. do ReadFileByLine^%YDBUTILS(fullpath,.file) 
	. set @response@("STATUS")="true"
	else  set @response@("STATUS")="false" quit
	merge @response@("CODE")=file zkill @response@("CODE")
	quit
	;
SAVEROUTINE(I,O)
	new response,data,routine,path
	merge data=I("data","DATA") if '$data(data) set @response@("STATUS")="false" quit
	set routine=$get(I("data","ROUTINE")) if routine=""  set @response@("STATUS")="false" quit
	set path=$get(I("data","PATH")) if path=""  set @response@("STATUS")="false" quit
	set response=$name(O("data"))
	if $zextract(routine)="%" set $zextract(routine)="_"
	do WriteFile^%YDBUTILS(path_routine_".m",.data)
	if $$FileExists^%YDBUTILS(path_routine_".m") do  if 1
	. do ReadFileByLine^%YDBUTILS(path_routine_".m",.file) 
	merge @response@("CODE")=file zkill @response@("CODE")
	set @response@("STATUS")="true"
	quit	
	;	
GETROUTINEPATHS(I,O)
	new id,response
	set response=$name(O("data"))
	do RoutinePaths^%YDBUTILS(.id)
	if '$data(id) set @response@("STATUS")="false" quit
	merge @response@("PATHS")=id set @response@("STATUS")="true"
	quit
	;	
CREATENEWROUTINE(I,O)
	new routine,path,response
	set response=$name(O("data"))
	set routine=$get(I("data","ROUTINE")) if routine="" set @response@("STATUS")="false" quit
	set path=$get(I("data","PATH")) if path="" set @response@("STATUS")="false" quit
	if $zextract(routine)="%" set $zextract(routine)="_"
	if $$FileExists^%YDBUTILS(path_"/"_routine_".m") S @response@("STATUS")="false" quit
	if '$$DirectoryExists^%YDBUTILS(path) set @response@("STATUS")="false" quit
	new id set id(1)=I("data","ROUTINE")
	do WriteFile^%YDBUTILS(path_"/"_routine_".m",.id)
	set @response@("STATUS")="true" 
	quit
	;
DELETEROUTINE(I,O)
	new reponse,data,routine,path
	set routine=$get(I("data","ROUTINE")) if routine=""  set @response@("STATUS")="false" quit
	set path=$get(I("data","PATH")) if path=""  set @response@("STATUS")="false" quit
	set response=$name(O("data"))
	if $zextract(routine)="%" set $zextract(routine)="_"
	do DeleteFile^%YDBUTILS(path_routine_".m")
	set @response@("STATUS")="true"
	quit
	;
	;
