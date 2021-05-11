YDBWEBZSY ; YottaDB system status display; 05-07-2021 
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
EN ; [Public] Main Entry Point
	;From the top just show by PID
	n done,args,i,currentjob
	s done=0
	f i=1:1:$l($zcmdline," ") d
	. s args(i)=$p($zcmdline," ",i)
	i $l($g(args(1)))&($g(args(1))=+$g(args(1))) s currentjob=args(1)
	N MODE
	L +^YDBWEB("YDBWEBZSY","XUSYS","COMMAND"):1 I '$T G LW
	S MODE=0 D WORK(MODE)
	Q
	;
QUERY ; [Public] Alternate Entry Point
	N MODE,X
	L +^YDBWEB("YDBWEBZSY","XUSYS","COMMAND"):1 I '$T G LW
	S X=$$ASK W ! I X=-1 L -^YDBWEB("YDBWEBZSY","XUSYS","COMMAND") Q
	S MODE=+X D WORK(MODE)
	Q
	;
TMMGR ; [Public] Show only taskman manager tasks
	N MODE
	L +^YDBWEB("YDBWEBZSY","XUSYS","COMMAND"):1 I '$T G LW
	N FILTER S FILTER("%ZTM")="",FILTER("%ZTM0")=""
	S MODE=0 D WORK(MODE,.FILTER)
	QUIT
	;
TMSUB ; [Public] Show only taskman submanager tasks
	N MODE
	L +^YDBWEB("YDBWEBZSY","XUSYS","COMMAND"):1 I '$T G LW
	N FILTER S FILTER("%ZTMS1")=""
	S MODE=0 D WORK(MODE,.FILTER)
	QUIT
	;
