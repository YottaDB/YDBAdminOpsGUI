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
  <q-page>
    <div class="row flex flex-center q-pa-md" :style="'padding-top:50px'">
      <img
        v-if="!$q.dark.isActive"
        alt="Quasar logo"
        src="~assets/YottaDB_logo-light.svg"
        style="max-width:35vw"
      />
      <img
        v-if="$q.dark.isActive"
        alt="Quasar logo"
        src="~assets/YottaDB_logo-dark.svg"
        style="max-width:35vw"
      />
    </div>
    <div
      class="row items-start q-gutter-md flex flex-center"
      style="padding-top:50px;"
    >
      <q-card style="width:300px" id="mn-navigation-panels">
        <q-img src="~assets/uc-1.png" />
        <q-card-actions>
          <span style="font-size:18px;font-weight:700;">{{$t('toolbar.system_management')}}</span>
          <q-space />

          <q-btn
            id="mn-system-management-expand-btn"
            color="grey"
            round
            flat
            dense
            :icon="
              expandedSystemManagement
                ? 'keyboard_arrow_up'
                : 'keyboard_arrow_down'
            "
            @click="expandedSystemManagement = !expandedSystemManagement"
          />
        </q-card-actions>

        <q-slide-transition>
          <div v-show="expandedSystemManagement" id="mn-system-management-expand-panel">
             <q-item dense>
             <q-btn flat size="xs" dense :to="'/processes'" class="full-width" id="mn-system-management-app-runningprocess">
              <span style="font-size:12px">
                {{$t('toolbar.running_processes')}}
              </span>
             </q-btn>
            </q-item>
            <q-item dense>
              <q-btn flat size="xs" dense :to="'/gde'" class="full-width" id="mn-system-management-app-gde">
              <span style="font-size:12px">
                {{$t('toolbar.global_directory_editor')}}
              </span>
              </q-btn>
            </q-item>
          </div>
        </q-slide-transition>
      </q-card>

      <q-card style="width:300px">
        <q-img src="~assets/uc-2.png" />
        <q-card-actions>
          <span style="font-size:18px;font-weight:700;">{{$t('toolbar.system_explorer')}}</span>
          <q-space />

          <q-btn
           id="mn-system-explorer-expand-btn"
            color="grey"
            round
            flat
            dense
            :icon="
              expandedSystemExplorer
                ? 'keyboard_arrow_up'
                : 'keyboard_arrow_down'
            "
            @click="expandedSystemExplorer = !expandedSystemExplorer"
          />
        </q-card-actions>

        <q-slide-transition>
          <div v-show="expandedSystemExplorer" id="mn-system-explorer-expand-panel">
            <q-item dense>
             <q-btn flat size="xs" dense :to="'/routines'" class="full-width" id="mn-system-explorer-app-routines">
              <span style="font-size:12px">
                {{$t('toolbar.routines')}}
              </span>
             </q-btn>
            </q-item>
            <q-item dense>
             <q-btn flat size="xs" dense :to="'/globals'" class="full-width" id="mn-system-explorer-app-globals">
              <span style="font-size:12px">
                {{$t('toolbar.globals')}}
              </span>
             </q-btn>
            </q-item>
            <q-item>
            <q-btn flat size="xs" dense :to="'/octo-sql'" class="full-width" id="mn-system-explorer-app-octo">
              <span style="font-size:12px">
                {{$t('toolbar.sqltables')}}
              </span>
            </q-btn>
            </q-item>
          </div>
        </q-slide-transition>
      </q-card>
      <q-card style="width:300px">
        <q-img src="~assets/uc-4.png" />
        <q-card-actions>
          <span style="font-size:18px;font-weight:700;">{{$t('toolbar.utilities')}}</span>
          <q-space />

          <q-btn
            color="grey"
            round
            flat
            dense
            :icon="
              expandedUtilities
                ? 'keyboard_arrow_up'
                : 'keyboard_arrow_down'
            "
            @click="expandedUtilities = !expandedUtilities"
          />
        </q-card-actions>

        <q-slide-transition>
          <div v-show="expandedUtilities">
          </div>
        </q-slide-transition>
      </q-card>
            <q-card style="width:300px">
        <q-img src="~assets/uc-6.png" />
        <q-card-actions>
          <span style="font-size:18px;font-weight:700;"> {{$t('toolbar.documentation')}}</span>
          <q-space />
          <q-btn
            color="grey"
            round
            flat
            dense
            :icon="
              expandedDocumentation
                ? 'keyboard_arrow_up'
                : 'keyboard_arrow_down'
            "
            @click="expandedDocumentation = !expandedDocumentation"
          />
        </q-card-actions>

        <q-slide-transition>
          <div v-show="expandedDocumentation">
             <q-item clickable :to="'/documentation/administration_and_operations'" dense>
              <span style="font-size:16px">
                Administration and Operations
              </span>
            </q-item>
                      <q-item clickable :to="'/documentation/multi-language_programmers_guide'" dense>
              <span style="font-size:16px">
                Multi-Language Programmers Guide
              </span>
            </q-item>
                      <q-item clickable :to="'/documentation/m_programmers_guide'" dense>
              <span style="font-size:16px">
                M Programmers Guide
              </span>
            </q-item>
                      <q-item clickable :to="'/documentation/messages_and_recovery_procedures'" dense>
              <span style="font-size:16px">
                Messages and Recovery Procedures
              </span>
            </q-item>
                      <q-item clickable :to="'/documentation/acculturation_guide'" dense>
              <span style="font-size:16px">
                Acculturation Guide
              </span>
            </q-item>
                      <q-item clickable :to="'/documentation/octo_documentation'" dense>
              <span style="font-size:16px">
                Octo Documentation
              </span>
            </q-item>
                      <q-item clickable :to="'/documentation/plugins'" dense>
              <span style="font-size:16px">
                Plugins
              </span>
            </q-item>
          </div>
        </q-slide-transition>
      </q-card>
    </div>
  </q-page>
</template>

<script>
export default {
  name: "PageIndex",
  data() {
    return {
      expandedSystemManagement: false,
      expandedSystemExplorer: false,
      expandedUtilities: false,
      expandedDocumentation: false
    };
  }
};
</script>
