%YDBUTILS1 ; YottaDB Utilities Routine; 05-07-2021
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
RoutinePaths(DIR)
	N ZRO,PIECE,I,CNT,PATH
	S ZRO=$ZROUTINES
	S CNT=1
	K DIR
	F  Q:($E(ZRO)'=" ")  S ZRO=$E(ZRO,2,$L(ZRO))
	F I=1:1:$L(ZRO," ") S PIECE=$P(ZRO," ",I) D
	.Q:$P(PIECE,".",2)="so"
	.Q:$P(PIECE,".",2)="o"
	.I PIECE["(",PIECE[")" S PATH=$P($P(PIECE,"(",2),")")
	.I PIECE["(" S PATH=$P(PIECE,"(",2)
	.I PIECE[")" S PATH=$P(PIECE,")")
	.I PIECE'[")",PIECE'["("  S PATH=PIECE
	.I $$DirectoryExists^%YDBUTILS(PATH) S DIR(CNT)=PATH
	.S CNT=CNT+1
	Q
	;
	;
DeleteFile(FILE)
	N RET,COMMMAND
	S COMMAND="rm "_FILE
	D RunShellCommand^%YDBUTILS(COMMAND,.RET)
	Q
	;
	;