<!--
#################################################################
#                                                               #
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
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
    <div>
      <q-breadcrumbs gutter="xs">
        <q-breadcrumbs-el label="Home" icon="home" :to="'/'"/>
        <q-breadcrumbs-el label="Dashboard" :to="'/dashboard'" icon="view_list"/>
      </q-breadcrumbs>
    </div>
    <div class="row items-start q-gutter-md flex flex-center">
      <div class="col-auto"  v-for="region in regions" :key="region" :name="region">
        <div>
          <table class="free">
            <tr>
              <td>
                <h4>{{ region }}</h4>
              </td>
            </tr>
            <tr>
              <td>Free {{ regionData[region].PERCENT }}%</td>
            </tr>
            <tr>
              <td>{{ regionData[region].FILE }}</td>
            </tr>
          </table>

          <pie-chart
            :chartdata="{
              labels: ['Free ' + regionData[region].PERCENT + '%', 'Used'],
              datasets: [
                {
                  backgroundColor: ['#21BA45', '#C10015'],
                  data: [regionData[region].FREE, regionData[region].USED]
                }
              ]
            }"
            :options="{}"
          />
          <br>
          <table class="peekbyname">
            <thead>
              <tr>
                <th>Name</th>
                <th>Value</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in freeCntData.PEEKBYNAME[region]" :key="index">
                <td>{{ item[0] }}</td>
                <td>{{ item[1] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import PieChart from "./PieChart.vue";
export default {
  components: {
    PieChart,
  },
  data() {
    return {
      tab: "",
      freeCntData: [],
      regions: [],
      regionData: {},
    };
  },
  async created() {
    this.freeCntData = await this.$m("GETDATA^%YDBWEBDASH");
    this.regions = this.getRegions(this.freeCntData.FREECNT);
    this.tab = this.regions[0];
  },
  methods: {
    getRegions(data) {
      return data.map(region => {
        this.regionData[region.REGION] = {};
        this.regionData[region.REGION].FREE = region.FREE;
        this.regionData[region.REGION].USED = region.USED;
        this.regionData[region.REGION].PERCENT = region.PERCENT;
        this.regionData[region.REGION].FILE = region.FILE;
        return region.REGION;
      });
    }
  }
};
</script>
<style>
table.peekbyname th, table.peekbyname td {
  border: 1px solid gray;
  padding: 5px;
}
table.peekbyname {
  border-collapse: collapse;
}
</style>
