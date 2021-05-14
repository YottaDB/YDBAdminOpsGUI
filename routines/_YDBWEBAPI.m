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
	Q
	;
SERVESTATIC(%Q,%R,%A)	
	N PATH S PATH=$G(%Q("path")) 
	I PATH="" S PATH="/YottaDB/index.html"
	I PATH="/" S PATH="/YottaDB/index.html"
	I PATH="/YottaDB" S PATH="/YottaDB/index.html"
	I PATH="/YottaDB/" S PATH="/YottaDB/index.html"
	I $E(PATH,1,9)'="/YottaDB/" D SETERROR^%YDBWEB(404) Q
	N FILEPATHS
	S FILEPATH="dist/spa/"_$E(PATH,10,$L(PATH))
	I $P(FILEPATH,".",$L(FILEPATH,"."))["?" D
	. S $P(FILEPATH,".",$L(FILEPATH,"."))=$P($P(FILEPATH,".",$L(FILEPATH,".")),"?")
	I '$$FileExists^%YDBUTILS(FILEPATH) D
	. S FILEPATH="dist/spa/index.html"
	N EXT S EXT=$P(FILEPATH,".",$L(FILEPATH,"."))
	S %R("mime")=$$GetMimeType^%YDBWEB(EXT)
	N OUTPUT
	D ReadFileByChunk^%YDBUTILS(FILEPATH,4080,.OUTPUT)
	M @%R=OUTPUT
	Q
	;	
PING(I,O)
	S O("data","RESULT")="PONG"
	Q
	;
ERR ;
	Q