<!--
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
-->
<template>
  <div id="q-app">
    <router-view />
  </div>
</template>
<script>
export default {
  name: 'App'
}
</script>
<style>
body ::-webkit-scrollbar-track
{
    -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
    border-radius: 12px;
}

body ::-webkit-scrollbar
{
    width: 12px;
    height: 10px;
}

body ::-webkit-scrollbar-thumb
{
    border-radius: 10px;
    -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
    background-color:#85858590
}
.body--dark ::-webkit-scrollbar-track
{
    -webkit-box-shadow: inset 0 0 6px rgba(255, 255, 255, 0.3)!important;
    border-radius: 12px!important;
}

.body--dark ::-webkit-scrollbar
{
    width: 12px!important;
    height: 10px!important;
}

.body--dark ::-webkit-scrollbar-thumb
{
    border-radius: 10px!important;
    -webkit-box-shadow: inset 0 0 6px rgba(255, 255, 255, 0.3)!important;
    background-color:#80808090
}
</style>

