%YDBWEBGLBLS ; YottaDB Globals Explorer; 05-07-2021
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
	quit
	;
	;
GETGLOBALSLIST(I,O)
	new pattern
	set pattern=$get(I("data","PATTERN"))
	if pattern="" set pattern="*"
	new globals,response set response=$name(O("data"))
	do GetGlobalList^%YDBUTILS(.globals,pattern)
	new paths,id,counter
	set id="" for  set id=$O(globals(id)) quit:id=""  do
	. if $increment(counter) do
	. . set @response@("GLIST",counter,"g")=id
	. . if globals(id)]"" set paths(globals(id))=""
	set @response@("GTOTAL")=$get(counter,0)
	quit
	;
POPULATEGLOBALS(I,O)
	new response set response=$name(O("data"))
	new global set global=$get(I("data","GLBL"))
	new size set size=$get(I("data","SIZE")) if size="" set size=100
	new search set search=$get(I("data","SEARCH"))
	if global="" set @response@("STATUS")="false" quit
	if '$data(@global) set @response@("STATUS")="false" quit
	if search="",$order(@global@(""))="" do setnode quit
	if search]"",$order(@global@(""))="",global[search do setnode quit
	new id,counter,count set count=0,counter=0
	set id="" for  set id=$order(@global@(id)) quit:id=""  do
	. if search]"",$name(@global@(id))'[search quit
	. if size,$increment(count),counter<size,$increment(counter) do setnodes if 1
	. else  if 'size,$increment(count),$increment(counter) do setnodes
	if size,count>size set @response@("MESSAGE")=counter_" node(s) out of "_count	
	else  set @response@("MESSAGE")=counter_" node(s)"
	if $data(@response@("NODES")) set @response@("STATUS")="true"
	else  set @response@("STATUS")="false"
	quit
	;
setnode
	set @response@("NODES",1,"expandable")="false"
	set @response@("NODES",1,"label")=global
	set @response@("NODES",1,"body")="story"
	set @response@("NODES",1,"key")=global
	set @response@("NODES",1,"story")=$$GETNODEVALUE(global)
	set @response@("NODES",1,"body")="story"
	set @response@("NODES",1,"icon")="text_snippet"
	set @response@("NODES",1,"selectable")="true"
	set @response@("MESSAGE")="1 node(s)"
	set @response@("STATUS")="true"
	quit	
	;
setnodes
	set @response@("NODES",counter,"label")=$name(@global@(id))
	set @response@("NODES",counter,"key")=$name(@global@(id))
	set @response@("NODES",counter,"body")="story"
	set @response@("NODES",counter,"story")=$$GETNODEVALUE($name(@global@(id)))
	if $O(@global@(id,""))]"" set @response@("NODES",counter,"lazy")="true"
	else  set @response@("NODES",counter,"expandable")="false"
	if $data(@global@(id))=1 set @response@("NODES",counter,"icon")="text_snippet"
	if $data(@global@(id))=10 set @response@("NODES",counter,"icon")="folder"
	if $data(@global@(id))=11 set @response@("NODES",counter,"icon")="source"
	set @response@("NODES",counter,"selectable")="true"
	;I $data(@global@(id))=11 set @response@("NODES",counter,"label")=@response@("NODES",counter,"label")_"="_$E($$GETNODEVALUE($name(@global@(id))),1,100)
	quit
	;
GETNODEVALUE(global) quit $get(@global)
	;
GETGLOBALVALUE(I,O)
	new response,global
	set response=$name(O("data"))
	set global=$get(I("data","GLOBAL"))
	if global="" set @response@("STATUS")="false" quit
	if '$data(@global) set @response@("STATUS")="false" quit
	set @response@("VALUE")=$get(@global)
	if $data(@global)=1 set @response@("ICON")="text_snippet"
	if $data(@global)=10 set @response@("ICON")="folder"
	if $data(@global)=11 set @response@("ICON")="source"
	set @response@("STATUS")="true"
	quit
	;
SAVEGLOBAL(I,O)
	new global,value,response
	set response=$name(O("data"))
	set global=$get(I("data","GLOBAL")) if global="" set @response@("STATUS")="false" quit
	if '$data(I("data","VALUE")) set @response@("STATUS")="false" quit
	set value=I("data","VALUE")
	set @global=value
	if $data(@global)=1 set @response@("ICON")="text_snippet"
	if $data(@global)=10 set @response@("ICON")="folder"
	if $data(@global)=11 set @response@("ICON")="source"
	set @response@("STATUS")="true"
	set @response@("VALUE")=$get(@global)
	quit
	;
KILLGLOBAL(I,O)
	new global,value,response
	set response=$name(O("data"))
	set global=$get(I("data","GLOBAL")) if global="" set @response@("STATUS")="false" quit
	kill @global
	set @response@("STATUS")="true"
	quit
	;
ZKILLLOBAL(I,O)
	new global,value,response
	set response=$name(O("data"))
	set global=$get(I("data","GLOBAL")) if global="" set @response@("STATUS")="false" quit
	zkill @global
	if $data(@global)=1 set @response@("ICON")="text_snippet"
	if $data(@global)=10 set @response@("ICON")="folder"
	if $data(@global)=11 set @response@("ICON")="source"
	set @response@("STATUS")="true"
	quit
	;
TESTADDGLOBAL
	set ^YDBGLBLMDLTST("LEVEL1")="VALUE"
	write 1
	quit
	;
TESTCHECKGLOBAL
	write $get(^YDBGLBLMDLTST("LEVEL1"))
	quit
	;
TESTCHECKKILLEDGLOBAL
	if $get(^YDBGLBLMDLTST("LEVEL1"))="" write 1 quit
	write 2
	quit