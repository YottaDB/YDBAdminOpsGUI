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
  <div class="q-pa-md" id="routinesDiv">
    <q-page-sticky position="top-right" :offset="[20, 3]">
      <q-btn
        id="rtn-btn-delete"
        icon="delete"
        @click="deleteRoutine"
        size="md"
        padding="0px"
        style="margin-right:15px;margin-top:10px"
        :color="!$q.dark.isActive ? 'purple' : 'orange'"
        flat
        ><q-tooltip>Delete Routine?</q-tooltip></q-btn
      >
      <q-btn
        id="rtn-btn-save"
        icon="save"
        @click="saveRoutine"
        size="md"
        padding="0px"
        style="margin-right:15px;margin-top:10px"
        :color="!$q.dark.isActive ? 'purple' : 'orange'"
        flat
        ><q-tooltip>Save Routine?</q-tooltip></q-btn
      >
      <q-btn
        id="rtn-btn-add"
        icon="add"
        @click="createRoutine"
        padding="0px"
        size="md"
        style=";margin-top:10px"
        :color="!$q.dark.isActive ? 'purple' : 'orange'"
        flat
        ><q-tooltip>Create Routine?</q-tooltip></q-btn
      >
      <!-- <q-btn fab icon="delete" padding="xs" :color="'red'" /> -->
    </q-page-sticky>
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
      <q-breadcrumbs gutter="xs" style="padding-left:10px;" id="breadcrumbs">
        <q-breadcrumbs-el label="Home" icon="home" :to="'/'" />
        <q-breadcrumbs-el
          label="Routines"
          icon="description"
          :to="'/routines'"
        />
        <q-breadcrumbs-el
          v-if="tabData && tabData[tab] && tabData[tab].path"
          :label="
            tabData[tab].path + tabData[tab].name
              ? tabData[tab].path + tabData[tab].name + '.m'
              : ''
          "
          :to="'/routines'"
        />
      </q-breadcrumbs>
    </div>
    <q-splitter
      v-model="splitterModel"
      style="height:calc(100vh - 121px)"
      v-if="!loading && !loadingDialog"
      :limits="[0, 50]"
    >
      <template v-slot:before>
        <span
          id="routines_header"
          :class="
            $q.dark.isActive
              ? 'text-orange text-center'
              : 'text-purple text-center'
          "
          style="font-size:28px;padding:25px"
        >
          Routines
        </span>
        <q-infinite-scroll
          @load="loadMoreRoutines"
          :offset="0"
          ref="infscroll"
          scroll-target="#routinesDiv"
          :initial-index="1"
        >
          <div class="q-pa-md">
            <q-input
              input-class="routine_search_input"
              filled
              bottom-slots
              v-model="searchRoutines"
              label="Search"
              :dense="true"
              @keydown.enter="getRoutines"
            >
              <template v-slot:append>
                <q-icon
                  v-if="searchRoutines !== ''"
                  name="close"
                  @click="searchRoutines = ''"
                  class="cursor-pointer"
                  id="routine_search_button"
                />
                <q-icon
                  name="search"
                  class="cursor-pointer"
                  @click="getRoutines"
                />
              </template>
            </q-input>
          </div>
          <div>
            <q-list>
              <q-item>
                <q-item-section>
                  <q-item-label
                    id="routine_count_section"
                    overline
                    :class="$q.dark.isActive ? 'text-orange' : 'text-purple'"
                    >{{ routineTotal }} Routines</q-item-label
                  >

                  <q-item-label>
                    <div class="q-gutter-sm">
                    
                      <q-checkbox
                        size="xs"
                        dense
                        v-model="showsys"
                        label=""
                      />
                        <q-btn :id="'showsyscheckbox'" dense size="xs" flat label="System routines" @click="showsys=!showsys" />
                      </div
                  ></q-item-label>
                </q-item-section>
              </q-item>
              <div
                id="routines_column"
                v-for="(rtn, index) in shownRoutineList"
                :key="'rlist-' + index"
              >
                <q-item
                  :ripple="false"
                  @click="populateRoutine(rtn)"
                  :active="getCurrentActiveRoutine(rtn.r)"
                  dense
                >
                  <q-item-section>
                    <q-item-label
                      ><q-btn
                        flat
                        class="full-width"
                        @click="populateRoutine(rtn)"
                        :id="'column-' + rtn.r"
                        >{{ rtn.r }}</q-btn
                      ></q-item-label
                    >
                  </q-item-section>
                  <!--
                  <q-item-section side>
                    <q-item-label caption>{{ rtn.p }}</q-item-label>
                  </q-item-section>
                -->
                </q-item>
                <q-separator inset />
              </div>
              <q-item
                clickable
                @click="loadMoreScrolledRoutines"
                v-if="!finishedLoadingAllRoutines"
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
        <codemirror
          :key="'code-panel' + tablekey"
          id="codeMirrorRoutines"
          v-if="tabData && tabData[tab]"
          ref="cmEditor"
          :value="tabData[tab].code"
          :options="cmOptions"
          @ready="onCmReady"
          @focus="onCmFocus"
          @input="onCmCodeChange"
        />
      </template>
    </q-splitter>
    <q-dialog v-model="loadingDialog" persistent>
      <q-card style="height:185px;width:300px">
        <q-card-section class="q-pa-md">
          <span
            style="font-size:18px;"
            class="flex flex-center"
            id="routines_loader_modal"
            >Loading Routines. Please wait!</span
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
    <q-dialog v-model="createRoutineDialog" persistent>
      <q-card style="width:300px" @keyup.enter="createNewRoutine">
        <q-card-section class="q-pa-md">
          <span style="font-size:18px;" class="flex flex-center"
            >Create New Routine</span
          >
        </q-card-section>
        <q-card-section>
          <q-input
            input-class="rtn-add-input"
            outlined
            v-model="newRoutineName"
            label="Routine Name*"
            dense
            ref="newRoutineField"
            lazy-rules
            :rules="[val => checkRoutineName(val) || 'Invalid routine name']"
          />
          <q-select
            lazy-rules
            ref="pathField"
            :rules="[val => val.length > 0 || 'Routine location is required!']"
            dense
            filled
            v-model="newRoutinePath"
            :value="newRoutinePath[0]"
            :options="newRoutinePaths"
            label="Routine Location*"
          />
        </q-card-section>
        <q-card-actions align="right" class="text-primary">
          <q-btn
            flat
            label="Cancel"
            color="warning"
            @click="cancelCreateNewRoutine"
          />
          <q-btn flat label="OK" @click="createNewRoutine" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>
