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
  <div class="q-pa-md" id="tablesDiv">
    <div style="padding:5px" class="row">
      <q-btn
        @click="collapseLeftSide"
        :fab="collapsed"
        :flat="!collapsed"
        dense
        padding="0px"
        icon="push_pin"
        :color="!$q.dark.isActive ? 'purple' : 'orange'"
      />
      <q-breadcrumbs gutter="xs" style="padding-left:10px;" id="breadcrumbs">
        <q-breadcrumbs-el label="Home" icon="home" :to="'/'"/>
        <q-breadcrumbs-el label="Octo" icon="account_tree" :to="'octo-sql'"/>
      </q-breadcrumbs>
    </div>
    <q-dialog v-model="loadingDialog" persistent>
      <q-card style="height:185px;width:300px">
        <q-card-section class="q-pa-md">
          <span style="font-size:18px;" class="flex flex-center"
            >Loading Tables. Please wait!</span
          >
        </q-card-section>
        <q-card-section class="q-pa-md">
          <div class="flex flex-center">
            <q-spinner-dots
              :color="$q.dark.isActive ? 'purple' : 'orange'"
              size="6em"
              v-if="loading"
              :thickness="0"
            />
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
    <transition
      enter-active-class="animated fadeIn"
      leave-active-class="animated fadeOut"
    >
      <q-splitter
        v-model="splitterModel"
        style="height:calc(100vh - 125px)"
        v-if="!loading"
        :limits="[0, 50]"
      >
        <template v-slot:before>
          <span
            :class="$q.dark.isActive ? 'text-orange' : 'text-purple'"
            style="font-size:28px;padding:5px"
            id="octo_header"
          >
            OCTO Tables
          </span>
          <q-infinite-scroll
            @load="loadMoreTables"
            :offset="0"
            ref="infscroll"
            scroll-target="#tablesDiv"
            :initial-index="1"
          >
            <div class="q-pa-md">
              <q-input
                filled
                bottom-slots
                v-model="searchTables"
                label="Search"
                :dense="true"
                @keydown.enter="getTables"
                class="input_octo_tables_search"
              >
                <template v-slot:append>
                  <q-icon
                    v-if="searchTables !== ''"
                    name="close"
                    @click="searchTables = ''"
                    class="cursor-pointer"
                  />
                  <q-icon
                    name="search"
                    class="cursor-pointer"
                    @click="getTables"
                  />
                </template>
              </q-input>
            </div>
            <div>
              <q-list>
                <q-item>
                  <q-item-section>
                    <q-item-label
                      overline
                      :class="$q.dark.isActive ? 'text-orange' : 'text-purple'"
                      >{{ tableTotal }} Table(s)</q-item-label
                    >
                  </q-item-section>
                </q-item>
                <div
                id="octo_column"
                  v-for="(tbl, index) in shownTableList"
                  :key="'table-list-' + index"
                >
                  <q-item
                    dense
                    @click="
                      filteredTbl = '';
                      populateTable(tbl);
                    "
                    :active="getCurrentActiveTable(tbl.T)"
                  >
                   <q-item-section>
                      <q-item-label><q-btn flat class="full-width"  @click="
                      filteredTbl = '';
                      populateTable(tbl);
                    " :id="'column-' + String(tbl.T)">{{ tbl.T }}</q-btn></q-item-label>
                    </q-item-section>
                  </q-item>
                  <q-separator inset />
                </div>
                <q-item
                  clickable
                  @click="loadMoreScrolledTables"
                  v-if="!finishedLoadingAllTables"
                >
                  <q-item-section>
                    <q-item-label style="margin:0 auto">load more</q-item-label>
                  </q-item-section>
                </q-item>
              </q-list>
            </div>
            <template v-slot:loading>
              <div class="row justify-center q-my-md">
                <q-spinner-dots color="primary" size="40px" />
              </div>
            </template>
          </q-infinite-scroll>
        </template>

        <template v-slot:after>
          <q-tabs
            v-model="tab"
            inline-label
            outside-arrows
            dense
            align="left"
            :class="
              $q.dark.isActive
                ? 'text-orange text-bold'
                : 'text-purple text-bold'
            "
            :breakpoint="0"
          >
            <q-tab
              ripple
              no-caps
              v-for="tab in tabs"
              :key="tab.name"
              v-bind="tab"
            >
              <q-btn
                dense
                padding="5px"
                flat
                size="sm"
                icon="close"
                @click="closeTab(tab.name)"
                :disable="tabs.length === 1"
              />
            </q-tab>
          </q-tabs>
          <div class="q-pa-md">
            <q-card>
              <q-card-section>
                <span :class="$q.dark.isActive ? 'text-orange text-bold' : 'text-purple text-bold' ">SQL Statement:</span>
                <codemirror
                  :key="'code-panel' + tablekey"
                  v-if="tabData && tabData[tab]"
                  id="codeMirrorTables"
                  ref="cmEditor"
                  @input="onCmCodeChange"
                  :value="tabData[tab].code"
                  :options="cmOptions"
                />
                <q-btn
                  :color="$q.dark.isActive ? 'orange' : 'purple'"
                  flat
                  label="EXECUTE"
                  @click="executeSqlStatement"
                  id="octo-execute-btn"
                />
                <div class="row justify-center q-my-md" v-if="loadingTable">
                  <q-spinner-dots
                    :color="$q.dark.isActive ? 'purple' : 'orange'"
                    size="6em"
                  />
                </div>
                <table :key="'tab-panel-' + tablekey" v-if="tabData && tabData[tab] && tabData[tab].data && !loadingTable"
                              :id="$q.dark.isActive ? 'sqltable-dark' : 'sqltable-light'">
                  <thead>
                    <tr>
                      <th v-for="(item, index) in tabData[tab].colHeaders" :key="index">{{ item }}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(item2, index2) in tabData[tab].data" :key="index2">
                      <td v-for="(cell, index3) in tabData[tab].data[index2]" :key="index3">{{ cell }}</td>
                    </tr>
                  </tbody>
                </table>
              </q-card-section>
            </q-card>
          </div>
        </template>
      </q-splitter>
    </transition>
  </div>
