#!/bin/bash

#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source $(pkg-config --variable=prefix yottadb)/ydb_env_set
$ydb_dist/mupip set -journal=before,enable,on -region YDBOCTO
git clone https://gitlab.com/YottaDB/DBMS/YDBOcto.git YDBOcto-master
$ydb_dist/mupip load YDBOcto-master/tests/fixtures/northwind.zwr
octo -f YDBOcto-master/tests/fixtures/northwind.sql
