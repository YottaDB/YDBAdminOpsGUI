%YDBUTILS ; YottaDB Utilities Entry Point; 05-07-2021
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
RunShellCommand(COMMAND,RET) 	D RunShellCommand^%YDBUTILS2(.COMMAND,.RET) Q
DirectoryExists(PATH) 			Q $$DirectoryExists^%YDBUTILS2(.PATH)
CreateDirectoryTree(PATH) 		Q $$CreateDirectoryTree^%YDBUTILS2(.PATH)
GetRoutineList(RTNS,PATTERN) 	D GetRoutineList^%YDBUTILS2(.RTNS,.PATTERN) Q
GetGlobalList(GLBLS,PATTERN)	D GetGlobalList^%YDBUTILS2(.GLBLS,.PATTERN) Q
FileExists(PATH)				Q $$FileExists^%YDBUTILS2(.PATH)
ReadFileByLine(FILE,RET)		D ReadFileByLine^%YDBUTILS2(.FILE,.RET) Q
ReadFileByChunk(FILE,CHUNK,RET) D ReadFileByChunk^%YDBUTILS2(.FILE,.CHUNK,.RET) Q
WriteFile(FILE,DATA)			D WriteFile^%YDBUTILS2(.FILE,.DATA) Q
UP(STR)							Q $$UP^%YDBUTILS2(.STR)
LOW(STR)						Q $$LOW^%YDBUTILS2(.STR)
RoutinePaths(RET)				D RoutinePaths^%YDBUTILS1(.RET) Q
DeleteFile(FILE)				D DeleteFile^%YDBUTILS1(.FILE) Q
	;							
	;
	;