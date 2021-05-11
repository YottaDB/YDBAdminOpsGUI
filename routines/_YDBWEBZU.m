%YDBWEBZU ;Job Exam Routine; 05-07-2021
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
	;	
EN ;See that escape processing is off, Conflict with Screenman
	U $P:(NOCENABLE:NOESCAPE)
	N $ESTACK,$ETRAP S $ETRAP="D ERR^%YDBWEBZU Q:$QUIT -9 Q"
	S $ZINTERRUPT="I $$JOBEXAM^%YDBWEBZU($ZPOSITION)"
	D COUNT^%YDBWEBXUSCNT(1)
	;
	;
ERR ;Come here on error
	; handle stack overflow errors specifically
	I $P($ZS,",",3)["STACKCRIT"!("STACKOFLOW"[$P($ZS,",",3)) S $ET="Q:$ST>"_($ST-8)_"  G ERR2^%YDBWEBZU" Q
	;
ERR2 ;
	S $ETRAP="D UNWIND^%YDBWEBZU" L  ;Backup Trap
	U $P:NOCENABLE
	Q:$ECODE["<PROG>"
	;
	S $ET="D HALT^%YDBWEBZU"
	;
	I $P($ZS,",",3)'["-CTRLC" S XUERF="" G ^%YDBWEBXUSCLEAN ;419
CTRLC U $P
	W !,"--Interrupt Acknowledged",!
	D KILL1^%YDBWEBXUSCLEAN ;Clean up symbol table
	S $ECODE=",<<POP>>,"
	Q
	;
UNWIND ;Unwind the stack
	Q:$ESTACK>1  G CTRLC2:$ECODE["<<POP>>"
	S $ECODE=""
	Q
	;
CTRLC2 S $ECODE="" G:$G(^YDBWEB("YDBWEBZSY","XQ",$J,"T"))<2 ^%YDBWEBXUSCLEAN
	S ^YDBWEB("YDBWEBZSY","XQ",$J,"T")=1,XQY=$G(^(1)),XQY0=$P(XQY,"^",2,99)
	G:$P(XQY0,"^",4)'="M" HALT
	S XQPSM=$P(XQY,"^",1),XQY=+XQPSM,XQPSM=$P(XQPSM,XQY,2,3)
	G:'XQY ^%YDBWEBXUSCLEAN
	S $ECODE="",$ETRAP="D ERR^%YDBWEBZU Q:$QUIT 0 Q"
	U $P:NOESCAPE
	G M1^XQ
	;
HALT I $D(^YDBWEB("YDBWEBZSY","XQ",$J)) D:$G(DUZ)>0 BYE^%YDBWEBXUSCLEAN
	D COUNT^%YDBWEBXUSCNT(-1)
	HALT
	;
JOBEXAM(%ZPOS) ;
	Q $$JOBEXAM^%YDBWEBZSY(%ZPOS)  ; FOIA improved by Sam
	;
	;
	;