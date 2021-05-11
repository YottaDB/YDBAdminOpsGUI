/*
#################################################################
#                                                               #
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#   This source code contains the intellectual property         #
#   of its copyright holder(s), and is made available           #
#   under a license.  If you do not know the terms of           #
#   the license, please stop and do not read further.           #
#                                                               #
#################################################################
*/
import { LocalStorage } from 'quasar'
export default function () {
  return {
    details:{
      port: LocalStorage.getItem('ydp-app-port') || '',
      protocol: LocalStorage.getItem('ydp-app-protocol') || '',
      ip: LocalStorage.getItem('ydp-app-ip') || '',
    }
  }
}
