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
      <q-breadcrumbs gutter="xs" style="padding-left:10px;">
        <q-breadcrumbs-el label="Home" />
        <q-breadcrumbs-el label="System Explorer" />
        <q-breadcrumbs-el label="OCTO Tables" />
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
                    <!--
                  <q-item-label
                    >in {{ tablesPaths.length }} location(s)</q-item-label
                  >-->
                  </q-item-section>
                </q-item>
                <div
                  v-for="(tbl, index) in shownTableList"
                  :key="'table-list-' + index"
                >
                  <q-item
                    dense
                    clickable
                    @click="
                      filteredTbl = '';
                      populateTable(tbl);
                    "
                    :active="getCurrentActiveTable(tbl.T)"
                  >
                    <q-item-section>
                      <q-item-label>{{ tbl.T }}</q-item-label>
                    </q-item-section>
                    <!--
                  <q-item-section side>
                    <q-item-label caption>{{ tbl.p }}</q-item-label>
                  </q-item-section>
                -->
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
                <span
                  :class="
                    $q.dark.isActive
                      ? 'text-orange text-bold'
                      : 'text-purple text-bold'
                  "
                >
                  SQL Statement:
                </span>
                <codemirror
                  :key="'code-panel' + tablekey"
                  v-if="tabData && tabData[tab] && tabData[tab]['hotSettings']"
                  id="codeMirrorTables"
                  ref="cmEditor"
                  @input="onCmCodeChange"
                  :value="tabData[tab]['hotSettings'].code"
                  :options="cmOptions"
                />
                <q-btn
                  :color="$q.dark.isActive ? 'orange' : 'purple'"
                  flat
                  label="EXECUTE"
                  @click="executeSqlStatement"
                />
                <div class="row justify-center q-my-md" v-if="loadingTable">
                  <q-spinner-dots
                    :color="$q.dark.isActive ? 'purple' : 'orange'"
                    size="6em"
                  />
                </div>
                <hot-table
                  :key="'tab-panel-' + tablekey"
                  v-if="
                    tabData &&
                      tabData[tab] &&
                      tabData[tab]['hotSettings'] &&
                      tabData[tab]['hotSettings'].data.length > 0 &&
                      !loadingTable
                  "
                  :settings="tabData[tab]['hotSettings']"
                  :id="
                    $q.dark.isActive ? 'sqlhottable-dark' : 'sqlhottable-light'
                  "
                ></hot-table>
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
import { HotTable } from "@handsontable/vue";
import "codemirror/mode/sql/sql.js";
export default {
  name: "OCTOSQL",
  components: {
    codemirror,
    HotTable
  },
  data() {
    return {
      collapsed: false,
      tablekey: uid(),
      hotSettings: {
        data: [],
        licenseKey: "non-commercial-and-evaluation",
        colHeaders: true,
        rowHeaders: true,
        width: "100%",
        height: "calc(100vh - 432px)",
        colHeaders: [],
        code: "",
        cells: function() {
          var cellProperties = {};
          cellProperties.readOnly = true;
          return cellProperties;
        }
      },
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
              color: "negative "
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
      let done = false;
      setTimeout(() => {
        if (done) {
          return;
        }
        this.loadingTable = true;
      }, 500);
      let data = await this.$M("EXECUTESQL^%YDBWEBTBLS", {
        STATEMENT: this.tabData[this.tab]["hotSettings"].code
      });
      done = true;
      this.loadingTable = false;
      let code = this.tabData[this.tab]["hotSettings"]["code"];
      this.$set(this.tabData, this.tab, {});
      this.$set(
        this.tabData[this.tab],
        "hotSettings",
        Object.assign({}, this.hotSettings)
      );
      this.tabData[this.tab]["hotSettings"]["code"] = code;
      if (data && data.RESULT) {
        this.$set(
          this.tabData[this.tab]["hotSettings"],
          "data",
          data.RESULT.splice(1)
        );
        this.$set(
          this.tabData[this.tab]["hotSettings"],
          "colHeaders",
          data.RESULT[0]
        );
      }
      this.generateNewTableKey();
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
      this.$set(
        this.tabData[this.tab],
        "hotSettings",
        Object.assign({}, this.hotSettings)
      );
      this.tabData[this.tab][
        "hotSettings"
      ].code = `SELECT * FROM ${tbl.T} LIMIT 100;`;
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
      this.tabData[this.tab]["hotSettings"].code = newCode;
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
@import "~handsontable/dist/handsontable.full.css";
@import "../../../node_modules/codemirror/lib/codemirror.css";
@import "../../../node_modules/codemirror/theme/abcdef.css";
#sqlhottable-dark > .handsontable td, #sqlhottable-dark > .handsontable .htDimmed {
  background-color: #000000;
  color: #ffffff;
}
#sqlhottable-dark > .handsontable th {
  color: #ffffff;
  background-color: rgb(83, 83, 83);
}

#sqlhottable-light > .handsontable#codeMirrorTables >  td, #sqlhottable-light > .handsontable .htDimmed {
  background-color: #ffffff;
  color: #000000;
}
#sqlhottable-light > .handsontable th {
  color: #000000;
  background-color: rgb(238, 238, 238);
}

#codeMirrorTables > .CodeMirror {
  border: 1px solid #eee;
  height: 150px;
}
.wraptext,
pre {
  white-space: pre-wrap; /* Since CSS 2.1 */
  white-space: -moz-pre-wrap; /* Mozilla, since 1999 */
  white-space: -pre-wrap; /* Opera 4-6 */
  white-space: -o-pre-wrap; /* Opera 7 */
  word-wrap: break-word; /* Internet Explorer 5.5+ */
}
</style>
