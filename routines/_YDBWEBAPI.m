%YDBWEBAPI ; YottaDB Web Server API Entry Point; 05-07-2021
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
API(%Q,%R,%A)
	s $ET="D ERR^%YDBWEBAPI"
	N %J
	S %R("mime")="application/json"
	S %R("header","Access-Control-Allow-Origin")="*"
	S %R("header","Access-Control-Allow-Headers")="Origin, X-Requested-With, Content-Type, Accept"
	I '$D(@%Q("body")) Q
	N %RR D DECODE^%YDBWEB(%Q("body"),"%RR")
	N %ROUTINE S %ROUTINE=%RR("routine")
	K %RR("routine") K %J
	N (%RR,%J,%WTCP,%ROUTINE,%Q,%R,%A,%YDBWEBRESP)
	D @(%ROUTINE_"(.%RR,.%J)")
	K @%R D ENCODE^%YDBWEB("%J",%R)
	U %WTCP
	Q
	;
PING(I,O)
	S O("data","RESULT")="PONG"
	Q
	;
ERR ;
	S @R@("ERROR")=$ZSTATUS
	Q
	;
	;