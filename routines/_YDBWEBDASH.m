%YDBWEBDASH ; YottaDB Dashboard; 11-23-2021
	;#################################################################
	;#                                                               #
	;# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
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
FREECNT(output,regions)
	new region,counter
	set region=$view("GVFIRST")
	do  for  set region=$view("GVNEXT",region) quit:region=""  do
	. if $increment(counter)
	. set output(counter,"REGION")=region
	. set regions(output(counter,"REGION"))=""
	. set output(counter,"FREE")=$view("FREEBLOCKS",region)
	. set output(counter,"TOTAL")=$view("TOTALBLOCKS",region)
	. set output(counter,"PERCENT")=$justify(output(counter,"FREE")/output(counter,"TOTAL")*100.0,5,1)
	. set output(counter,"USED")=output(counter,"TOTAL")-output(counter,"FREE")
	. set output(counter,"FILE")=$view("GVFILE",region)
	quit
	;
PEEKBYNAME(output,regions)
	new counter 
	set counter=0
	new region set region=""
	for  set region=$order(regions(region)) quit:region=""  do
	. set counter=counter+1
	. set output(region,counter,1)="Asynchronous I/O"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.asyncio",region)
	. set counter=counter+1
	. set output(region,counter,1)="Block size"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.blk_size",region)
	. set counter=counter+1
	. set output(region,counter,1)="Journal align size"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.alignsize",region)
	. set counter=counter+1
	. set output(region,counter,1)="Journal autoswitch limit"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.autoswitchlimit",region)
	. set counter=counter+1
	. set output(region,counter,1)="Journal before imaging"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.jnl_before_image",region)
	. set counter=counter+1
	. set output(region,counter,1)="Lock space"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.lock_space_size",region)
	. set counter=counter+1
	. set output(region,counter,1)="Maximum key size"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.max_key_size",region)
	. set counter=counter+1
	. set output(region,counter,1)="Maximum record size"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.max_rec_size",region)
	. set counter=counter+1
	. set output(region,counter,1)="Null subscripts"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.null_subs",region)
	. set counter=counter+1
	. set output(region,counter,1)="Number of global buffers (dirty)"
	. set output(region,counter,2)=$$^%PEEKBYNAME("node_local.wcs_active_lvl",region)
	. set counter=counter+1
	. set output(region,counter,1)="Number of global buffers (total)"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.n_bts",region)
	. set counter=counter+1
	. set output(region,counter,1)="Number of processes accessing the database"
	. set output(region,counter,2)=$$^%PEEKBYNAME("node_local.ref_cnt",region)
	. set counter=counter+1
	. set output(region,counter,1)="Region open"
	. set output(region,counter,2)=$$^%PEEKBYNAME("gd_region.open",region)
	. set counter=counter+1
	. set output(region,counter,1)="Region replication sequence number"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.reg_seqno",region)
	. set counter=counter+1
	. set output(region,counter,1)="Spanning nodes absent"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.span_node_absent",region)
	. set counter=counter+1
	. set output(region,counter,1)="Write errors"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.wcs_wterror_invoked_cntr",region)
	. set counter=counter+1
	. set output(region,counter,1)="Writes in progress"
	. set output(region,counter,2)=$$^%PEEKBYNAME("node_local.wcs_wip_lvl",region)
	. set counter=counter+1
	. set output(region,counter,1)="Commit wait spin count"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.wcs_phase2_commit_wait_spincnt",region)
	. set counter=counter+1
	. set output(region,counter,1)="Current transaction"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.trans_hist.curr_tn",region)
	. set counter=counter+1
	. set output(region,counter,1)="Defer allocate"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.defer_allocate",region)
	. set counter=counter+1
	. set output(region,counter,1)="Extension size"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.extension_size",region)
	. set counter=counter+1
	. set output(region,counter,1)="Flush trigger"
	. set output(region,counter,2)=$$^%PEEKBYNAME("sgmnt_data.flush_trigger",region)
	quit
	;	
GETDATA(i,o)
	new response,output,regions,routput,rresponse
	do FREECNT(.output,.regions)
	do PEEKBYNAME(.routput,.regions)
	set response=$name(o("data","FREECNT"))
	set rresponse=$name(o("data","PEEKBYNAME"))
	merge @response=output
	merge @rresponse=routput
	quit
