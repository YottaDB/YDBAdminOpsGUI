<!--
#################################################################
#                                                               #
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.  #
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
     <div class="q-pa-md">
    <div style="padding:5px">
      <q-breadcrumbs gutter="xs">
        <q-breadcrumbs-el label="Home" icon="home" :to="'/'"/>
        <q-breadcrumbs-el  label="Running Processes" :to="'/processes'" icon="view_list"/>
      </q-breadcrumbs>
       <q-btn id="btn-refresh" round style="margin-right:10px" size="md" icon="refresh"  :color="!$q.dark.isActive ? 'purple' : 'orange'"  @click="refreshProcesses">
        <q-tooltip>
        Refresh running processes
        </q-tooltip>
      </q-btn>
    </div>
    <div class="row flex flex-center">
        <div class="col-auto">
    <div v-if="loading">
        <q-spinner-dots
          :color="$q.dark.isActive ? 'purple' : 'orange'"
          size="16em"
        />
        <q-tooltip :offset="[0, 8]">QSpinnerGears</q-tooltip>
      </div>
    <q-markup-table id="processes_table" flat bordered v-if="!loading" style="max-height:calc(100vh - 190px)">
      <thead :class="$q.dark.isActive ? 'bg-purple text-white' : 'bg-orange text-white'">
        <tr>
          <th colspan="5">
            <div class="row no-wrap items-center">
              <q-img
                style="width: 70px"
                :ratio="1"
                class="rounded-borders"
               src="~assets/uc-1.png"
              />

              <div id="processes_header" class="text-h4 q-ml-md text-white">Running Processes</div>
            </div>
          </th>
        </tr>
        <tr>
          <th class="text-left">PID</th>
          <th class="text-left">Process Name</th>
          <th class="text-left">Device</th>
          <th class="text-left">Routine</th>
          <th class="text-left">CPU Time</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="process in processes" :key="'pid-'+process.PID" class="table_row_processes_list">
          <td class="text-left" v-if="typeof process.PID ==='number'"><q-btn flat :id="'btn-pid-'+process.PID"  :to="'/process/'+process.PID" :class="'table_cell_process text-orange'">{{process.PID}}</q-btn></td>
          <td class="text-left" v-else>{{process.PID}}</td>
          <td class="text-left">{{process.PN}}</td>
          <td class="text-left">{{process.DV}}</td>
          <td class="text-left">{{process.RTN}}</td>
          <td class="text-left">{{process.CTM}}</td>
        </tr>
      </tbody>
    </q-markup-table>
        </div>
    </div>
     </div>
</template>
<script>

export default {
    name:'Processes',
    data(){
        return {
            processes:[],
            loading:false
        }
    },
    async mounted(){
        await this.refreshProcesses()
    },
    methods:{
        async refreshProcesses(){
            this.loading=true
            let data = await this.$M('GETPROCESSLIST^%YDBWEBPRSC')
            this.loading=false
            if (data && data.STATUS){
                this.processes = data.PROCESSES
            } else {
                this.$q.notify({
                    message:'Could not get current processes, please try again!',
                    color:'negative'
                })
            }
        },
    }
}
</script>
<style scoped>

</style>
