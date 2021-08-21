%YDBWEBPRSC ; YottaDB Running Processes GUI; 05-07-2021
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
	;
GETPROCESSLIST(I,O)
	new response set response=$name(O("data"))
	new id,cmd
	if '$$Zjob^%YDBUTILS4("do ^%YDBWEBZSY",.id) set @response@("STATUS")="false" quit
	if '$data(id) set @response@("STATUS")="false" quit
	new idb,pid,processName,device,routine,ctm,I
	set idb="" for  set idb=$order(id(idb)) quit:idb=""  do
	. set pid=$zpiece(id(idb),$C(9))
	. set processName=$zpiece(id(idb),$C(9),2)
	. set device=$zpiece(id(idb),$C(9),3)
	. set routine=$zpiece(id(idb),$C(9),4)
	. set ctm=$zpiece(id(idb),$C(9),5)
	. if $increment(I) do
	. . set @response@("PROCESSES",I,"PID")=pid
	. . set @response@("PROCESSES",I,"PN")=processName
	. . set @response@("PROCESSES",I,"DV")=device
	. . set @response@("PROCESSES",I,"RTN")=routine
	. . set @response@("PROCESSES",I,"CTM")=ctm
	set @response@("STATUS")="true"
	quit
	;
ISPROCESSALIVE(I,O)
	new response set response=$name(O("data"))
	new pid set pid=$get(I("data","PID")) if pid="" set @response@("STATUS")="false" quit
	if pid'?1.n set @response@("STATUS")="false" quit
	if '$zgetjpi(pid,"isprocalive") set @response@("STATUS")="false" quit
	set @response@("STATUS")="true"
	quit
	;
PROCESSDETAILS(I,O)
	new response set response=$name(O("data"))
	new pid set pid=$get(I("data","PID")) if pid="" set @response@("STATUS")="false" quit
	if pid'?1.n set @response@("STATUS")="false" quit
	if '$zgetjpi(pid,"isprocalive") set @response@("STATUS")="false" quit
	new id if $$Zsystem^%YDBUTILS4("$ydb_dist/yottadb -run PROCESSDETAILS^%YDBWEBZSY "_pid,.id)
	merge @response@("DETAILS")=id
	kill id if $$Zsystem^%YDBUTILS4("$ydb_dist/yottadb -run PROCESSDETAILS^%YDBWEBZSY "_pid_" "_"V",.id)
	merge @response@("VARIABLES")=id
	kill id if $$Zsystem^%YDBUTILS4("$ydb_dist/yottadb -run PROCESSDETAILS^%YDBWEBZSY "_pid_" "_"I",.id)
	merge @response@("IVARIABLES")=id
	set @response@("STATUS")="true"
	quit
	;
KILLPROCESS(I,O)
	new response set response=$name(O("data"))
	new pid set pid=$get(I("data","PID")) if pid="" set @response@("STATUS")="false" quit
	if pid'?1.n set @response@("STATUS")="false" quit
	if '$ZGETJPI(pid,"isprocalive") set @response@("STATUS")="false" quit
	do RunShellCommand^%YDBUTILS("$ydb_dist/mupip STOP "_pid)
	set @response@("STATUS")="true"
	quit
	;
TestLongProcess
	job LongProcess
	write $zjob
	quit
	;
LongProcess
	hang 60*60*60
	quit
	;
TEST1
	new I,output
	do GETPROCESSLIST(.I,.output)
	zwrite output
	quit
	;
TEST2
	set $et="write $zstatus"
	new id,cmd
	set cmd="$ydb_dist/yottadb -run ^%YDBWEBZSY "_$job_""
	do RunShellCommand^%YDBUTILS(cmd,.id)
	if $d(id) zwrite id
	else  write "No id"
	quit
	;
TEST3
	zsystem "$ydb_dist/yottadb -run '^%YDBWEBZSY "_$job_"'"
	quit
	;
TEST4
	do GETPROCESSLIST(.I,.O)
	quit