<script>
import { uid } from "quasar";
import { codemirror } from "vue-codemirror";
import "codemirror/mode/mumps/mumps.js";

export default {
  name: "Routines",
  components: {
    codemirror
  },
  data() {
    return {
      tablekey: uid(),
      tabData: {},
      tab: "",
      tabs: [],
      collapsed: false,
      newRoutinePath: "",
      newRoutinePaths: [],
      newRoutineName: "",
      createRoutineDialog: false,
      splitterModel: 10,
      searchRoutines: "*",
      shownRoutineList: [],
      shownRoutineIndex: 0,
      showsys: false,
      routinePatchCount: 100,
      finishedLoadingAllRoutines: false,
      cmOptions: {
        autofocus: true,
        tabSize: 4,
        mode: {
          name: "mumps"
        },
        theme: this.$q.dark.isActive ? "abcdef" : "default",
        lineNumbers: true,
        line: true,
        extraKeys: {
          "Ctrl-S": async instance => {
            await this.saveRoutine();
          }
        }
      },
      routinesList: [],
      routinesPaths: [],
      loading: false,
      loadingDialog: false,
      routineTotal: 0
    };
  },
  methods: {
    generateNewTableKey() {
      this.tablekey = uid();
    },
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
    collapseLeftSide() {
      this.collapsed = !this.collapsed;
      if (this.collapsed) {
        this.splitterModel = 0;
      } else {
        this.splitterModel = this.$q.localStorage.getItem(
          "ydb-routines-splitter"
        );
        if (this.splitterModel === 0) {
          this.splitterModel = 15;
        }
      }
      this.generateNewTableKey();
    },
    checkRoutineName(value) {
      let valid = true;
      if (!value) {
        return false;
      }
      let dict = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".split(
        ""
      );
      let digits = "0123456789".split("");
      let fulldict = dict.concat(digits);
      let valueArr = value.split("");
      for (let i = 0; i < valueArr.length; i++) {
        if (i === 0 && !dict.includes(valueArr[i]) && valueArr[i] !== "%") {
          valid = false;
        } else if (i > 0 && !fulldict.includes(valueArr[i])) {
          valid = false;
        }
      }
      return valid;
    },
    getCurrentActiveRoutine(rtn) {
      return this.tab === rtn;
    },
    loadMoreRoutines(index, done) {
      this.shownRoutineIndex = index;
      for (
        let i = this.shownRoutineIndex * this.routinePatchCount;
        i <
        this.shownRoutineIndex * this.routinePatchCount +
          this.routinePatchCount;
        i++
      ) {
        if (this.routinesList[i]) {
          this.shownRoutineList.push(this.routinesList[i]);
        } else {
          this.finishedLoadingAllRoutines = true;
          done(true);
          return;
        }
      }
      done();
      this.$refs.infscroll.stop();
    },
    async populateRoutine(rtn) {
      let tab = {
        name: rtn.r,
        label: rtn.r,
        path: rtn.p
      };
      let found = false;
      this.tabs.map(t => {
        if (
          t.name === tab.name &&
          t.label === tab.label &&
          t.path === tab.path
        ) {
          found = true;
        }
      });
      if (!found) {
        this.tabs.push(tab);
      }
      this.tab = tab.name;
      this.$set(this.tabData, this.tab, {});
      this.$set(
        this.tabData[this.tab],
        "code",
        (this.tabData[this.tab] && this.tabData[this.tab].code) || ""
      );
      this.$set(this.tabData[this.tab], "name", rtn.r);
      this.$set(this.tabData[this.tab], "path", rtn.p);
      let data = await this.$M("POPULATEROUTINE^%YDBWEBRTNS", {
        RTN: rtn.r,
        PATH: rtn.p
      });
      if (data && data.STATUS && data.CODE && data.CODE.length > 0) {
        this.$set(this.tabData[this.tab], "code", data.CODE.join("\n"));
        this.$set(this.tabData[this.tab], "name", rtn.r);
        this.$set(this.tabData[this.tab], "path", rtn.p);
      } else {
        this.$q.notify({
          message: "Routine could not be found!",
          color: "negative"
        });
      }
    },
    async getRoutines() {
      if (!this.searchRoutines.length) {
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
      this.shownRoutineList = [];
      this.shownRoutineIndex = 0;
      this.finishedLoadingAllRoutines = false;
      let data = await this.$M("GETROUTINESLIST^%YDBWEBRTNS", {
        PATTERN: this.searchRoutines,
        SYS: this.showsys
      });
      if (data && data.RTOTAL) {
        this.routineTotal = data.RTOTAL;
      } else {
        this.routineTotal = 0;
      }
      if (data && data.RLIST) {
        this.routinesList = data.RLIST;
      } else {
        this.routinesList = [];
      }
      if (data && data.PLIST) {
        this.routinesPaths = data.PLIST;
      } else {
        this.routinesPaths = [];
      }
      for (
        let i = this.shownRoutineIndex * this.routinePatchCount;
        i <
        this.shownRoutineIndex * this.routinePatchCount +
          this.routinePatchCount;
        i++
      ) {
        if (this.routinesList[i]) {
          this.shownRoutineList.push(this.routinesList[i]);
        } else {
          this.finishedLoadingAllRoutines = true;
        }
      }
      done = true;
      this.loading = false;
      this.loadingDialog = false;
    },
    onCmReady(cm) {},
    onCmFocus(cm) {},
    onCmCodeChange(newCode) {
      this.tabData[this.tab]["code"] = newCode;
    },
    loadMoreScrolledRoutines() {
      this.$refs.infscroll.resume();
      this.$refs.infscroll.trigger();
    },
    async saveRoutine() {
      let data = await this.$M("SAVEROUTINE^%YDBWEBRTNS", {
        ROUTINE: this.tabData[this.tab].name,
        PATH: this.tabData[this.tab].path,
        DATA: this.tabData[this.tab].code.split("\n")
      });
      if (
        data.STATUS &&
        data.CODE &&
        data.CODE.join("\n") === this.tabData[this.tab].code
      ) {
        this.$q.notify({
          message: "Routine saved!",
          color: "positive"
        });
      } else {
        this.$q.notify({
          message: "Routine could not be saved!",
          color: "negative"
        });
      }
    },
    async deleteRoutine() {
      this.$q
        .dialog({
          title: "Delete Routine",
          message:
            "Are you sure you want to delete " +
            this.tabData[this.tab].path +
            this.tabData[this.tab].name,
          cancel: true,
          persistent: true
        })
        .onOk(async () => {
          let data = await this.$M("DELETEROUTINE^%YDBWEBRTNS", {
            ROUTINE: this.tabData[this.tab].name,
            PATH: this.tabData[this.tab].path
          });
          if (data.STATUS) {
            this.$q.notify({
              message: "Routine deleted!",
              color: "positive"
            });
            await this.getRoutines();
            if (this.shownRoutineList[0]) {
              this.populateRoutine(this.shownRoutineList[0]);
            }
          } else {
            this.$q.notify({
              message: "Routine could not be deleted!",
              color: "negative"
            });
          }
        });
    },
    async createRoutine() {
      let data = await this.$M("GETROUTINEPATHS^%YDBWEBRTNS");
      if (data && data.STATUS) {
        this.newRoutinePaths = data.PATHS;
        this.createRoutineDialog = true;
        this.newRoutinePath = data.PATHS[0];
      } else {
        this.$q.notify({
          message: "Could not get routine paths!",
          color: "negative"
        });
      }
    },
    async createNewRoutine() {
      this.$refs.newRoutineField.validate();
      this.$refs.pathField.validate();

      if (
        this.$refs.newRoutineField.hasError ||
        this.$refs.pathField.hasError
      ) {
        this.$q.notify({
          message: "Please enter a valid routine name and location",
          color: "negative"
        });
        return;
      } else {
        let data = await this.$M("CREATENEWROUTINE^%YDBWEBRTNS", {
          ROUTINE: this.newRoutineName,
          PATH: this.newRoutinePath
        });
        if (data && data.STATUS) {
          this.$q.notify({
            color: "positive",
            message: "Routine: " + this.newRoutineName + " created successfully"
          });
          await this.getRoutines();
          if (this.shownRoutineList[0]) {
            this.populateRoutine(this.shownRoutineList[0]);
          }
          this.createRoutineDialog = false;
          this.newRoutineName = "";
        } else {
          this.$q.notify({
            message: "Routine could not be created. It might already exists",
            color: "negative"
          });
        }
      }
    },
    cancelCreateNewRoutine() {
      this.createRoutineDialog = false;
      this.newRoutineName = "";
    }
  },
  computed: {
    codemirror() {
      // console.log("the current CodeMirror instance object:", this.codemirror);
      return this.$refs.cmEditor.codemirror;
    },
    theme() {
      return this.$q.dark.isActive;
    }
  },
  watch: {
    async showsys(v) {
        await this.getRoutines();
        if (this.shownRoutineList[0]) {
          this.populateRoutine(this.shownRoutineList[0]);
        }
    },
    splitterModel(v) {
      if (v === 0) {
        this.collapsed = true;
      } else {
        this.collapsed = false;
        this.$q.localStorage.set("ydb-routines-splitter", v);
      }
    },
    collapsed(v) {
      this.$q.localStorage.set("ydb-routines-collapsed", v);
    },
    theme(v) {
      if (v) {
        this.$set(this.cmOptions, "theme", "abcdef");
      } else {
        this.$set(this.cmOptions, "theme", "default");
      }
    },
    tab(v) {
      this.generateNewTableKey();
    }
  },
  async mounted() {
    this.collapsed = !!this.$q.localStorage.getItem("ydb-routines-collapsed");
    if (this.collapsed) {
      this.splitterModel = 0;
    } else {
      this.splitterModel =
        this.$q.localStorage.getItem("ydb-routines-splitter") || 15;
    }
    await this.getRoutines();
    if (this.shownRoutineList[0]) {
      this.populateRoutine(this.shownRoutineList[0]);
    }
  }
};
</script>
<style>
@import "../../../node_modules/codemirror/lib/codemirror.css";
@import "../../../node_modules/codemirror/theme/abcdef.css";
#codeMirrorRoutines > .CodeMirror {
  border: 1px solid #eee;
  height: calc(100vh - 165px);
}
</style>
