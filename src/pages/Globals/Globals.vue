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
  <div class="q-pa-md" id="globalsDiv">
    <div class="row">
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
        <q-breadcrumbs-el label="Globals" />
      </q-breadcrumbs>
      <transition
        appear
        enter-active-class="animated fadeIn"
        leave-active-class="animated fadeOut"
      >
        <q-page-sticky
          v-show="loadedNodesMessage.indexOf('out of') > 0"
          position="top"
          :offset="[18, 18]"
        >
          <q-banner
            dense
            class="text-white bg-red"
            v-show="showLoadedNodesBanner"
          >
            {{ loadedNodesMessage }}
          </q-banner>
        </q-page-sticky>
      </transition>
    </div>
    <transition
      enter-active-class="animated fadeIn"
      leave-active-class="animated fadeOut"
    >
      <q-splitter
        :limits="[0, 50]"
        v-model="splitterModel"
        style="height:calc(100vh - 125px)"
        v-if="!loading && !loadingDialog"
      >
        <template v-slot:before>
          <span
            :class="$q.dark.isActive ? 'text-orange' : 'text-purple'"
            style="font-size:28px;padding:5px"
          >
            Globals
          </span>
          <q-infinite-scroll
            @load="loadMoreGlobals"
            :offset="0"
            ref="infscroll"
            scroll-target="#globalsDiv"
            :initial-index="1"
          >
            <div class="q-pa-md">
              <q-input
                filled
                bottom-slots
                v-model="searchGlobals"
                label="Search"
                :dense="true"
                @keydown.enter="getGlobals"
              >
                <template v-slot:append>
                  <q-icon
                    v-if="searchGlobals !== ''"
                    name="close"
                    @click="searchGlobals = ''"
                    class="cursor-pointer"
                  />
                  <q-icon
                    name="search"
                    class="cursor-pointer"
                    @click="getGlobals"
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
                      >{{ globalTotal }} Global(s)</q-item-label
                    >
                    <!--
                  <q-item-label
                    >in {{ globalsPaths.length }} location(s)</q-item-label
                  >-->
                  </q-item-section>
                </q-item>
                <div
                  v-for="(glbl, index) in shownGlobalList"
                  :key="'glist-' + index"
                >
                  <q-item
                    dense
                    clickable
                    @click="populateGlobal(glbl.g)"
                    :active="getCurrentActiveGlobal(glbl.g)"
                  >
                    <q-item-section>
                      <q-item-label>{{ glbl.g }}</q-item-label>
                    </q-item-section>
                    <!--
                  <q-item-section side>
                    <q-item-label caption>{{ glbl.p }}</q-item-label>
                  </q-item-section>
                -->
                  </q-item>
                  <q-separator inset />
                </div>
                <q-item
                  clickable
                  @click="loadMoreScrolledGlobals"
                  v-if="!finishedLoadingAllGlobals"
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
          <div class="q-pa-xs">
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
          </div>
          <div class="q-pa-md q-col-gutter-sm">
            <div
              v-if="loadingNodes"
              class="flex items-center justify-center"
              style="height:calc(100vh - 125px);"
            >
              <q-spinner-dots
                :color="$q.dark.isActive ? 'purple' : 'orange'"
                size="10em"
              />
            </div>
            <q-card>
            <div class="row" v-if="tabData && tabData[tab] && tabData[tab]">
              <div class="col-8" style="padding:5px" v-show="!loadingNodes">
                <q-input
                  filled
                  bottom-slots
                  v-model="tabData[tab].filteredGlbl"
                  label="Globals Subscript Search"
                  :dense="true"
                  @keydown.enter="populateGlobal(tab)"
                >
                  <template v-slot:append>
                    <q-icon
                      v-if="
                        tabData &&
                          tabData[tab] &&
                          tabData[tab].filteredGlbl !== ''
                      "
                      name="close"
                      @click="
                        tabData[tab].filteredGlbl = '';
                        populateGlobal(tab);
                      "
                      class="cursor-pointer"
                    />
                    <q-icon
                      name="search"
                      class="cursor-pointer"
                      @click="populateGlobal(tab)"
                    />
                  </template>
                </q-input>
              </div>
              <div class="col-4" style="padding:5px" v-show="!loadingNodes">
                <q-select
                  @input="populateGlobal(tab)"
                  dense
                  filled
                  v-model="tabData[tab].nodesPagingSize"
                  :options="[100, 500, 1000]"
                  label="Number of nodes to show"
                />
              </div>
            </div>
            <div
              class="row"
              v-show="!loadingNodes"
              v-if="tabData && tabData[tab] && tabData[tab]"
            >
              <q-tree
                :nodes="tabData && tabData[tab] && tabData[tab].globalNodes"
                node-key="key"
                :selected.sync="tabData[tab].selectedGlblNode"
                @lazy-load="onLazyLoadGlobalNodes"
                icon="arrow_forward_ios"
              >
                <template v-slot:default-body="prop">
                  <pre
                    :class="$q.dark.isActive ? 'text-orange' : 'text-purple'"
                    style="margin:0px 0px 0px 0px;padding:0px"
                    >{{ prop.node.story }}</pre
                  >
                </template>
              </q-tree>
            </div>
            </q-card>
          </div>
        </template>
      </q-splitter>
    </transition>
    <q-dialog v-model="loadingDialog" persistent>
      <q-card style="height:185px;width:300px">
        <q-card-section class="q-pa-md">
          <span style="font-size:18px;" class="flex flex-center"
            >Loading Globals. Please wait!</span
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
    <q-drawer
      v-if="tabData && tabData[tab] && tabData[tab]"
      side="right"
      v-model="tabData[tab].globalRightDrawer"
      @hide="
        tabData[tab].code = '';
        tabData[tab].codeIcon = '';
        tabData[tab].globalRightDrawer = false;
        tabData[tab].selectedGlblNode = '';
      "
      bordered
      :width="800"
      overlay
      content-class="width:800px"
    >
      <q-card style="height:100%">
        <q-bar
          :class="
            !$q.dark.isActive ? 'bg-purple text-white' : 'bg-orange text-white'
          "
          color="white"
        >
          Global Node Value
          <q-space />
          <q-btn
            dense
            flat
            icon="close"
            color="white"
            @click="
              tabData[tab].code = '';
              tabData[tab].codeIcon = '';
              tabData[tab].globalRightDrawer = false;
              tabData[tab].selectedGlblNode = '';
            "
          />
        </q-bar>
        <q-card-section>
          <q-icon
            :name="tabData && tabData[tab] && tabData[tab].codeIcon"
            style="font-size: 5rem;"
          />
          <span class="wraptext">{{
            tabData && tabData[tab] && tabData[tab].selectedGlblNode
          }}</span>
        </q-card-section>
        <q-card-section>
          <codemirror
            id="codeMirrorGlobals"
            ref="cmEditor"
            @input="onCmCodeChange"
            :value="tabData && tabData[tab] && tabData[tab].code"
            :options="cmOptions"
          />
        </q-card-section>
        <q-card-section>
          <pre>
            Character Count: {{ tabData[tab].code.length }}
          </pre>
          <div class="q-gutter-sm">
            <q-radio v-model="codeLineBreak" :val="true" label="Wrap Line(s)" />
            <q-radio
              v-model="codeLineBreak"
              :val="false"
              label="Don't Wrap Line(s)"
            />
          </div>
        </q-card-section>
        <q-card-actions align="right" class="text-primary">
          <q-btn flat label="SAVE (SET)" @click="saveGlobal" />
          <q-btn
            flat
            color="negative"
            label="KILL GLOBAL (KILL)"
            @click="killGlobal"
          />
          <q-btn
            v-if="
              tabData &&
                tabData[tab] &&
                tabData[tab].codeIcon !== 'text_snippet'
            "
            flat
            color="purple"
            label="REMOVE VALUE (ZKILL)"
            @click="zkillGlobal"
          />
          <q-btn
            flat
            color="orange"
            label="CANCEL"
            @click="
              tabData[tab].code = '';
              tabData[tab].codeIcon = '';
              tabData[tab].globalRightDrawer = false;
              tabData[tab].selectedGlblNode = '';
            "
          />
        </q-card-actions>
      </q-card>
    </q-drawer>
  </div>
