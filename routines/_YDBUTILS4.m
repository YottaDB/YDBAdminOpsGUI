%YDBUTILS4 ; YottaDB Utilities Routine; 05-07-2021
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
Zsystem(command,return,timeout)
	new device,currentDevice,now,timetoquit
	set timeout=$get(timeout,60*60*5) ; 5 minutes timeout
	set device="zsystem_job_"_$job_"-"_$$guid^%YDBUTILS4()_".mjo"
	set now=$zpiece($horolog,",",2)
	set timetoquit=now+timeout
	job @("ZsystemJob(command):(OUTPUT="""_device_""")")
	for  quit:('$zgetjpi($zjob,"isprocalive")!(timetoquit<$zpiece($horolog,",",2)))
	if $zsearch(device)]"" do  quit 1
	. do ReadFileByLine^%YDBUTILS(device,.return)
	. do DeleteFile^%YDBUTILS(device)
	quit 0
	;
ZsystemJob(command)
	zsystem command
	quit
	;
Zjob(command,return,timeout)
	new device,currentDevice,now,timetoquit
	set timeout=$get(timeout,60*60*5) ; 5 minutes timeout
	set device="zjob_job_"_$job_"-"_$$guid^%YDBUTILS4()_".mjo"
	set now=$zpiece($horolog,",",2)
	set timetoquit=now+timeout
	job @("ZjobJob(command):(OUTPUT="""_device_""")")
	for  quit:('$zgetjpi($zjob,"isprocalive")!(timetoquit<$zpiece($horolog,",",2)))
	if $zsearch(device)]"" do  quit 1
	. do ReadFileByLine^%YDBUTILS(device,.return)
	. do DeleteFile^%YDBUTILS(device)
	quit 0
	;
ZjobJob(command)
	xecute command
	quit
	;
DeleteFile(file)
	if $zsearch(file)]"" zsystem "rm "_file
	quit
	;
Key(length,seed)
	new i,key
	set key="" for i=1:1:length set key=key_seed($random(seed)+1)
	quit key
	;
guid()
	new str set str=$zextract(+$H,1)+$zextract(+$H,2)+$zextract(+$H,3)+$zextract(+$H,4)+$zextract(+$H,5)
	if $zlength(str)=4 set str=$zextract(str,1)+$zextract(str,1)+$zextract(str,3)+$zextract(str,4)
	if $zlength(str)=3 set str=$zextract(str,1)+$zextract(str,2)+$zextract(str,3)
	if $zlength(str)=2 set str=$zextract(str,1)+$zextract(str,2)
	new i,bkt for i=48:1:57,65:1:90 set bkt($increment(bkt))=$char(i)
	quit $$Key(8,.bkt)_"-"_$$Key(4,.bkt)_"-"_str_$$Key(3,.bkt)_"-"_$$Key(4,.bkt)_"-"_$$Key(12,.bkt)
	;
