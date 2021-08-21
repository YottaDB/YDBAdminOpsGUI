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
        <q-breadcrumbs-el icon="computer" :label="'Process ' + $route.params.pid" :to="'/process/'+$route.params.pid"/>
      </q-breadcrumbs>
      <q-btn
       id="btn-go-back"
        round
        style="margin-right:10px"
        :class="$q.dark.isActive?'bg-orange':'bg-purple'"
        size="md"
        icon="arrow_back"
        :color="'primary'"
        @click="$router.push('/processes')"
      >
        <q-tooltip>
          Go Back
        </q-tooltip>
      </q-btn>
      <q-btn
       id="btn-kill"
        round
        style="margin-right:10px"
        size="md"
        icon="delete_forever"
        :color="'negative'"
        @click="killProcess"
      >
        <q-tooltip>
          Kill Process
        </q-tooltip>
      </q-btn>
    </div>
    <q-card v-if="!processAlive">
      <q-card-section>
        <span class="text-negative" style="font-size:26px;font-wight:700">
          Process details not available!
        </span>
      </q-card-section>
    </q-card>
    <q-card v-if="processAlive">
      <q-tabs v-model="tab" dense :class="$q.dark.isActive?'bg-orange text-white shadow-2':'bg-purple text-white shadow-2'">
        <q-tab name="details" label="Process Details" id="process_details_tab"/>
        <q-tab name="variables" label="Variables" id="variables_tab" />
        <q-tab name="ivariables" label="Intrinsic Variables" id="ivariables_tab" />
      </q-tabs>
      <q-separator />

      <q-tab-panels v-model="tab" animated id="tab_panel">
        <q-tab-panel name="details" id="details_panel">
          <div :class="$q.dark.isActive?'text-h6 text-orange':'text-h6 text-purple'">
            PID:{{ $route.params.pid }} Details
          </div>
          <pre
          id="details_panel_pre"
            style="max-height:calc(100vh - 302px)"
            v-html="processDetails.join('\n')"
          ></pre>
        </q-tab-panel>

        <q-tab-panel name="variables" id="variables_panel">
          <div :class="$q.dark.isActive?'text-h6 text-orange':'text-h6 text-purple'">
            PID:{{ $route.params.pid }} Variables
          </div>
          <pre
          id="variables_panel_pre"
            style="max-height:calc(100vh - 302px)"
            v-html="processVariables.join('\n')"
          ></pre>
        </q-tab-panel>

        <q-tab-panel name="ivariables" id="ivariables_panel">
          <div :class="$q.dark.isActive?'text-h6 text-orange':'text-h6 text-purple'">
            PID:{{ $route.params.pid }} Intrinsic variables
          </div>
          <pre
          id="ivariables_panel_pre"
            style="max-height:calc(100vh - 302px)"
            v-html="processIVariables.join('\n')"
          ></pre>
        </q-tab-panel>
      </q-tab-panels>
    </q-card>
  </div>
</template>
<script>
export default {
  name: "ProcessDetails",
  data() {
    return {
      tab: "details",
      processAlive: false,
      processDetails: [],
      processVariables: [],
      processIVariables: []
    };
  },
  async mounted() {
    let data = await this.$M("PROCESSDETAILS^%YDBWEBPRSC", {
      PID: this.$route.params.pid
    });
    if (data && data.STATUS) {
      this.processAlive = true;
      this.processDetails = data.DETAILS || [];
      this.processVariables = data.VARIABLES || [];
      this.processIVariables = data.IVARIABLES || [];
    } else {
      this.processAlive = false;
    }
  },
  methods: {
    async killProcess() {
      this.$q
        .dialog({
          title: "Confirm",
          message:
            "Are you sure you want to kill process " + this.$route.params.pid,
          cancel: true,
          persistent: true
        })
        .onOk(async () => {
          let data = await this.$M("KILLPROCESS^%YDBWEBPRSC", {
            PID: this.$route.params.pid
          });
          if (data && data.STATUS) {
            this.$q.notify({
              message: "Process Killed!",
              color: "positive"
            });
            this.$router.push("/processes");
          } else {
            this.$q.notify({
              message: "Process does not exist or no longer alive!",
              color: "negative"
            });
          }
        });
    }
  }
};
</script>