</template>
<script>
import { uid } from "quasar";
import { codemirror } from "vue-codemirror";
import "codemirror/mode/sql/sql.js";
export default {
  name: "OCTOSQL",
  components: {
    codemirror,
  },
  data() {
    return {
      octoData:[],
      collapsed: false,
      tablekey: uid(),
      tabData: {},
      tab: "",
      tabs: [],
      codeIcon: "",
      updatedNodeValue: "",
      tableRightDrawer: false,
      selectedTblNode: "",
      tableNodes: [],
      splitterModel: 15,
      searchTables: "*",
      shownTableList: [],
      shownTableIndex: 0,
      tablePatchCount: 100,
      finishedLoadingAllTables: false,
      currentActiveTable: "",
      currentActivePath: "",
      tablesList: [],
      tablesPaths: [],
      loading: false,
      loadingDialog: false,
      tableTotal: 0,
      loadingTable: false,
      loadedNodesMessage: "",
      showLoadedNodesBanner: false,
      selectedTbl: "",
      filteredTbl: "",
      nodesPagingSize: 100,
      codeLineBreak: false,
      code: "",
      cmOptions: {
        autofocus:true,
        tabSize: 4,
        lineWrapping: false,
        mode: {
          name: "sql"
        },
        theme: this.$q.dark.isActive ? "abcdef" : "default",
        lineNumbers: true,
        line: true
      }
    };
  },
  methods: {
    closeTab(tab) {
      this.$q
        .dialog({
          title: "Confirm",
          message: "Are you sure you want to close " + tab + "?",
          cancel: true,
          persistent: true
        })
        .onOk(() => {
          let index = -1;
          this.tabs.map((t, i) => {
            if (t.name == tab) {
              index = i;
            }
          });
          if (index !== -1) {
            if (
              tab === this.tab &&
              index <= this.tabs.length - 1 &&
              index > 0
            ) {
              this.tab = this.tabs[index - 1].name;
            } else if (
              tab === this.tab &&
              index === 0 &&
              this.tabs.length > 1
            ) {
              this.tab = this.tabs[1].name;
            } else if (
              tab === this.tab &&
              index === 0 &&
              this.tabs.length === 1
            ) {
              return;
            }
            this.tabs.splice(index, 1);
            delete this.tabData[tab];
          } else {
            this.$q.notify({
              message: "Couldn't find tab",
              color: "negative"
            });
          }
        });
    },
    generateNewTableKey() {
      this.tablekey = uid();
    },
    collapseLeftSide() {
      this.collapsed = !this.collapsed;
      if (this.collapsed) {
        this.splitterModel = 0;
      } else {
        this.splitterModel = this.$q.localStorage.getItem(
          "ydb-tables-splitter"
        );
        if (this.splitterModel === 0) {
          this.splitterModel = 15;
        }
      }
      this.generateNewTableKey();
    },
    async executeSqlStatement() {
      // Tell the page we need to spin while we load the table
      this.loadingTable = true;

      // Get the data
      let data = await this.$M("EXECUTESQL^%YDBWEBTBLS", {
        STATEMENT: this.tabData[this.tab].code
      });

      // Save the query as we will modify the model
      let code = this.tabData[this.tab].code;
      this.$set(this.tabData, this.tab, {});
      this.$set(this.tabData[this.tab], "code", code);

      // If we have data, show it
      if (data && data.RESULT) {
        let colHeaders = data.RESULT.shift(); // Remove the column headers
        data.RESULT.pop(); // Remove counter (x rows) from the end
        this.$set(this.tabData[this.tab], "data", data.RESULT);
        this.$set(this.tabData[this.tab], "colHeaders", colHeaders);
      }

      // Not sure what that does
      this.generateNewTableKey();

      // Tell model we finished loading
      this.loadingTable = false;
    },
    getCurrentActiveTable(tbl) {
      return this.tab === tbl;
    },
    loadMoreTables(index, done) {
      this.shownTableIndex = index;
      for (
        let i = this.shownTableIndex * this.tablePatchCount;
        i < this.shownTableIndex * this.tablePatchCount + this.tablePatchCount;
        i++
      ) {
        if (this.tablesList[i]) {
          this.shownTableList.push(this.tablesList[i]);
        } else {
          this.finishedLoadingAllTables = true;
          done(true);
          return;
        }
      }
      done();
      this.$refs.infscroll.stop();
    },
    async populateTable(tbl) {
      let tab = {
        name: tbl.T,
        label: tbl.T
      };
      let found = false;
      this.tabs.map(t => {
        if (t.name === tab.name && t.label === tab.label) {
          found = true;
        }
      });
      if (!found) {
        this.tabs.push(tab);
      }
      this.tab = tab.name;
      this.selectedTblNode = "";
      this.selectedTbl = tbl;
      this.loadedNodesMessage = "";
      this.$set(this.tabData, this.tab, {});
      this.tabData[this.tab].code = `SELECT * FROM ${tbl.T} LIMIT 100;`;
      this.currentActiveTable = tbl.T;
      await this.executeSqlStatement();
    },
    async getTables() {
      if (!this.searchTables.length) {
        return;
      }
      this.loading = true;
      this.loadingDialog = true;
      let done = false;
      setTimeout(() => {
        if (done) {
          return;
        }
        this.loading = true;
        this.loadingDialog = true;
      }, 0);
      this.shownTableList = [];
      this.shownTableIndex = 0;
      this.finishedLoadingAllTables = false;
      let data = await this.$M("GETTABLESLIST^%YDBWEBTBLS", {
        PATTERN: this.searchTables
      });
      done = true;
      this.loading = false;
      this.loadingDialog = false;
      if (data && data.TABLETOTAL) {
        this.tableTotal = data.TABLETOTAL;
      } else {
        this.tableTotal = 0;
      }
      if (data && data.TABLELIST) {
        this.tablesList = data.TABLELIST;
      } else {
        this.tablesList = [];
      }
      for (
        let i = this.shownTableIndex * this.tablePatchCount;
        i < this.shownTableIndex * this.tablePatchCount + this.tablePatchCount;
        i++
      ) {
        if (this.tablesList[i]) {
          this.shownTableList.push(this.tablesList[i]);
        } else {
          this.finishedLoadingAllTables = true;
        }
      }
    },
    loadMoreScrolledTables() {
      this.$refs.infscroll.resume();
      this.$refs.infscroll.trigger();
    },
    onCmCodeChange(newCode) {
      this.tabData[this.tab].code = newCode;
    }
  },
  computed: {
    theme() {
      return this.$q.dark.isActive;
    },
    codemirror() {
      return this.$refs.cmEditor.codemirror;
    }
  },
  watch: {
    theme(v) {
      if (v) {
        this.$set(this.cmOptions, "theme", "abcdef");
      } else {
        this.$set(this.cmOptions, "theme", "default");
      }
    },
    splitterModel(v) {
      if (v === 0) {
        this.collapsed = true;
      } else {
        this.collapsed = false;
        this.$q.localStorage.set("ydb-tables-splitter", v);
      }
    },
    collapsed(v) {
      this.$q.localStorage.set("ydb-tables-collapsed", v);
    },
    tab(v) {
      this.generateNewTableKey();
    }
  },
  async created() {
    this.collapsed = !!this.$q.localStorage.getItem("ydb-tables-collapsed");
    if (this.collapsed) {
      this.splitterModel = 0;
    } else {
      this.splitterModel =
        this.$q.localStorage.getItem("ydb-tables-splitter") || 15;
    }
  },
  async mounted() {
    await this.getTables();
    if (this.shownTableList[0]) {
      this.populateTable(this.shownTableList[0]);
    }
  }
};
</script>
<style>
@import "../../../node_modules/codemirror/lib/codemirror.css";
@import "../../../node_modules/codemirror/theme/abcdef.css";
#sqltable-dark td {
  background-color: #000000;
  color: #ffffff;
}
#sqltable-dark th {
  color: #ffffff;
  background-color: rgb(83, 83, 83);
}

#sqltable-light td {
  color: #000000;
  background-color: #ffffff;
}
#sqltable-light th {
  color: #000000;
  background-color: rgb(238, 238, 238);
}

#sqltable-dark th, #sqltable-light td {
  border: 1px solid gray;
}

#sqltable-dark, #sqltable-light {
  border-collapse: collapse;
}

#codeMirrorTables > .CodeMirror {
  border: 1px solid #eee;
  height: 150px;
}

.wraptext, pre {
  white-space: pre-wrap; /* Since CSS 2.1 */
}
</style>