</template>
<script>
import { codemirror } from "vue-codemirror";
export default {
  name: "Globals",
  components: {
    codemirror
  },
  data() {
    return {
      tabData: {},
      tab: "",
      tabs: [],
      collapsed: false,
      updatedNodeValue: "",
      splitterModel: 15,
      searchGlobals: "*",
      shownGlobalList: [],
      shownGlobalIndex: 0,
      globalPatchCount: 100,
      finishedLoadingAllGlobals: false,
      globalsList: [],
      loading: false,
      loadingDialog: false,
      globalTotal: 0,
      loadingNodes: false,
      loadedNodesMessage: "",
      showLoadedNodesBanner: false,
      codeLineBreak: false,
      code: "",
      cmOptions: {
        tabSize: 4,
        lineWrapping: false,
        mode: {
          name: "text"
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
    async onLazyLoadGlobalNodes(node) {
      this.loadedNodesMessage = "";
      let done = false;
      setTimeout(() => {
        if (done) {
          return;
        }
        this.loadingNodes = true;
      }, 1000);
      let data = await this.$M("POPULATEGLOBALS^%YDBWEBGLBLS", {
        GLBL: node.key,
        SEARCH: this.tabData[this.tab].filteredGlbl,
        SIZE: this.tabData[this.tab].nodesPagingSize
      });
      done = true;
      this.loadingNodes = false;
      if (data.STATUS) {
        node.done(data.NODES);
        if (data.MESSAGE && data.MESSAGE.indexOf("out of") > 0) {
          this.loadedNodesMessage = data.MESSAGE;
          this.showLoadedNodesBanner = true;
          setTimeout(() => {
            this.showLoadedNodesBanner = false;
          }, 5000);
        } else if (data.MESSAGE) {
          this.loadedNodesMessage = data.MESSAGE;
        }
      } else {
        node.done([]);
        this.$q.notify({
          message: "Globals could not be found!",
          color: "negative"
        });
      }
    },
    collapseLeftSide() {
      this.collapsed = !this.collapsed;
      if (this.collapsed) {
        this.splitterModel = 0;
      } else {
        this.splitterModel = this.$q.localStorage.getItem(
          "ydb-globals-splitter"
        );
        if (this.splitterModel === 0) {
          this.splitterModel = 15;
        }
      }
      this.generateNewTableKey();
    },
    getCurrentActiveGlobal(glbl) {
      return this.tab === glbl;
    },
    loadMoreGlobals(index, done) {
      this.shownGlobalIndex = index;
      for (
        let i = this.shownGlobalIndex * this.globalPatchCount;
        i <
        this.shownGlobalIndex * this.globalPatchCount + this.globalPatchCount;
        i++
      ) {
        if (this.globalsList[i]) {
          this.shownGlobalList.push(this.globalsList[i]);
        } else {
          this.finishedLoadingAllGlobals = true;
          done(true);
          return;
        }
      }
      done();
      this.$refs.infscroll.stop();
    },
    async populateGlobal(glbl) {
      let tab = {
        name: glbl,
        label: glbl
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
      this.$set(this.tabData, this.tab, this.tabData[this.tab] || {});
      this.$set(
        this.tabData[this.tab],
        "code",
        (this.tabData[this.tab] && this.tabData[this.tab].code) || ""
      );
      this.$set(
        this.tabData[this.tab],
        "globalRightDrawer",
        (this.tabData[this.tab] && this.tabData[this.tab].globalRightDrawer) ||
          false
      );
      this.$set(
        this.tabData[this.tab],
        "filteredGlbl",
        (this.tabData[this.tab] && this.tabData[this.tab].filteredGlbl) || ""
      );
      this.$set(
        this.tabData[this.tab],
        "nodesPagingSize",
        (this.tabData[this.tab] && this.tabData[this.tab].nodesPagingSize) ||
          100
      );
      this.$set(this.tabData[this.tab], "globalNodes", []);
      this.$set(this.tabData[this.tab], "codeIcon", "");
      this.$set(this.tabData[this.tab], "selectedGlblNode", "");
      this.loadedNodesMessage = "";
      let done = false;
      setTimeout(() => {
        if (done) {
          return;
        }
        this.loadingNodes = true;
      }, 1000);
      let data = await this.$M("POPULATEGLOBALS^%YDBWEBGLBLS", {
        GLBL: this.tab,
        SEARCH: this.tabData[this.tab].filteredGlbl,
        SIZE: this.tabData[this.tab].nodesPagingSize
      });
      done = true;
      this.loadingNodes = false;
      if (data.STATUS) {
        this.$set(this.tabData[this.tab], "globalNodes", data.NODES);

        if (data.MESSAGE && data.MESSAGE.indexOf("out of") > 0) {
          this.loadedNodesMessage = data.MESSAGE;
          this.showLoadedNodesBanner = true;
          setTimeout(() => {
            this.showLoadedNodesBanner = false;
          }, 5000);
        } else if (data.MESSAGE && data.MESSAGE) {
          this.loadedNodesMessage = data.MESSAGE;
        }
      } else {
        this.$set(this.tabData[this.tab], "globalNodes", []);
        this.$q.notify({
          message: "Globals could not be found!",
          color: "negative"
        });
      }
    },
    async getGlobals() {
      if (!this.searchGlobals.length) {
        return;
      }
      let done = false;
      setTimeout(() => {
        if (done) {
          return;
        }
        this.loading = true;
        this.loadingDialog = true;
      }, 1000);
      this.shownGlobalList = [];
      this.shownGlobalIndex = 0;
      this.finishedLoadingAllGlobals = false;
      let data = await this.$M("GETGLOBALSLIST^%YDBWEBGLBLS", {
        PATTERN: this.searchGlobals
      });
      if (data && data.GTOTAL) {
        this.globalTotal = data.GTOTAL;
      } else {
        this.globalTotal = 0;
      }
      if (data && data.GLIST) {
        this.globalsList = data.GLIST;
      } else {
        this.globalsList = [];
      }
      for (
        let i = this.shownGlobalIndex * this.globalPatchCount;
        i <
        this.shownGlobalIndex * this.globalPatchCount + this.globalPatchCount;
        i++
      ) {
        if (this.globalsList[i]) {
          this.shownGlobalList.push(this.globalsList[i]);
        } else {
          this.finishedLoadingAllGlobals = true;
        }
      }
      done = true;
      this.loading = false;
      this.loadingDialog = false;
    },
    loadMoreScrolledGlobals() {
      this.$refs.infscroll.resume();
      this.$refs.infscroll.trigger();
    },
    async getSelectedGlobalValue(global) {
      let code = "";
      let icon = "";
      let data = await this.$M("GETGLOBALVALUE^%YDBWEBGLBLS", {
        GLOBAL: global
      });
      if (data && data.STATUS) {
        code = String(data.VALUE);
        icon = data.ICON;
      } else {
        code = "";
        icon = "";
        this.$q.notify({
          message: "Global couldn't be found!",
          color: "negative"
        });
      }
      return { code, icon };
    },
    onCmCodeChange(newCode) {
      this.$set(this.tabData[this.tab], "code", newCode);
    },
    async saveGlobal() {
      this.$q
        .dialog({
          title: "Confirm",
          message: "Are you sure you want to save global?",
          cancel: true,
          persistent: true
        })
        .onOk(async () => {
          let data = await this.$M("SAVEGLOBAL^%YDBWEBGLBLS", {
            GLOBAL: this.tabData[this.tab].selectedGlblNode,
            VALUE: this.tabData[this.tab].code
          });
          if (data && data.STATUS) {
            this.$q.notify({
              message: "Global saved!",
              color: "positive"
            });
            this.updateIcon(data.ICON);
            this.updateValue(data.VALUE);
            this.$set(this.tabData[this.tab], "globalRightDrawer", false);
            this.$set(this.tabData[this.tab], "code", "");
            this.$set(this.tabData[this.tab], "codeIcon", "");
            this.$set(this.tabData[this.tab], "selectedGlblNode", "");
          } else {
            this.$q.notify({
              message: "Error ocurred. Global not saved!",
              color: "negative"
            });
          }
        });
    },
    async zkillGlobal() {
      this.$q
        .dialog({
          title: "Confirm",
          message:
            "Are you sure you want to Zkill the global (remove its value) ?",
          cancel: true,
          persistent: true
        })
        .onOk(async () => {
          let data = await this.$M("ZKILLLOBAL^%YDBWEBGLBLS", {
            GLOBAL: this.tabData[this.tab].selectedGlblNode
          });
          if (data && data.STATUS) {
            this.$q.notify({
              message: "Global ZKILLED!",
              color: "positive"
            });
            this.updateIcon(data.ICON);
            this.updateValue("");
            this.$set(this.tabData[this.tab], "globalRightDrawer", false);
            this.$set(this.tabData[this.tab], "code", "");
            this.$set(this.tabData[this.tab], "codeIcon", "");
            this.$set(this.tabData[this.tab], "selectedGlblNode", "");
          } else {
            this.$q.notify({
              message: "Error ocurred. Global not ZKILLED!",
              color: "negative"
            });
          }
        });
    },
    async killGlobal() {
      this.$q
        .dialog({
          title: "Confirm",
          message: "Are you sure you want to kill the global?",
          cancel: true,
          persistent: true
        })
        .onOk(async () => {
          let data = await this.$M("KILLGLOBAL^%YDBWEBGLBLS", {
            GLOBAL: this.tabData[this.tab].selectedGlblNode
          });
          if (data && data.STATUS) {
            this.$q.notify({
              message: "Global killed!",
              color: "positive"
            });
            this.deleteNode(this.tabData[this.tab].selectedGlblNode);
            this.$set(this.tabData[this.tab], "globalRightDrawer", false);
            this.$set(this.tabData[this.tab], "code", "");
            this.$set(this.tabData[this.tab], "codeIcon", "");
            this.$set(this.tabData[this.tab], "selectedGlblNode", "");
          } else {
            this.$q.notify({
              message: "Error ocurred. Global not killed!",
              color: "negative"
            });
          }
        });
    },
    deleteNode(node) {
      let self = this;
      let nodes = this.tabData[this.tab].globalNodes;
      function parseObjectProperties(obj) {
        for (var k in obj) {
          if (typeof obj[k] === "object" && obj[k] !== null) {
            parseObjectProperties(obj[k]);
          } else if (obj.hasOwnProperty(k)) {
            if (k === "key" && obj[k] === node) {
              obj["icon"] = "delete";
              obj["label"] = obj["label"] + " " + "(killed)";
              obj["expandable"] = false;
              obj["story"] = "";
              obj["selectable"] = false;
              delete obj.children;
            }
          }
        }
      }
      parseObjectProperties(nodes);
      this.$set(this.tabData[this.tab], nodes, []);
    },
    updateIcon(icon) {
      let self = this;
      let nodes = this.tabData[this.tab].globalNodes;
      function parseObjectProperties(obj) {
        for (var k in obj) {
          if (typeof obj[k] === "object" && obj[k] !== null) {
            parseObjectProperties(obj[k]);
          } else if (obj.hasOwnProperty(k)) {
            if (
              k === "key" &&
              obj[k] === self.tabData[self.tab].selectedGlblNode
            ) {
              obj["icon"] = icon;
            }
          }
        }
      }
      parseObjectProperties(nodes);
      this.$set(this.tabData[this.tab], nodes, []);
    },
    updateValue(value) {
      let self = this;
      let nodes = this.tabData[this.tab].globalNodes;
      function parseObjectProperties(obj) {
        for (var k in obj) {
          if (typeof obj[k] === "object" && obj[k] !== null) {
            parseObjectProperties(obj[k]);
          } else if (obj.hasOwnProperty(k)) {
            if (
              k === "key" &&
              obj[k] === self.tabData[self.tab].selectedGlblNode
            ) {
              obj["story"] = value;
            }
          }
        }
      }
      parseObjectProperties(nodes);
      this.$set(this.tabData[this.tab], nodes, []);
    }
  },
  computed: {
    theme() {
      return this.$q.dark.isActive;
    },
    codemirror() {
      return this.$refs.cmEditor.codemirror;
    },
    selectedGlblNode() {
      return (
        this.tabData &&
        this.tabData[this.tab] &&
        this.tabData[this.tab].selectedGlblNode
      );
    }
  },
  watch: {
    splitterModel(v) {
      if (v === 0) {
        this.collapsed = true;
      } else {
        this.collapsed = false;
        this.$q.localStorage.set("ydb-globals-splitter", v);
      }
    },
    collapsed(v) {
      this.$q.localStorage.set("ydb-globals-collapsed", v);
    },
    codeLineBreak(v) {
      if (v) {
        this.$set(this.cmOptions, "lineWrapping", true);
      } else {
        this.$set(this.cmOptions, "lineWrapping", false);
      }
    },
    theme(v) {
      if (v) {
        this.$set(this.cmOptions, "theme", "abcdef");
      } else {
        this.$set(this.cmOptions, "theme", "default");
      }
    },
    selectedGlblNode: {
      async handler(v) {
        if (v) {
          let data = await this.getSelectedGlobalValue(v);
          this.$set(this.tabData[this.tab], "code", String(data.code));
          this.$set(this.tabData[this.tab], "codeIcon", data.icon);
          this.$set(this.tabData[this.tab], "globalRightDrawer", true);
        } else {
          this.$set(this.tabData[this.tab], "globalRightDrawer", false);
          this.$set(this.tabData[this.tab], "code", "");
          this.$set(this.tabData[this.tab], "codeIcon", "");
        }
      },
      deep: true
    },
    splitterModel(v) {
      this.$q.localStorage.set("ydb-globals-splitter", v);
    }
  },
  created() {
    this.collapsed = !!this.$q.localStorage.getItem("ydb-routines-collapsed");
    if (this.collapsed) {
      this.splitterModel = 0;
    } else {
      this.splitterModel =
        this.$q.localStorage.getItem("ydb-routines-splitter") || 15;
    }
  },
  async mounted() {
    await this.getGlobals();
    if (this.shownGlobalList[0]) {
      this.populateGlobal(this.shownGlobalList[0].g);
    }
  }
};
</script>
<style>
@import "../../../node_modules/codemirror/lib/codemirror.css";
@import "../../../node_modules/codemirror/theme/abcdef.css";
#codeMirrorGlobals > .CodeMirror {
  border: 1px solid #eee;
  height: calc(100vh - 430px);
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