ASK() ;Ask sort item
	; ZEXCEPT: %utAnswer
	I $D(%utAnswer) Q %utAnswer
	N RES,X,GROUP
	S RES=0,GROUP=2
	W !,"1 pid",!,"2 cpu time"
	F  R !,"1// ",X:600 S:X="" X=1 Q:X["^"  Q:(X>0)&(X<3)  W " not valid"
	Q:X["^" -1
	S X=X-1,RES=(X#GROUP)_"~"_(X\GROUP)
	Q RES
	;
	;
JOBEXAM(%ZPOS) ; [Public; Called by ^%YDBWEBZU]
	; Preserve old state for process
	N OLDIO S OLDIO=$IO S U=""
	N %reference S %reference=$REFERENCE
	K ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE")
	;
	; Halt the Job if requested - no need to do other work
	I $G(^YDBWEB("YDBWEBZSY","XUSYS",$J,"CMD"))="HALT" D H2^XUSCLEAN G HALT^%YDBWEBZU
	;
	;
	; Save these
	S ^YDBWEB("YDBWEBZSY","XUSYS",$J,0)=$H
	S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","INTERRUPT")=$G(%ZPOS)
	S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","ZMODE")=$ZMODE ; SMH - INTERACTIVE or OTHER
	I %ZPOS'["GTM$DMOD" S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","codeline")=$T(@%ZPOS)
	I $G(DUZ) S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","UNAME")=$P($G(^VA(200,DUZ,0)),"^")
	E           S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","UNAME")=$G(^YDBWEB("YDBWEBZSY","XUSYS",$J,"NM"))
	;
	;
	; Default System Status. ;
	; S -> Stack
	; D -> Devices
	; G -> Global Stats
	; L -> Locks
	I '$D(^YDBWEB("YDBWEBZSY","XUSYS",$J,"CMD")) ZSHOW "SGDL":^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE") ; Default case -- most of the time this is what happens. ;
	;
	; Examine the Job
	; ZSHOW "*" is "BDGILRV"
	; B is break points
	; D is Devices
	; G are global stats
	; I is ISVs
	; L is Locks
	; R is Routines with Hash (similar to S)
	; V is Variables
	; ZSHOW "*" does not include:
	; A -> Autorelink information
	; C -> External programs that are loaded (presumable with D &)
	; S -> Stack (use R instead)
	I $G(^YDBWEB("YDBWEBZSY","XUSYS",$J,"CMD"))="EXAM" ZSHOW "*":^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE")
	;
	; ^YDBWEB("YDBWEBZSY","XUSYS",8563,"JE","G",0)="GLD:*,REG:*,SET:25610,KIL:593,GET:12284,... ;
	; Just grab the default region only. Decreases the stats as a side effect from this utility
	N GLOSTAT
	N I F I=0:0 S I=$O(^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","G",I)) Q:'I  I ^(I)[$ZGLD,^(I)["DEFAULT" S GLOSTAT=^(I)
	I GLOSTAT]"" N I F I=1:1:$L(GLOSTAT,",") D
	. N EACHSTAT S EACHSTAT=$P(GLOSTAT,",",I)
	. N SUB,OBJ S SUB=$P(EACHSTAT,":"),OBJ=$P(EACHSTAT,":",2)
	. S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","GSTAT",SUB)=OBJ
	;
	; Capture IO statistics for this process
	; ZEXCEPT: READONLY,REWIND
	I $ZV["Linux" D
	. N F S F="/proc/"_$J_"/io"
	. O F:(READONLY:REWIND):0 E  Q
	. U F
	. N DONE S DONE=0 ; $ZEOF doesn't seem to work (https://github.com/YottaDB/YottaDB/issues/120)
	. N X F  R X:0 U F D  Q:DONE
	.. I X["read_bytes"  S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","RBYTE")=$P(X,": ",2)
	.. I X["write_bytes" S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","WBYTE")=$P(X,": ",2) S DONE=1
	. U OLDIO C F
	;
	; Capture String Pool Stats: Full size - Freed Data
	; spstat 2nd piece is the actual size--but that fluctuates wildly
	; I use the full size allocated (defaults at 0.10 MB) - the size freed. ;
	n spstat s spstat=$view("spsize")
	;
	S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","SPOOL")=spstat
	S ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","HEAP_MEM")=$p(spstat,",",1)-$p(spstat,",",3)
	;
	; Done. We can tell others we are ready
	SET ^YDBWEB("YDBWEBZSY","XUSYS",$J,"JE","COMPLETE")=1
	;
	;
	; Restore old IO and $R
	U OLDIO
	I %reference
	Q 1
	;
WORK(MODE,FILTER) ; [Private] Main driver, Will release lock
	; int MODE
	; FILTER ref
	N USERS,GROUP,PROCID
	N TNAME,I,SORT,TAB
	N $ES,$ET
	n %PS,RTN,%OS,DONE
	;
	;Save $ZINTERRUPT, set new one
	N OLDINT
	S OLDINT=$ZINTERRUPT,$ZINTERRUPT="I $$JOBEXAM^%YDBWEBZU($ZPOSITION) S DONE=1"
	;
	;Clear old data
	S ^YDBWEB("YDBWEBZSY","XUSYS","COMMAND")="Status"
	;
	S I=0 F  S I=$O(^YDBWEB("YDBWEBZSY","XUSYS",I)) Q:'I  K ^YDBWEB("YDBWEBZSY","XUSYS",I,"CMD"),^("JE")
	;
	; Counts; Turn on Ctrl-C. ;
	; ZEXCEPT: CTRAP,NOESCAPE,NOFILTER
	N USERS S USERS=0
	U $P:(CTRAP=$C(3):NOESCAPE:NOFILTER)
	;
	;Go get the data
	D UNIX(MODE,.USERS,.SORT)
	;
	;Now show the results
	I USERS D
	. ;D HEADER(.TAB),
	. ; PID   PName   Device       Routine                                CPU Time
	.  D USHOW(.TAB,.SORT,.FILTER)
	. ;W !!,"Total ",USERS," user",$S(USERS>1:"s.",1:"."),!
	. Q
	;E  W !,"No current GT.M users.",!
	;
	;
EXIT ;
	L -^YDBWEB("YDBWEBZSY","XUSYS","COMMAND") ;Release lock and let others in
	I $L($G(OLDINT)) S $ZINTERRUPT=OLDINT
	U $P:CTRAP=""
	Q
	;
ERR ;
	U $P W !,$P($ZS,",",2,99),!
	D EXIT
	Q
	;
LW ;Lock wait
	W !,"Someone else is running the System status now."
	Q
	;
HEADER(TAB) ;Display Header
	; ZEXCEPT: AB
	W #
	S IOM=+$$AUTOMARG
	;W !,"YottaDB System Status users on ",$$DATETIME($H)
	S TAB(0)=0,TAB(1)=6,TAB(2)=14,TAB(3)=18,TAB(4)=27,TAB(5)=46,TAB(6)=66
	S TAB(7)=75,TAB(8)=85,TAB(9)=100,TAB(10)=110,TAB(11)=115,TAB(12)=123
	S TAB(13)=130,TAB(14)=141,TAB(15)=150
	U 0:FILTER="ESCAPE"
	W !
	D EACHHEADER("PID",TAB(0))
	D EACHHEADER("PName",TAB(1))
	D EACHHEADER("Device",TAB(2))
	D EACHHEADER("Routine",TAB(4))
	D EACHHEADER("CPU Time",TAB(6))
	Q
EACHHEADER(H,TAB) ; [Internal]
	; ZEXCEPT: AB
	N BOLD S BOLD=$C(27,91,49,109)
	N RESET S RESET=$C(27,91,109)
	W ?TAB,BOLD,H,RESET
	QUIT
USHOW(TAB,SORT,FILTER) ;Display job info, sorted by pid
	; ZEXCEPT: AB
	N SI,I
	S SI=""
	F  S SI=$ORDER(SORT(SI)) Q:SI=""  F I=1:1:SORT(SI) D
	. N X,TNAME,PROCID,PROCNAME,CTIME,PS,PID,PLACE
	. S X=SORT(SI,I)
	. S PID=$P(X,"~",8)
	. S PLACE=$G(^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","INTERRUPT"))
	. ; Debug
	. ; I $D(^YDBWEB("YDBWEBZSY","XUSYS",PID)) ZWRITE ^(PID,*)
	. ; debug
	. N RTNNAME S RTNNAME=$P(PLACE,"^",2)
	. I $D(FILTER)=10 Q:$$FILTROUT(.FILTER,RTNNAME,PID)
	. N DEV D DEV(.DEV,PID)
	. S TNAME=$$DEVSEL(.DEV),PROCID=$P(X,"~",1) ; TNAME is Terminal Name, i.e. the device. ;
	. S PROCNAME=$P(X,"~",5),CTIME=$P(X,"~",6)
	. I $G(^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","ZMODE"))="OTHER" S TNAME="Background-"_TNAME
	. N UNAME S UNAME=$G(^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","UNAME"))
	. W PROCID,$C(9),PROCNAME,$C(9),TNAME,$C(9),PLACE,$C(9),CTIME,!
	. Q
	Q
	;
FILTROUT(FILTER,RTNNAME,PID) ; [Private] Should this item be filtered out?
	I RTNNAME="" QUIT 1  ; yes, filter out processes that didn't respond
	; ^YDBWEB("YDBWEBZSY","XUSYS",24754,"JE","S",1)="JOBEXAM+22^%YDBWEBZSY"
	; ^YDBWEB("YDBWEBZSY","XUSYS",24754,"JE","S",2)="JOBEXAM+2^%YDBWEBZU"
	; ^YDBWEB("YDBWEBZSY","XUSYS",24754,"JE","S",3)="GETTASK+3^%ZTMS1    ($ZINTERRUPT) "
	; ^YDBWEB("YDBWEBZSY","XUSYS",24754,"JE","S",4)="SUBMGR+1^%ZTMS1"
	n found s found=0
	N I F I=1:1 Q:'$D(^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","S",I))  do  q:found
	. i ^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","S",I)["Call-In" quit
	. i ^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","S",I)["GTM$DMOD" quit
	. n rtnName s rtnName=$p(^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","S",I),"^",2)
	. i rtnName[" " s rtnName=$p(rtnName," ")
	. n each s each=""
	. f  s each=$o(FILTER(each)) q:each=""  do  q:found
	.. i $d(FILTER(rtnName)) s found=1
	;
	; If we find it, we don't want to filter it out. ;
	QUIT 'found
	;
DEV(DEV,PID) ; [Private] Device Processing
	; Input: Global ^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","D"), PID
	; Output: .DEV
	; Device processing
	; First pass, normalize output into single lines
	N DEVCNT,X
	S DEVCNT=0
	N DI F DI=1:1 Q:'$D(^YDBWEB("YDBWEBZSY","XUSYS",PID,"JE","D",DI))  S X=^(DI) D
	. I X["CLOSED" QUIT  ; Don't print closed devices
	. I PID=$J,$E(X,1,2)="ps" QUIT  ; Don't print our ps device
	. I $E(X)'=" " S DEVCNT=DEVCNT+1,DEV(DEVCNT)=X
	. E  S DEV(DEVCNT)=DEV(DEVCNT)_" "_$$TRIM(X)
	;
	; Second Pass, identify Devices
	S DEVCNT="" F  S DEVCNT=$O(DEV(DEVCNT)) Q:DEVCNT=""  D
	. S X=DEV(DEVCNT)
	. N UPX S UPX=$ZCO(X,"U")
	. I $E(X)=0 S DEV("4JOB")="0"
	. I $P(X," ")["/dev/" S DEV("3TERM")=$P(X," ")
	. I $P(X," ")["/",$P(X," ")'["/dev/" S DEV("1FILE")=$P(X," ")
	. I UPX["SOCKET",UPX["SERVER" S DEV("2SOCK")=+$P(UPX,"PORT=",2)
	QUIT
	;
DEVSEL(DEV) ; [Private] Select Device to Print
	N DEVTYP S DEVTYP=$O(DEV(" "))
	Q:DEVTYP="" ""
	I DEVTYP="4JOB" Q "0"
	I DEVTYP="2SOCK" Q "S"_DEV(DEVTYP)
	I DEVTYP="3TERM" Q DEV(DEVTYP)
	I DEVTYP="1FILE" Q DEV(DEVTYP)
	Q "ERROR"
	;
TRIM(STR) ; [Private] Trim spaces
	Q $$FUNC^%TRIM(STR)
	;
DATETIME(HOROLOG) ;
	Q $ZDATE(HOROLOG,"DD-MON-YY 24:60:SS")
	;
UNIX(MODE,USERS,SORT) ;PUG/TOAD,FIS/KSB,VEN/SMH - Kernel System Status Report for GT.M
	N %I,U,$ET,$ES
	S $ET="D UERR^%YDBWEBZSY"
	S %I=$I,U="^"
	n procs
	D INTRPTALL(.procs)
	H .205 ; 200ms for TCP Read processes; 5ms b/c I am nice. ;
	n procgrps
	n done s done=0
	n j s j=1
	n i s i=0 f  s i=$o(procs(i)) q:'i  d
	. s procgrps(j)=$g(procgrps(j))_procs(i)_" "
	. i $l(procgrps(j))>220 s j=j+1 ; Max GT.M pipe len is 255
	f j=1:1 q:'$d(procgrps(j))  d
	. N %LINE,%TEXT,CMD
	. I $ZV["Linux" S CMD="ps o pid,tty,stat,time,cmd -p"_procgrps(j)
	. I $ZV["Darwin" S CMD="ps o pid,tty,stat,time,args -p"_procgrps(j)
	. I $ZV["CYGWIN" S CMD="for p in "_procgrps(j)_"; do ps -p $p; done | awk '{print $1"" ""$5"" n/a ""$7"" ""$8"" n/a ""}'"
	. ; ZEXCEPT: COMMAND,READONLY,SHELL
	. O "ps":(SHELL="/bin/sh":COMMAND=CMD:READONLY)::"PIPE" U "ps"
	. F  R %TEXT Q:$ZEO  D
	.. S %LINE=$$VPE(%TEXT," ",U) ; parse each line of the ps output
	.. Q:$P(%LINE,U)="PID"  ; header line
	.. D JOBSET(%LINE,MODE,.USERS,.SORT)
	. U %I C "ps"
	Q
	;
UERR ;Linux Error
	N ZE S ZE=$ZS,$EC="" U $P
	ZSHOW "*"
	Q  ;halt
	;
JOBSET(%LINE,MODE,USERS,SORT) ;Get data from a Linux job
	N %J
	N UNAME,PS,TNAME,CTIME
	S (UNAME,PS,TNAME,CTIME)=""
	N %J,PID,PROCID S (%J,PID,PROCID)=$P(%LINE,U)
	S TNAME=$P(%LINE,U,2) S:TNAME="?" TNAME="" ; TTY, ? if none
	S PS=$P(%LINE,U,3) ; process STATE
	S CTIME=$P(%LINE,U,4) ;cpu time
	N PROCNAME S PROCNAME=$P(%LINE,U,5) ; process name
	I PROCNAME["/" S PROCNAME=$P(PROCNAME,"/",$L(PROCNAME,"/")) ; get actual image name if path
	I $D(^YDBWEB("YDBWEBZSY","XUSYS",%J)) S UNAME=$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"NM"))
	E  S UNAME="unknown"
	N SI S SI=$S(MODE=0:PID,MODE=1:CTIME,1:PID)
	N I S I=$GET(SORT(SI))+1
	S SORT(SI)=I
	S SORT(SI,I)=PROCID_"~"_UNAME_"~"_PS_"~"_TNAME_"~"_PROCNAME_"~"_CTIME_"~"_""_"~"_PID
	S USERS=USERS+1
	Q
	;
VPE(%OLDSTR,%OLDDEL,%NEWDEL) ; $PIECE extract based on variable length delimiter
	N %LEN,%PIECE,%NEWSTR
	S %OLDDEL=$G(%OLDDEL) I %OLDDEL="" S %OLDDEL=" "
	S %LEN=$L(%OLDDEL)
	; each %OLDDEL-sized chunk of %OLDSTR that might be delimiter
	S %NEWDEL=$G(%NEWDEL) I %NEWDEL="" S %NEWDEL="^"
	; each piece of the old string
	S %NEWSTR="" ; new reformatted string to retun
	F  Q:%OLDSTR=""  D
	. S %PIECE=$P(%OLDSTR,%OLDDEL)
	. S $P(%OLDSTR,%OLDDEL)=""
	. S %NEWSTR=%NEWSTR_$S(%NEWSTR="":"",1:%NEWDEL)_%PIECE
	. F  Q:%OLDDEL'=$E(%OLDSTR,1,%LEN)  S $E(%OLDSTR,1,%LEN)=""
	Q %NEWSTR
	;
	; Sam's entry points
UNIXLSOF(procs) ; [Public] - Get all processes
	; (return) .procs(n)=unix process number
	; ZEXCEPT: shell,parse
	n %cmd s %cmd="lsof -t $ydb_dist/yottadb && lsof -t $ydb_dist/mumps" ;_$view("gvfile","DEFAULT")
	;s %cmd="ps ax | grep -i yottadb | awk '{print $1}'"
	i $ZV["CYGWIN" s %cmd="ps -a | grep yottadb | grep -v grep | awk '{print $1}'"
	n oldio s oldio=$IO
	o "lsof":(shell="/bin/bash":command=%cmd:parse)::"pipe"
	u "lsof"
	n i,k,tprocs f k=1:1 q:$ZEOF  r tprocs(k):1
	s k="" f  s k=$o(tprocs(k)) q:k=""  d
	. i tprocs(k)="" q 
	. i tprocs(k)=$j q
	. i $g(currentjob),tprocs(k)=currentjob q
	. s procs($i(i))=tprocs(k)
	u oldio c "lsof"
	n cnt s cnt=0
	n i f i=0:0 s i=$o(procs(i)) q:'i  i $i(cnt)
	quit:$Q cnt quit
	;
INTRPT(%J) ; [Public] Send mupip interrupt (currently SIGUSR1)
	N SIGUSR1,A
	I $ZV["Linux" S SIGUSR1=10
	I $ZV["Darwin" S SIGUSR1=30
	I $ZV["CYGWIN" S SIGUSR1=30
	;N % S %=$ZSIGPROC(%J,"SIGUSR1")
	D RunShellCommand^%YDBUTILS("$ydb_dist/mupip INTRPT "_%J,.A)
	QUIT
	;
INTRPTALL(procs) ; [Public] Send mupip interrupt to every single database process
	N SIGUSR1,A
	I $ZV["Linux" S SIGUSR1=10
	I $ZV["Darwin" S SIGUSR1=30
	I $ZV["CYGWIN" S SIGUSR1=30
	; Collect processes
	D UNIXLSOF(.procs)
	; Signal all processes
	N i,% s i=0 f  s i=$o(procs(i)) q:'i  D RunShellCommand^%YDBUTILS("$ydb_dist/mupip INTRPT "_procs(i),.A) ;S %=$ZSIGPROC(procs(i),"SIGUSR1")
	QUIT
	;
HALTALL ; [Public] Gracefully halt all jobs accessing current database
	; Calls ^XUSCLEAN then HALT^%YDBWEBZU
	;Clear old data
	S ^YDBWEB("YDBWEBZSY","XUSYS","COMMAND")="Status"
	N I F I=0:0 S I=$O(^YDBWEB("YDBWEBZSY","XUSYS",I)) Q:'I  K ^YDBWEB("YDBWEBZSY","XUSYS",I,"JE"),^("INTERUPT")
	;
	; Get jobs accessing this database
	n procs d UNIXLSOF(.procs)
	;
	; Tell them to stop
	n i f i=1:1 q:'$d(procs(i))  s ^YDBWEB("YDBWEBZSY","XUSYS",procs(i),"CMD")="HALT"
	K ^YDBWEB("YDBWEBZSY","XUSYS",$J,"CMD")  ; but not us
	;
	; Sayonara
	N J F J=0:0 S J=$O(^YDBWEB("YDBWEBZSY","XUSYS",J)) Q:'J  D INTRPT(J)
	;
	; Wait; Long hang for TCP jobs that can't receive interrupts for .2 seconds
	H .25
	;
	; Check that they are all dead. If not, kill it "softly". ;
	; Need to do this for node and java processes that won't respond normally. ;
	N J F J=0:0 S J=$O(^YDBWEB("YDBWEBZSY","XUSYS",J)) Q:'J  I $zgetjpi(J,"isprocalive"),J'=$J D KILL(J)
	;
	quit
	;
HALTONE(%J) ; [Public] Halt a single process
	S ^YDBWEB("YDBWEBZSY","XUSYS",%J,"CMD")="HALT"
	D INTRPT(%J)
	H .25 ; Long hang for TCP jobs that can't receive interrupts
	I $zgetjpi(%J,"isprocalive") D KILL(%J)
	QUIT
	;
KILL(%J) ; [Private] Kill %J
	; ZEXCEPT: shell
	n %cmd s %cmd="kill "_%J
	o "kill":(shell="/bin/sh":command=%cmd)::"pipe" u "kill" c "kill"
	quit
	;
ZJOB(PID) G JOBVIEWZ ; [Public, Interactive] Examine a specific job -- written by OSEHRA/SMH
EXAMJOB(PID) G JOBVIEWZ ;
VIEWJOB(PID) G JOBVIEWZ ;
JOBVIEW(PID) G JOBVIEWZ ;
JOBVIEWZ ;
	; ZEXCEPT: CTRAP,NOESCAPE,NOFILTER,PID
	U $P:(CTRAP=$C(3):NOESCAPE:NOFILTER)
	I $G(PID) D JOBVIEWZ2(PID) QUIT
	D ^%YDBWEBZSY
	N X,DONE
	S DONE=0
	; Nasty read loop. I hate read loops
	F  D  Q:DONE
	. R !,"Enter a job number to examine (^ to quit): ",X:$G(DTIME,300)
	. E  S DONE=1 QUIT
	. I X="^" S DONE=1 QUIT
	. I X="" D ^%YDBWEBZSY QUIT
	. I X["?" D ^%YDBWEBZSY QUIT
	. ;
	. D JOBVIEWZ2(X)
	. D ^%YDBWEBZSY
	QUIT
	;
PROCESSDETAILS
	N i,args,currentjob
	f i=1:1:$l($zcmdline," ") s args(i)=$p($zcmdline," ",i)
	N X,CMD
	S X=args(1)
	S CMD=$G(args(2))
	D JOBVIEWZ2(X,CMD)
	Q
	;	
	;
JOBVIEWZ2(X,CMD) ; [Private] View Job Information
	;	
	;	
	;	
	;	
	I X'?1.N W !,"Not a valid job number." Q
	I '$zgetjpi(X,"isprocalive") W !,"This process does not exist" Q
	;
	;	
	N EXAMREAD
	N DONEONE S DONEONE=0
	D ; This is an inner read loop to refresh a process. ;
	. N % S %=$$EXAMINEJOBBYPID(X)
	. I %'=0 W !,"The job didn't respond to examination for 305 ms. You may try again." S DONEONE=1 QUIT
	. D PRINTEXAMDATA(X,CMD)
	. ;W "Enter to Refersh, V for variables, I for ISVs, K to kill",!
	. ;W "L to load variables into your ST and quit, ^ to go back: ",!
	. ;W "D to debug (broken), Z to zshow all data for debugging."
	. ;R EXAMREAD:$G(DTIME,300)
	. S DONEONE=1
	. ;I EXAMREAD="^" S DONEONE=1
	. ;I $TR(EXAMREAD,"k","K")="K" D HALTONE(X) S DONEONE=1
	QUIT
	;
EXAMINEJOBBYPID(%J) ; [$$, Public, Silent] Examine Job by PID; Non-zero output failure
	Q:'$ZGETJPI(%J,"isprocalive") -1
	K ^YDBWEB("YDBWEBZSY","XUSYS",%J,"CMD"),^("JE")
	S ^YDBWEB("YDBWEBZSY","XUSYS",%J,"CMD")="EXAM"
	D INTRPT(%J)
	N I F I=1:1:5 H .001 Q:$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"JE","COMPLETE"))
	I '$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"JE","COMPLETE")) H .2
	I '$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"JE","COMPLETE")) H .2
	I '$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"JE","COMPLETE")) Q -1
	QUIT 0
	;
PRINTEXAMDATA(%J,FLAG) ; [Private] Print the exam data
	; ^YDBWEB("YDBWEBZSY","XUSYS",8563,"JE","INTERRUPT")="GETTASK+3^%ZTMS1"
	; ^YDBWEB("YDBWEBZSY","XUSYS",8563,"JE","G",0)="GLD:*,REG:*,SET:25610,KIL:593,GET:12284,... ;
	; ^YDBWEB("YDBWEBZSY","XUSYS",8563,"JE","ZMODE")="OTHER"
	N YDBWEBZSY M YDBWEBZSY=^YDBWEB("YDBWEBZSY","XUSYS",%J)
	;
	N BOLD S BOLD="" ;$C(27,91,49,109)
	N RESET S RESET="" ;$C(27,91,109)
	N UNDER S UNDER="" ;$C(27,91,52,109)
	N DIM S DIM=$$AUTOMARG()
	;
	; List Variables?
	I $TR(FLAG,"v","V")="V" D  QUIT
	. ;W BOLD,"Variables: ",RESET,!
	. N V F V=0:0 S V=$O(YDBWEBZSY("JE","V",V)) Q:'V  W YDBWEBZSY("JE","V",V),!
	;
	;
	; List ISVs?
	I $TR(FLAG,"i","I")="I" D  QUIT
	. ;W BOLD,"ISVs: ",RESET,!
	. N I F I=0:0 S I=$O(YDBWEBZSY("JE","I",I)) Q:'I  W YDBWEBZSY("JE","I",I),!
	;
	; Normal Display: Job Info, Stack, Locks, Devices
	;W UNDER,"JOB INFORMATION FOR "_%J," (",$ZDATE(YDBWEBZSY(0),"YYYY-MON-DD 24:60:SS"),")",RESET,!
	W BOLD,"AT: ",RESET,YDBWEBZSY("JE","INTERRUPT"),": ",$G(YDBWEBZSY("JE","codeline")),!!
	;
	N CNT S CNT=1
	W BOLD,"Stack: ",RESET,!
	; Stack is funny -- print just to $ZINTERRUPT
	N S F S=$O(YDBWEBZSY("JE","R"," "),-1):-1:1 Q:YDBWEBZSY("JE","R",S)["$ZINTERRUPT"  D
	. N PLACE S PLACE=$P(YDBWEBZSY("JE","R",S),":")
	. I $E(PLACE)=" " QUIT  ; GTM adds an extra level sometimes for display -- messes me up
	. W CNT,". "
	. I PLACE'["GTM$DMOD" W PLACE,?40,$T(@PLACE)
	. W !
	. S CNT=CNT+1
	W CNT,". ",YDBWEBZSY("JE","INTERRUPT"),":",?40,$G(YDBWEBZSY("JE","codeline")),!
	;
	W !
	W BOLD,"Locks: ",RESET,!
	N L F L=0:0 S L=$O(YDBWEBZSY("JE","L",L)) Q:'L  W YDBWEBZSY("JE","L",L),!
	;
	W !
	W BOLD,"Devices: ",RESET,!
	N D F D=0:0 S D=$O(YDBWEBZSY("JE","D",D)) Q:'D  W YDBWEBZSY("JE","D",D),!
	;
	W !
	W BOLD,"Breakpoints: ",RESET,!
	N B F B=0:0 S B=$O(YDBWEBZSY("JE","B",B)) Q:'B  W YDBWEBZSY("JE","B",B),!
	;
	W !
	W BOLD,"Global Stats for default region: ",RESET,!
	N G S G=""
	N SLOTS S SLOTS=+DIM\15
	N SLOT S SLOT=0
	F  S G=$O(YDBWEBZSY("JE","GSTAT",G)) Q:G=""  D
	. I G="GLD" QUIT
	. N V S V=YDBWEBZSY("JE","GSTAT",G)
	. I V>9999 S V=$J(V/1024,"",0)_"k"
	. I V>9999,V["k" S V=$J(V/1024,"",0)_"m"
	. W ?(SLOT*15),G,": ",V," "
	. S SLOT=SLOT+1
	. I SLOT+1>SLOTS S SLOT=0 W !
	W !!
	;
	W BOLD,"String Pool (size,currently used,freed): ",RESET,YDBWEBZSY("JE","SPOOL"),!!
	QUIT
	;
LOADST ; [Private] Load the symbol table into the current process
	KILL
	N V F V=0:0 S V=$O(^TMP("YDBWEBZSY",$J,V)) Q:'V  S @^(V)
	K ^TMP("YDBWEBZSY",$J)
	QUIT
	;
DEBUG(%J) ; [Private] Debugging logic
		Q
	Q:'$ZGETJPI(%J,"isprocalive") -1
	K ^YDBWEB("YDBWEBZSY","XUSYS",%J,"CMD"),^("JE")
	S ^YDBWEB("YDBWEBZSY","XUSYS",%J,"CMD")="DEBUG"
	D INTRPT(%J)
	N I F I=1:1:5 H .001 Q:$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"JE","COMPLETE"))
	I '$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"JE","COMPLETE")) H .2
	I '$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"JE","COMPLETE")) H .1
	I '$G(^YDBWEB("YDBWEBZSY","XUSYS",%J,"JE","COMPLETE")) Q -1
	N YDBWEBZSY M YDBWEBZSY=^YDBWEB("YDBWEBZSY","XUSYS",%J)
	;
	N BOLD S BOLD=$C(27,91,49,109)
	N RESET S RESET=$C(27,91,109)
	N UNDER S UNDER=$C(27,91,52,109)
	N DIM S DIM=$$AUTOMARG()
	;
	; Normal Display: Job Info, Stack, Locks, Devices
	W #
	W UNDER,"JOB INFORMATION FOR "_%J," (",$ZDATE(YDBWEBZSY(0),"YYYY-MON-DD 24:60:SS"),")",RESET,!
	W BOLD,"AT: ",RESET,YDBWEBZSY("JE","INTERRUPT"),": ",YDBWEBZSY("JE","codeline"),!!
	;
	N CNT S CNT=1
	W BOLD,"Stack: ",RESET,!
	; Stack is funny -- print just to $ZINTERRUPT
	N S F S=$O(YDBWEBZSY("JE","R"," "),-1):-1:1 Q:YDBWEBZSY("JE","R",S)["$ZINTERRUPT"  D
	. N PLACE S PLACE=$P(YDBWEBZSY("JE","R",S),":")
	. I $E(PLACE)=" " QUIT  ; GTM adds an extra level sometimes for display -- messes me up
	. W CNT,". "
	. I PLACE'["GTM$DMOD" W PLACE,?40,$T(@PLACE)
	. W !
	. S CNT=CNT+1
	W CNT,". ",YDBWEBZSY("JE","INTERRUPT"),":",?40,YDBWEBZSY("JE","codeline"),!
	;
	W !
	W BOLD,"Locks: ",RESET,!
	N L F L=0:0 S L=$O(YDBWEBZSY("JE","L",L)) Q:'L  W YDBWEBZSY("JE","L",L),!
	;
	W !
	W BOLD,"Devices: ",RESET,!
	N D F D=0:0 S D=$O(YDBWEBZSY("JE","D",D)) Q:'D  W YDBWEBZSY("JE","D",D),!
	W !
	W BOLD,"Breakpoints: ",RESET,!
	N B F B=0:0 S B=$O(YDBWEBZSY("JE","B",B)) Q:'B  W YDBWEBZSY("JE","B",B),!
	;
	n x r "press key to continue",x
	QUIT
	;
AUTOMARG() ;RETURNS IOM^IOSL IF IT CAN and resets terminal to those dimensions; GT.M
	; ZEXCEPT: APC,TERM,NOECHO,WIDTH
	I $PRINCIPAL'["/dev/" quit:$Q "" quit
	U $PRINCIPAL:(WIDTH=0)
	N %I,%T,ESC,DIM S %I=$I,%T=$T D
	. ; resize terminal to match actual dimensions
	. S ESC=$C(27)
	. U $P:(TERM="R":NOECHO)
	. W ESC,"7",ESC,"[r",ESC,"[999;999H",ESC,"[6n"
	. R DIM:1 E  Q
	. W ESC,"8"
	. I DIM?.APC U $P:(TERM="":ECHO) Q
	. I $L($G(DIM)) S DIM=+$P(DIM,";",2)_"^"_+$P(DIM,"[",2)
	. U $P:(TERM="":ECHO:WIDTH=+$P(DIM,";",2):LENGTH=+$P(DIM,"[",2))
	; restore state
	U %I I %T
	; Extra just for ^ZJOB - don't wrap
	U $PRINCIPAL:(WIDTH=0)
	Q:$Q $S($G(DIM):DIM,1:"") 
	Q
	;
	;
	;