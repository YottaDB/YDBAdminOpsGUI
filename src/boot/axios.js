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
import Vue from 'vue'
import axios from 'axios'
// axios.defaults.timeout = 10000


axios.interceptors.request.use(x => {
  if (process.env.DEV){
  x.meta = x.meta || {}
  x.meta.requestStartedAt = new Date().getTime()
  }
  return x
})

axios.interceptors.response.use(x => {
  if (x.config.data && process.env.DEV){
    console.log('*******************************************************************************************************')
    console.log(`Request =>  ${JSON.stringify(JSON.parse(x.config.data), null, 4)} - ${new Date().getTime() - x.config.meta.requestStartedAt} ms`)
    console.log('Result =>', x.data)
  }
  return x
}
)

Vue.prototype.$axios = axios
