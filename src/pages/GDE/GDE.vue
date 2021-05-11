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
  <div class="q-pa-md" :key="pageKey" id="gdediv">
    <div style="padding:5px">
      <q-breadcrumbs gutter="xs">
      <q-breadcrumbs-el  label="Home" />
      <q-breadcrumbs-el   label="System Administration" />
      <q-breadcrumbs-el   label="Global Directory Editor (GDE)" />
    </q-breadcrumbs>
      <span :class="$q.dark.isActive?'text-orange':'text-purple'" style="font-size:28px;padding:25px"
        >Global Directory Editor (GDE)</span
      >
      
      <q-btn round style="margin-right:10px" size="sm" icon="add"  :color="$q.dark.isActive ? 'purple' : 'orange'"  @click="addDialog = true">
        <q-tooltip>
        Add Segment,Region and Name
        </q-tooltip>
      </q-btn>   
      <q-btn round style="margin-right:10px" size="sm" icon="text_snippet"  :color="'primary'"  @click="createDialog = true">
        <q-tooltip>
        Create Database File
        </q-tooltip>
      </q-btn>  
      <q-btn round style="margin-right:10px" size="sm" icon="delete"  :color="'negative'"  @click="delDialog = true">
        <q-tooltip>
        Delete Segment,Region and Name
        </q-tooltip>
      </q-btn>   
      <!--
          <q-fab
              icon="add"
              direction="right"
              color="orange"
            >
              <q-fab-action @click="addNameDialog = true" color="primary" icon="add">
                Name
                <q-tooltip content-style="font-size: 20px">
                   Add Name
                </q-tooltip>
              </q-fab-action>
              <q-fab-action @click="addRegionDialog = true" color="positive" icon="add" >
                Region
               <q-tooltip content-style="font-size: 20px">
                   Add Region
                </q-tooltip>
              </q-fab-action>
              <q-fab-action @click="addSegmentDialog = true" color="accent" icon="add" >
                Segment
               <q-tooltip content-style="font-size: 20px">
                   Add Segment
                </q-tooltip>
              </q-fab-action>
            </q-fab>
            -->
      <q-banner inline-actions class="text-white bg-red" v-if="!saved && verified && !errors">
        Changes not saved!
        <template v-slot:action>
          <q-btn
            flat
            color="white"
            icon="save"
            label="Save Changes"
            @click="savedata"
          />
        </template>
      </q-banner>
    </div>
    <!-- ********************************** NAMES-START ********************************************* -->
    <div style="padding:25px">
    <q-table
      title="Names"
      :data="items"
      :columns="fields"
      row-key="name"
      bordered
      dense
      virtual-scroll
      :pagination.sync="pagination"
      :rows-per-page-options="[0]"
      :loading="loading"
      tabindex="0"
      selection="single"
      :selected.sync="selectedName"
      :hide-selected-banner="true"
    >
      <template v-slot:top>
        <div :class="$q.dark.isActive?'bg-orange text-white row':'bg-purple text-white row'" style="width:100%">
        <div style="padding:10px">
          <span  style="font-size:21px;">Names</span>
        </div>
        <q-btn round icon="info" size="md" dense flat />
        <q-space />
        <div v-if="selectedName.length > 0">
          <q-btn
            icon="edit"
            label="EDIT"
            @click="
              info(selectedName[0]);
              editNameDialog = true;
            "
            flat
          />
          <!--
          <q-btn
            icon="delete"
            label="DELETE"
            color="negative"
            flat
             @click="remove(selectedName[0],'name')"
            v-if="show(selectedName[0])"
          />
          -->
        </div>
        </div>
      </template>
      <template v-slot:body-cell-region="props">
        <q-td :props="props">
          <div>
            <q-badge
              style="max-width:150px"
              color="orange"
              :label="props.value"
            />
          </div>
        </q-td>
      </template>
      <template v-slot:body-cell-segment="props">
        <q-td :props="props">
          <div>
            <q-badge style="max-width:150px" color="purple" :label="props.value" />
          </div>
        </q-td>
      </template>
    </q-table>
    <q-dialog v-model="editNameDialog" persistent v-if="selectedName.length > 0">
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Edit {{selectedName[0].name}} Name</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            outlined
            disable
            label="Name"
            v-model="selectedItem.name.NAME"
            :value="selectedItem.name.NAME"
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-select
            outlined
            id="region"
            :options="Object.keys(regions)"
            label="Region"
            v-model="selectedItem.name.REGION"
            :value="selectedItem.name.REGION"
            :dense="true"
            option-label="text"
            map-options
            emit-value
          />
        </q-card-section>

        <q-card-actions align="right" class="text-primary">
          <q-btn flat label="Cancel" color="warning" @click="cancel()" />
          <q-btn flat label="OK" @click="ok('name')" />
        </q-card-actions>
      </q-card>
    </q-dialog>
    </div>
  <!-- ********************************** NAMES-END ********************************************* -->
  <!-- ********************************** REGIONS-START ***************************************** -->
 <div style="padding:25px">
 <q-table
      title="Regions"
      :data="regionItems"
      :columns="regionFields"
      row-key="name"
      bordered
      dense
      virtual-scroll
      :pagination.sync="pagination"
      :rows-per-page-options="[0]"
      :loading="loading"
      tabindex="0"
      selection="single"
      :selected.sync="selectedRegion"
      :hide-selected-banner="true"
    >
      <template v-slot:top>
        <div :class="$q.dark.isActive?'bg-orange text-white row':'bg-purple text-white row'" style="width:100%">
        <div style="padding:10px">
          <span class="text-center" style="font-size:21px;">Regions</span>
        </div>
        <q-btn round icon="info" size="md" dense flat />
        <q-space />
        <div v-if="selectedRegion.length > 0">
                   <q-btn
            icon="preview"
            label="DETAILS"
            @click="
              showDetailsRegionDialog = true;
            "
            flat
          />
          <q-btn
            icon="edit"
            label="EDIT"
            @click="
              info(selectedRegion[0]);
              editRegionDialog = true;
            "
            flat
          />
          <!--
          <q-btn
            icon="delete"
            label="DELETE"
            color="negative"
            flat
             @click="remove(selectedRegion[0],'region')"
            v-if="show(selectedRegion[0])"
          />
          -->
        </div>
        </div>
      </template>
      <template v-slot:body-cell-name="props">
        <q-td :props="props">
          <div>
            <q-badge style="max-width:100px" color="orange" :label="props.value" />
          </div>
        </q-td>
      </template>
      <template v-slot:body-cell-segment="props">
        <q-td :props="props">
          <div>
            <q-badge style="max-width:100px" color="purple" :label="props.value" />
          </div>
        </q-td>
      </template>
    </q-table>
 </div>
     <q-dialog v-model="editRegionDialog" persistent v-if="selectedRegion.length>0">
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Edit {{selectedRegion[0].name}} Region</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Region"
               id="region"
                v-model="selectedItem.region.NAME"
                :value="selectedItem.region.NAME"
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-select
            outlined
            id="segment"
            :options="Object.keys(segments)"
            label="Segment"
            v-model="selectedItem.region.DYNAMIC_SEGMENT"
            :value="selectedItem.region.DYNAMIC_SEGMENT"
            :dense="true"
            option-label="text"
            map-options
            emit-value
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
           <q-checkbox right-label label="AutoDB" v-model="selectedItem.region.AUTODB" />
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Collation Default"
                v-model="selectedItem.region.COLLATION_DEFAULT"
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
           <q-checkbox right-label label="Epoch Taper" v-model="selectedItem.region.EPOCHTAPER" />
           <q-checkbox right-label label="Instance Freeze on Error"  v-model="selectedItem.region.INST_FREEZE_ON_ERROR" />
           <q-checkbox right-label label="Enable Journal" v-model="selectedItem.region.JOURNAL" />
        </q-card-section>
       <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Auto Switch Limit"
                 v-model="selectedItem.region.AUTOSWITCHLIMIT"
            :dense="true"
          />
        </q-card-section>
               <q-card-section class="q-pt-none">
           <q-checkbox right-label label="Before Image" v-model="selectedItem.region.BEFORE_IMAGE" />
        </q-card-section>
            <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Journal File Name"
            v-model="selectedItem.region.FILE_NAME"
            :dense="true"
          />
        </q-card-section>
                   <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Key Size (bytes)"
            v-model="selectedItem.region.KEY_SIZE"
            :dense="true"
          />
        </q-card-section>
         <q-card-section class="q-pt-none">
           <q-checkbox right-label label="Lock Crit Separate" v-model="selectedItem.region.LOCK_CRIT_SEPARATE" />
           <q-checkbox right-label label="Quick Database Rundown"  v-model="selectedItem.region.QDBRUNDOWN" />
        </q-card-section>
        <q-card-section class="q-pt-none">
           <q-checkbox right-label label="Region Stats" v-model="selectedItem.region.STATS" />
           <q-checkbox right-label label="Standard Null Collation" v-model="selectedItem.region.STDNULLCOLL" />
        </q-card-section>
              <q-card-section class="q-pt-none">
          <q-select
            outlined
            :options="regionNullSubscriptsOptions"
            label="Null Subscripts"
            v-model="selectedItem.region.NULL_SUBSCRIPTS"
            :value="selectedItem.region.NULL_SUBSCRIPTS"
            option-label="text"
            map-options
            emit-value
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Record Size (bytes)"
            v-model="selectedItem.region.RECORD_SIZE"
            :dense="true"
          />
        </q-card-section>
        <q-card-actions align="right" class="text-primary">
          <q-btn flat label="Cancel" color="warning" @click="cancel()" />
          <q-btn flat label="OK" @click="ok('region')" />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <q-dialog v-model="showDetailsRegionDialog" persistent v-if="selectedRegion.length>0">
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Region {{selectedRegion[0].name}} Details</div>
        </q-card-section>
        <q-card-section>
          <div class="q-pa-md">
    <q-markup-table>
      <tbody>
        <tr>
          <td class="text-left"><b>Journal Extension Count</b></td>
          <td class="text-right">{{selectedRegion[0].extensionCount}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Journal Auto Switch Limit</b></td>
          <td class="text-right">{{selectedRegion[0].autoSwitchLimit}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Default Collation</b></td>
          <td class="text-right">{{selectedRegion[0].defaultCollation}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Stats</b></td>
          <td class="text-right">{{selectedRegion[0].stats}}</td>
        </tr>
     <tr>
          <td class="text-left"><b>AutoDB</b></td>
          <td class="text-right">{{selectedRegion[0].autodb}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Lock Crit</b></td>
          <td class="text-right">{{selectedRegion[0].lockCrit}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Null Subscripts</b></td>
          <td class="text-right">{{selectedRegion[0].nullSubscripts}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Standard Null Collation</b></td>
          <td class="text-right">{{selectedRegion[0].standardNullCollation}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Instance Freeze On Error</b></td>
          <td class="text-right">{{selectedRegion[0].instFreezeOnError}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Qdb Rundown</b></td>
          <td class="text-right">{{selectedRegion[0].qDbRundown}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Epoch Taper</b></td>
          <td class="text-right">{{selectedRegion[0].epochTaper}}</td>
        </tr>
      </tbody>
    </q-markup-table>
  </div>
        </q-card-section>
        <q-card-actions align="right" class="text-primary">
          <q-btn flat label="OK" @click="showDetailsRegionDialog = false" />
        </q-card-actions>
      </q-card>
    </q-dialog>
 <!-- ********************************** REGIONS-END ***************************************** -->
 <!-- ********************************** SEGMENTS-START ************************************** -->

<div style="padding:25px">
 <q-table
      title="Segments"
      :data="segmentItems"
      :columns="segmentFields"
      row-key="name"
      bordered
      dense
      virtual-scroll
      :pagination.sync="pagination"
      :rows-per-page-options="[0]"
      :loading="loading"
      tabindex="0"
      selection="single"
      :selected.sync="selectedSegment"
      :hide-selected-banner="true"
    >
      <template v-slot:top>
        <div :class="$q.dark.isActive?'bg-orange text-white row':'bg-purple text-white row'" style="width:100%">
        <div style="padding:10px">
          <span class="text-center" style="font-size:21px;">Segments</span>
        </div>
        <q-btn round icon="info" size="md" dense flat />
        <q-space />
        <div v-if="selectedSegment.length > 0">
                   <q-btn
            icon="preview"
            label="DETAILS"
            @click="
              showDetailsSegmentDialog = true;
            "
            flat
          />
          <q-btn
            icon="edit"
            label="EDIT"
            @click="
              info(selectedSegment[0]);
              editSegmentDialog = true;
            "
            flat
          />
          <!--
          <q-btn
            icon="delete"
            label="DELETE"
            color="negative"
            flat
             @click="remove(selectedSegment[0],'segment')"
            v-if="show(selectedSegment[0])"
          />
          -->
        </div>
        </div>
      </template>
      <template v-slot:body-cell-name="props">
        <q-td :props="props">
          <div>
            <q-badge style="max-width:100px" color="purple" :label="props.value" />
          </div>
        </q-td>
      </template>
    </q-table>
 </div>
      <q-dialog v-model="editSegmentDialog" persistent v-if="selectedSegment.length>0">
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Edit {{selectedSegment[0].name}} Segment</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Segment"
            v-model="selectedItem.segment.NAME"
            :value="selectedItem.segment.NAME"
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="File"
            v-model="selectedItem.segment.FILE_NAME"
            :value="selectedItem.segment.FILE_NAME"
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-select
            outlined
            :options="accessMethods"
            label="Access Method"
            v-model="selectedItem.segment.ACCESS_METHOD"
            :value="selectedItem.segment.ACCESS_METHOD"
            :dense="true"
            option-label="text"
            map-options
            emit-value
          />
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Allocation (blocks)"
            v-model="selectedItem.segment.ALLOCATION"
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
           <q-checkbox right-label label="Async IO" v-model="selectedItem.segment.ASYNCIO" />
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Block Size (bytes & multiple of 512)"
            v-model="selectedItem.segment.BLOCK_SIZE"
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
           <q-checkbox right-label label="Defer Allocate" v-model="selectedItem.segment.DEFER_ALLOCATE" />
           <q-checkbox right-label label="Encryption"  v-model="selectedItem.segment.ENCRYPTION_FLAG" />
        </q-card-section>
       <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Extension Count"
            v-model="selectedItem.segment.EXTENSION_COUNT"
            :dense="true"
          />
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Global Buffer Count (blocks)"
             v-model="selectedItem.segment.GLOBAL_BUFFER_COUNT"
            :dense="true"
          />
        </q-card-section>
             <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Lock Space (pages)"
            v-model="selectedItem.segment.LOCK_SPACE"
            :dense="true"
          />
        </q-card-section>
             <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Mutex Slots"
            v-model="selectedItem.segment.MUTEX_SLOTS"
            :dense="true"
          />
        </q-card-section>
             <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Reserved Bytes"
            v-model="selectedItem.segment.RESERVED_BYTES"
            :dense="true"
          />
        </q-card-section>
        <q-card-actions align="right" class="text-primary">
          <q-btn flat label="Cancel" color="warning" @click="cancel()" />
          <q-btn flat label="OK" @click="ok('segment')" />
          
        </q-card-actions>
      </q-card>
    </q-dialog>
     <q-dialog v-model="showDetailsSegmentDialog" persistent v-if="selectedSegment.length>0">
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Segment {{selectedSegment[0].name}} Details</div>
        </q-card-section>
        <q-card-section>
          <div class="q-pa-md">
    <q-markup-table>
      <tbody>
        <tr>
          <td class="text-left"><b>Reserved Bytes</b></td>
          <td class="text-right">{{selectedSegment[0].reservedBytes}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Encryption</b></td>
          <td class="text-right">{{selectedSegment[0].encryption}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Mutex Slots</b></td>
          <td class="text-right">{{selectedSegment[0].mutexSlots}}</td>
        </tr>
        <tr>
          <td class="text-left"><b>Defer Allocation</b></td>
          <td class="text-right">{{selectedSegment[0].deferAllocate}}</td>
        </tr>
     <tr>
          <td class="text-left"><b>Async IO</b></td>
          <td class="text-right">{{selectedSegment[0].asyncIO}}</td>
        </tr>
      </tbody>
    </q-markup-table>
  </div>
        </q-card-section>
        <q-card-actions align="right" class="text-primary">
          <q-btn flat label="OK" @click="showDetailsSegmentDialog = false" />
        </q-card-actions>
      </q-card>
    </q-dialog>

 <!-- ********************************** SEGMENTS-END **************************************** -->
 <!-- ********************************** MAP-START ******************************************* -->
<div style="padding:25px">
<q-table
      title="Global Mapping"
      :data="map"
      :columns="mapFields"
      row-key="name"
      bordered
      dense
      virtual-scroll
      :pagination.sync="pagination"
      :rows-per-page-options="[0]"
      :loading="loading"
      tabindex="0"
      :hide-selected-banner="true"
    >
      <template v-slot:top>
        <div :class="$q.dark.isActive?'bg-orange text-white row':'bg-purple text-white row'" style="width:100%">
        <div style="padding:10px">
          <span class="text-center" style="font-size:21px;">Global Mapping</span>
        </div>
        <q-btn round icon="info" size="md" dense flat />
        <q-space />
        </div>
      </template>
      <template v-slot:body-cell-segment="props">
        <q-td :props="props">
          <div>
            <q-badge style="max-width:100px" color="purple" :label="props.value" />
          </div>
        </q-td>
      </template>
      <template v-slot:body-cell-region="props">
        <q-td :props="props">
          <div>
            <q-badge style="max-width:100px" color="orange" :label="props.value" />
          </div>
        </q-td>
      </template>
    </q-table>
</div>
 <!-- ********************************** MAP-END ********************************************* -->
 <!-- ********************************** ADD NEW START**************************************** -->
 <q-dialog v-model="addDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Add Segment, Region and Name</div>
        </q-card-section>
          <q-card-section class="q-pt-none">
          <q-input
            outlined
            label="Name"
            ref="addSegmentField"
            v-model="addSegment"
            :rules="[val => !!val || 'Field is required']"
            :dense="true"
          />
        </q-card-section>
        <q-card-section class="q-pt-none">
          <q-input
            ref="addFileField"
            outlined
            label="File"
            :rules="[val => !!val || 'Field is required']"
            v-model="addFile"
            :dense="true"
          />
        </q-card-section>
         <q-card-actions align="right" class="text-primary">
           <q-btn flat label="Cancel" color="warning" @click="addDialog=false" />
          <q-btn  flat label="OK" @click="addNewSegmentAndFile"/> 
        </q-card-actions>
      </q-card>
 </q-dialog>
 <q-dialog v-model="addStatusDialog">
      <q-card>
        <q-bar :class="!$q.dark.isActive ? 'bg-purple' : 'bg-orange'">
          <span class="text-white">Status</span>
          <q-space />
        </q-bar>

        <q-card-section >
           <pre v-html="addStatusMessage"></pre>
        </q-card-section>

          <q-card-actions align="right" class="text-primary">
            
          <q-btn flat label="OK" @click="addStatusDialog=false;addDialog=false"/> 
        </q-card-actions>
      </q-card>
 </q-dialog>

 <!-- ********************************** ADD NEW END ***************************************** -->
  <!-- ********************************** DELETE START**************************************** -->
 <q-dialog v-model="delDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Delete Segment, Region and Name</div>
        </q-card-section>
          <q-card-section class="q-pt-none">
          <q-select
            outlined
            label="Name"
            ref="delSegmentField"
            :options="Object.keys(regions)"
            v-model="delSegment"
            :dense="true"
            option-label="text"
            map-options
            :rules="[val => !!val || 'Field is required']"
            emit-value
          />
        </q-card-section>
         <q-card-actions align="right" class="text-primary">
           <q-btn flat label="Cancel" color="warning" @click="delDialog=false" />
          <q-btn  flat label="OK" @click="delSegmentAndName"/> 
        </q-card-actions>
      </q-card>
 </q-dialog>
 <q-dialog v-model="delStatusDialog">
      <q-card>
        <q-bar :class="!$q.dark.isActive ? 'bg-purple' : 'bg-orange'">
          <span class="text-white">Status</span>
          <q-space />
        </q-bar>

        <q-card-section >
           <pre v-html="delStatusMessage"></pre>
        </q-card-section>

          <q-card-actions align="right" class="text-primary">
            
          <q-btn flat label="OK" @click="delStatusDialog=false;delDialog=false"/> 
        </q-card-actions>
      </q-card>
 </q-dialog>

 <!-- ********************************** DELETE END ***************************************** -->
  <!-- ********************************** CREATE START**************************************** -->
 <q-dialog v-model="createDialog" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Create dataase file for a region</div>
        </q-card-section>
          <q-card-section class="q-pt-none">
          <q-select
            outlined
            label="Name"
            ref="createSegmentField"
            :options="Object.keys(regions)"
            v-model="createSegment"
            :dense="true"
            option-label="text"
            map-options
            :rules="[val => !!val || 'Field is required']"
            emit-value
          />
        </q-card-section>
         <q-card-actions align="right" class="text-primary">
           <q-btn flat label="Cancel" color="warning" @click="createDialog=false" />
          <q-btn  flat label="OK" @click="createRegion"/> 
        </q-card-actions>
      </q-card>
 </q-dialog>
 <q-dialog v-model="createStatusDialog">
      <q-card>
        <q-bar :class="!$q.dark.isActive ? 'bg-purple' : 'bg-orange'">
          <span class="text-white">Status</span>
          <q-space />
        </q-bar>

        <q-card-section >
           <pre v-html="createStatusMessage"></pre>
        </q-card-section>

          <q-card-actions align="right" class="text-primary">
            
          <q-btn flat label="OK" @click="createStatusDialog=false;createDialog=false"/> 
        </q-card-actions>
      </q-card>
 </q-dialog>

 <!-- ********************************** CREATE END ***************************************** -->
 <!-- ********************************** ERROR START ***************************************** -->
 <q-dialog v-model="errorDialog" full-width>
      <q-card>
        <q-bar class="bg-negative">
          <span class="text-white">ERROR</span>
          <q-space />
        </q-bar>

        <q-card-section >
           <pre v-html="errors"></pre>
        </q-card-section>

          <q-card-actions align="right" class="text-primary">             
          <q-btn flat label="OK" @click="okError"/> 
        </q-card-actions>
      </q-card>
    </q-dialog>
 <!-- ********************************** ERROR END ***************************************** -->
  </div>
</template>
<script>
import { uid } from 'quasar'
import { required, numeric } from "vuelidate/lib/validators";

const regions = [""];
const segments = [""];
const accessMethods = [""];

export default {
  name: "Gde",
  data() {
    return {
      createDialog:false,
      createSegment:'',
      createStatusDialog:false,
      createStatusMessage:'',
      delDialog:false,
      delSegment:'',
      delStatusDialog:false,
      delStatusMessage:'',
      addStatusDialog:false,
      addStatusMessage:'',
      addSegment:'',
      addFile:'',
      addDialog:false,
      errorDialog:false,
      addNameDialog:false,
      addRegionDialog:false,
      addSegmentDialog:false,
      pageKey:uid(),
      showDetailsRegionDialog:false,
      showDetailsSegmentDialog:false,
      editNameDialog: false,
      editRegionDialog:false,
      editSegmentDialog: false,
      selectedName: [],
      selectedRegion:[],
      selectedSegment:[],
      loading: true,
      pagination: {
        rowsPerPage: 0
      },
      version: [],
      fromSave: false,
      deletedItems: [],
      unsavedItems: {
        names: [],
        regions: [],
        segments: []
      },
      saved: true,
      savedToggle: false,
      advanced: false,
      advancedToggle: false,
      items: [],
      regionItems: [],
      segmentItems: [],
      names: {},
      errors: "",
      addType: "name",
      addOptions: [
        { text: "Name", value: "name" },
        { text: "Segment", value: "segment" },
        { text: "Region", value: "region" }
      ],
      regionNullSubscriptsOptions: [
        { text: "Always", value: "ALWAYS" },
        { text: "Never", value: "NEVER" },
        { text: "Existing", value: "EXISTING" }
      ],
      regions,
      segments,
      accessMethods,
      map: [],
      fields: [
        {
          name: "name",
          field: "displayName",
          label: "Name",
          sortable: true,
          align: "left",
        },
        {
          name: "region",
          field: "region",
          label: "Region",
          sortable: true,
          align: "left"
        },
        {
          name: "segment",
          field: "segment",
          label: "Segment",
          sortable: true,
          align: "left"
        },
        {
          name: "file",
          field: "file",
          label: "File",
          sortable: true,
          align: "left"
        }
      ],
      regionFields: [
        {
          field:"name",
          name: "name",
          label: "Region",
          sortable: true,
          sortDirection: "desc",
          align: "left"
        },
        {
          name: "segment",
          field:'segment',
          label: "Dynamic Segment",
          sortable: true,
          align: "left"
        },
        {
          field:'keySize',
          name: "keySize",
          label: "Key Size",
          sortable: true,
          align: "right"
        },
        {
          field:'recordSize',
          name: "recordSize",
          label: "Record Size",
          sortable: true,
          align: "right"
        },
        {
          field:'beforeImage',
          name: "beforeImage",
          label: "Before Image Journaling",
          sortable: true,
          align: "center"
        },
        {
          field:'journal',
          name: "journal",
          label: "Journaling Enabled",
          sortable: true,
          align: "center"
        },
        {
          field:'journalFileName',
          name: "journalFileName",
          label: "Journal File Name",
          sortable: true,
          align: "left"
        },
        {
          field:'bufferSize',
          name: "bufferSize",
          label: "Journal Buffer Size",
          sortable: true,
          align: "right"
        },
        {
          field:'allocation',
          name: "allocation",
          label: "Journal Allocation",
          sortable: true,
          align: "right"
        }
      ],
      segmentFields: [
        {
          name: "name",
          field: "name",
          label: "Segment",
          sortable: true,
          align: "left"
        },
        {
          name: "fileName",
          field: "fileName",
          label: "File Name",
          sortable: true,
          align: "left"
        },
        {
          name: "accessMethod",
          field: "accessMethod",
          label: "Access Method",
          sortable: true,
          align: "left"
        },
        {
          key: "type",
          field: "type",
          label: "File Type",
          sortable: true,
          align: "left"
        },
        {
          name: "blockSize",
          field: "blockSize",
          label: "Block Size",
          sortable: true,
          align: "right"
        },
        {
          name: "allocation",
          field: "allocation",
          label: "Database Allocation Count",
          sortable: true,
          align: "right"
        },
        {
          name: "extensionCount",
          field: "extensionCount",
          label: "Database Extension Count",
          sortable: true,
          align: "right"
        },
        {
          name: "globalBufferCount",
          field: "globalBufferCount",
          label: "Global Buffer Count",
          sortable: true,
          align: "right"
        },
        {
          name: "lockSpace",
          field: "lockSpace",
          label: "Lock Space",
          sortable: true,
          align: "right"
        }
      ],
      mapFields: [
        {
          name: "from",
          field: "from",
          label: "From",
          sortable: true,
          align:'left'
        },
        {
          name: "to",
          field: "to",
          label: "Up to",
          sortable: true,
          align:'left'
        },
        {
          name: "region",
          field: "region",
          label: "Region",
          sortable: true,
          align:'left'
        },
        {
          name: "segment",
          field: "segment",
          label: "Segment",
          sortable: true,
          align:'left'
        },
        {
          name: "file",
          field: "file",
          label: "File Name",
          sortable: true,
         align:'left'
        }
      ],
      sortBy: "name",
      sortDesc: false,
      sortDirection: "asc",
      filter: null,
      striped: true,
      hover: true,
      fixed: true,
      selectedIndex: null,
      verified: false,
      modified: false,
      selectedItem: {
        name: {
          NAME: "",
          REGION: "DEFAULT"
        },
        segment: {
          NAME: "",
          FILE_NAME: "",
          FILE_TYPE: "DYNAMIC",
          ACCESS_METHOD: "BG",
          ALLOCATION: 150000,
          ASYNCIO: false,
          BLOCK_SIZE: 4096,
          BUCKET_SIZE: "",
          DEFER: "",
          DEFER_ALLOCATE: true,
          ENCRYPTION_FLAG: false,
          EXTENSION_COUNT: 20000,
          GLOBAL_BUFFER_COUNT: 1024,
          LOCK_SPACE: 1000,
          MUTEX_SLOTS: 1024,
          RESERVED_BYTES: 0,
          WINDOW_SIZE: ""
        },
        region: {
          NAME: "",
          DYNAMIC_SEGMENT: "DEFAULT",
          AUTODB: false,
          COLLATION_DEFAULT: 0,
          EPOCHTAPER: true,
          INST_FREEZE_ON_ERROR: false,
          JOURNAL: false,
          AUTOSWITCHLIMIT: "",
          BEFORE_IMAGE: false,
          FILE_NAME: "",
          KEY_SIZE: 64,
          LOCK_CRIT_SEPARATE: true,
          NULL_SUBSCRIPTS: "NEVER",
          QDBRUNDOWN: false,
          RECORD_SIZE: 256,
          STATS: true,
          STDNULLCOLL: true
        }
      },
      
    };
  },
  computed: {
    sortOptions() {
      const self = this;
      return self.fields
        .filter(f => f.sortable)
        .map(f => ({ text: f.label, value: f.key }));
    },
  endPoint(){
    if (this.$store.getters['app/details'].port && this.$store.getters['app/details'].protocol && this.$store.getters['app/details'].ip){
      return `${this.$store.getters['app/details'].protocol}://${this.$store.getters['app/details'].ip}:${this.$store.getters['app/details'].port}`
    } else {
      return ''
    }
  }
  },
  mounted() {
    const self = this;
    self.getdata();
  },
  validations() {
    switch (this.addType) {
      case "name":
        return {
          selectedItem: {
            name: {
              NAME: {
                required
              },
              REGION: {
                required
              }
            }
          }
        };
      case "segment":
        return {
          selectedItem: {
            segment: {
              NAME: {
                required
              },
              FILE_NAME: {
                required
              },
              EXTENSION_COUNT: {
                numeric
              },
              ALLOCATION: {
                numeric
              },
              BLOCK_SIZE: {
                numeric
              },
              GLOBAL_BUFFER_COUNT: {
                numeric
              },
              LOCK_SPACE: {
                numeric
              },
              MUTEX_SLOTS: {
                numeric
              },
              RESERVED_BYTES: {
                numeric
              }
            }
          }
        };
      case "region":
        return {
          selectedItem: {
            region: {
              NAME: {
                required
              },
              DYNAMIC_SEGMENT: {
                required
              },
              KEY_SIZE: {
                numeric
              },
              RECORD_SIZE: {
                numeric
              }
            }
          }
        };
      default:
        break;
    }
    return {};
  },
  methods: {
    async createRegion(){
        this.$refs.createSegmentField.validate()

      if (this.$refs.createSegmentField.hasError) {
          this.$q.notify({
            message: 'Please fill in required fileds!',
            color:'negative'
          })
          return 
      }
      this.createStatusMessage=''
      this.createStatusDialog = false
      let data = await this.$M('CREATEREGION^%YDBWEBGDE',{
        REGION: this.createSegment.toUpperCase(),
      })
      if (data && data.STATUS && data.RESULT){
        this.createSegment=''
        this.createDialog = false
        this.createStatusMessage = data.RESULT.join('\n')
        this.createStatusDialog = true
        this.getdata();
      } else {
        this.$q.notify({
          message: data && data.ERROR || 'Error Creating Database!',
          color:'negative'
        })
      }
    },
    async delSegmentAndName(){
       this.$refs.delSegmentField.validate()

      if (this.$refs.delSegmentField.hasError) {
          this.$q.notify({
            message: 'Please fill in required fileds!',
            color:'negative'
          })
          return 
      }
      this.delStatusMessage=''
      this.delStatusDialog = false
      let data = await this.$M('DELSEGMENTANDFILE^%YDBWEBGDE',{
        SEGMENT: this.delSegment.toUpperCase(),
      })
      if (data && data.STATUS && data.RESULT){
        this.delSegment=''
        this.delDialog = false
        this.delStatusMessage = data.RESULT.join('\n')
        this.delStatusDialog = true
        this.getdata();
      } else {
        this.$q.notify({
          message: data && data.ERROR || 'Error Deleting Data!',
          color:'negative'
        })
      }
    },
    async addNewSegmentAndFile(){
      this.$refs.addFileField.validate()
      this.$refs.addSegmentField.validate()
      if (this.$refs.addFileField.hasError || this.$refs.addSegmentField.hasError) {
          this.$q.notify({
            message: 'Please fill in required fileds!',
            color:'negative'
          })
          return 
      }
      this.addStatusMessage=''
      this.addStatusDialog = false
      let data = await this.$M('ADDSEGMENTANDFILE^%YDBWEBGDE',{
        SEGMENT: this.addSegment.toUpperCase(),
        FILE: this.addFile
      })
      if (data && data.STATUS && data.RESULT){
        this.addSegment=''
        this.addFile=''
        this.addDialog = false
        this.addStatusMessage = data.RESULT.join('\n')
        this.addStatusDialog = true
        this.getdata();
      } else {
        this.$q.notify({
          message: data && data.ERROR || 'Error Adding Data!',
          color:'negative'
        })
      }
 
    },
    forceUpper(e, obj, prop) {
      this.$set(obj, prop, e.toUpperCase());
    },
    show(item) {
      switch (item.name) {
        case "*":
          return false;
        case "#": // Also known as Local Locks
          return false;
        default:
          return true;
      }
    },
    info(item) {
      const self = this;
      self.boundItem = item;

      // Make unbound clones of the item object
      self.cachedItem = Object.assign({}, item);
      self.selectedItem = {
        name: {
          NAME: item.name,
          REGION: item.region
        },
        segment: {
          NAME: item.name,
          FILE_NAME: item.fileName,
          ACCESS_METHOD: item.accessMethod,
          ALLOCATION: item.allocation,
          ASYNCIO: item.asyncIO,
          BLOCK_SIZE: item.blockSize,
          DEFER_ALLOCATE: item.deferAllocate,
          ENCRYPTION_FLAG: item.encryption,
          EXTENSION_COUNT: item.extensionCount,
          GLOBAL_BUFFER_COUNT: item.globalBufferCount,
          LOCK_SPACE: item.lockSpace,
          MUTEX_SLOTS: item.mutexSlots,
          RESERVED_BYTES: item.reservedBytes
        },
        region: {
          NAME: item.name,
          DYNAMIC_SEGMENT: item.segment,
          AUTODB: item.autodb,
          COLLATION_DEFAULT: item.collationDefault,
          EPOCHTAPER: item.epochTaper,
          INST_FREEZE_ON_ERROR: item.instFreezeOnError,
          JOURNAL: item.journal,
          AUTOSWITCHLIMIT: item.autoSwitchLimit,
          BEFORE_IMAGE: item.beforeImage,
          FILE_NAME: item.journalFileName,
          KEY_SIZE: item.keySize,
          LOCK_CRIT_SEPARATE: item.lockCrit,
          NULL_SUBSCRIPTS: item.nullSubscripts,
          QDBRUNDOWN: item.qDbRundown,
          RECORD_SIZE: item.recordSize,
          STATS: item.stats,
          STDNULLCOLL: item.standardNullCollation
        }
      };
    },
    okError() {
      const self = this;

      // Reset & Hide the modal - nothing to do here
      self.errors = null;
      self.resetModal();
      self.errorDialog = false;
      // self.selectedItem = Object.assign(self.boundItem, self.cachedItem);
      self.$nextTick(()=>{
        self.pageKey = uid()
        self.getdata();
      })
    },
    cancel() {
      const self = this;

      // Reset the boundItem to the copy we made earlier and hide the modal
      // self.selectedItem = Object.assign(self.boundItem, self.cachedItem);
      self.errors = null;
      self.resetModal();

      // hide all the modals
      self.hideModals();
      self.$nextTick(()=>{
        self.pageKey = uid()
        self.getdata();
      })
    },
    focusElement() {
      const self = this;
      self.$refs.infoName.focus();
    },
    resetModal() {
      const self = this;

      // Clear out anything in selected item and set boundItem, CachedItem and selectedIndex to null
      // Only reset if errors isn't set
      if (self.errors === null) {
        self.selectedItem = {
          name: {
            NAME: "",
            REGION: "DEFAULT"
          },
          segment: {
            NAME: "",
            FILE_NAME: "",
            ACCESS_METHOD: "BG",
            ALLOCATION: 100,
            ASYNCIO: false,
            BLOCK_SIZE: 1024,
            DEFER_ALLOCATE: true,
            ENCRYPTION_FLAG: false,
            EXTENSION_COUNT: 100,
            GLOBAL_BUFFER_COUNT: 1024,
            LOCK_SPACE: 40,
            MUTEX_SLOTS: 1024,
            RESERVED_BYTES: 0
          },
          region: {
            NAME: "",
            DYNAMIC_SEGMENT: "DEFAULT",
            AUTODB: false,
            COLLATION_DEFAULT: 0,
            EPOCHTAPER: true,
            INST_FREEZE_ON_ERROR: false,
            JOURNAL: false,
            AUTOSWITCHLIMIT: "",
            BEFORE_IMAGE: false,
            FILE_NAME: "",
            KEY_SIZE: 64,
            LOCK_CRIT_SEPARATE: true,
            NULL_SUBSCRIPTS: "NEVER",
            QDBRUNDOWN: false,
            RECORD_SIZE: 256,
            STATS: true,
            STDNULLCOLL: true
          }
        };
        self.boundItem = null;
        self.cachedItem = null;
        self.selectedIndex = null;
      }
    },
    makeitems() {
      const self = this;

      // Builds a filled out items array combining information in regions, segments, and names
      const newItems = [];
      Object.keys(self.names).forEach(name => {
        if (name === "#") {
          self.displayName = "Local Locks";
        } else {
          self.displayName = name;
        }
        const displayItem = {
          displayName: self.displayName,
          name,
          region: self.names[name],
          segment: self.regions[self.names[name]].DYNAMIC_SEGMENT,
          file:
            self.segments[self.regions[self.names[name]].DYNAMIC_SEGMENT]
              .FILE_NAME
        };
        newItems.push(displayItem);
      });
      self.items = Object.assign([], newItems);

      // Build items array for regions
      const newRegions = [];
      Object.keys(self.regions).forEach(name => {
        const displayRegion = {
          name,
          segment: self.regions[name].DYNAMIC_SEGMENT,
          defaultCollation: self.regions[name].COLLATION_DEFAULT,
          recordSize: self.regions[name].RECORD_SIZE,
          keySize: self.regions[name].KEY_SIZE,
          nullSubscripts: self.regions[name].NULL_SUBSCRIPTS,
          standardNullCollation: self.regions[name].STDNULLCOLL,
          journal: self.regions[name].JOURNAL,
          instFreezeOnError: self.regions[name].INST_FREEZE_ON_ERROR,
          qDbRundown: self.regions[name].QDBRUNDOWN,
          epochTaper: self.regions[name].EPOCHTAPER,
          autodb: self.regions[name].AUTODB,
          stats: self.regions[name].STATS,
          lockCrit: self.regions[name].LOCK_CRIT_SEPARATE,
          journalFileName: self.regions[name].FILE_NAME,
          beforeImage: self.regions[name].BEFORE_IMAGE,
          bufferSize: self.regions[name].BUFFER_SIZE,
          allocation: self.regions[name].ALLOCATION,
          extensionCount: self.regions[name].EXTENSION,
          autoSwitchLimit: self.regions[name].AUTOSWITCHLIMIT
        };
        newRegions.push(displayRegion);
      });
      self.regionItems = Object.assign([], newRegions);

      // Build items array for segments
      const newSegments = [];
      Object.keys(self.segments).forEach(name => {
        const displaySegment = {
          name,
          fileName: self.segments[name].FILE_NAME,
          accessMethod: self.segments[name].ACCESS_METHOD,
          type: self.segments[name].FILE_TYPE,
          allocation: self.segments[name].ALLOCATION,
          blockSize: self.segments[name].BLOCK_SIZE,
          extensionCount: self.segments[name].EXTENSION_COUNT,
          globalBufferCount: self.segments[name].GLOBAL_BUFFER_COUNT,
          lockSpace: self.segments[name].LOCK_SPACE,
          reservedBytes: self.segments[name].RESERVED_BYTES,
          encryption: self.segments[name].ENCRYPTION_FLAG,
          mutexSlots: self.segments[name].MUTEX_SLOTS,
          deferAllocate: self.segments[name].DEFER_ALLOCATE,
          asyncIO: self.segments[name].ASYNCIO
        };
        newSegments.push(displaySegment);
      });
      self.segmentItems = Object.assign([], newSegments);
    },
    ok(type) {
      let item;
      const self = this;
      self.saved = false;
      self.savedToggle = !self.saved;

      // Move data from the modal to the correct object behind the scenes
      switch (type) {
        case "name":
          self.names[self.selectedItem.name.NAME] =
            self.selectedItem.name.REGION;
          self.unsavedItems.names.push(self.selectedItem.name.NAME);
          break;
        case "segment":
          item = Object.assign({}, self.selectedItem.segment);
          delete item.NAME;
          self.segments[self.selectedItem.segment.NAME] = item;
          self.unsavedItems.segments.push(self.selectedItem.segment.NAME);
          break;
        case "region":
          item = Object.assign({}, self.selectedItem.region);
          delete item.NAME;
          self.regions[self.selectedItem.region.NAME] = item;
          self.unsavedItems.regions.push(self.selectedItem.region.NAME);
          break;
        default:
          break;
      }

      // Verify the data, but don't save it
      self.verifydata();

      // hide all the modals
      self.hideModals();
      self.pageKey = uid()
      self.selectedName = []
      self.selectedRegion = []
      self.selectedSegment = []
    },
    hideModals() {
      const self = this
      self.errorDialog = false;
      self.editNameDialog = false;
      self.editRegionDialog = false;
      self.editSegmentDialog = false;
      self.addNameDialog = false;
      self.addRegionDialog = false;
      self.addSegmentDialog = false;
    },
    remove(item, type) {
      const self = this;
      let index = 0;
      let unsavedItemsIndex = 0;
      self.saved = false;
      self.savedToggle = !self.saved;

      switch (type) {
        case "name":
          unsavedItemsIndex = self.unsavedItems.names.findIndex(
            name => name === item.name
          );
          if (unsavedItemsIndex === -1) {
            self.deletedItems.push({
              name: {
                NAME: item.name
              }
            });
          } else {
            self.unsavedItems.names.splice(unsavedItemsIndex, 1);
          }
          delete self.names[item.name];
          index = self.items.findIndex(name => name.name === item.name);
          self.items.splice(index, 1);
           self.verifydata()
          // self.verified=true
          break;
        case "segment":
          // disable eslint max-len for next line so it looks like all other findIndex calls
          /* eslint-disable max-len */
          unsavedItemsIndex = self.unsavedItems.segments.findIndex(
            segment => segment === item.name
          );
          if (unsavedItemsIndex === -1) {
            self.deletedItems.push({
              segment: {
                SEGMENT: item.name
              }
            });
          } else {
            self.unsavedItems.segments.splice(unsavedItemsIndex, 1);
          }
          delete self.segments[item.name];
          index = self.segmentItems.findIndex(
            segment => segment.name === item.name
          );
          self.segmentItems.splice(index, 1);
           self.verifydata()
          // self.verified=true
          break;
        case "region":
          unsavedItemsIndex = self.unsavedItems.regions.findIndex(
            region => region === item.name
          );
          if (unsavedItemsIndex === -1) {
            self.deletedItems.push({
              region: {
                REGION: item.name
              }
            });
          } else {
            self.unsavedItems.regions.splice(unsavedItemsIndex, 1);
          }
          delete self.regions[item.name];
          index = self.regionItems.findIndex(
            region => region.name === item.name
          );
          self.regionItems.splice(index, 1);
          self.verifydata()
          // self.verified=true
          break;
        default:
          break;
      }
    },
    getdata() {
      const self = this;
      self.$axios({
        method: "GET",
        url: self.endPoint + "/gde/get"
      }).then(
        result => {
          self.names = result.data.names;
          self.regions = result.data.regions;
          self.segments = result.data.segments;
          self.accessMethods = result.data.accessMethods;
          self.map = result.data.map;
          self.makeitems();
          self.loading = false;
        },
        error => {
          self.errors = JSON.stringify(error,null,4);
          self.errorDialog = true
        }
      );
      // self.verified = true;
    },
    verifydata() {
      const self = this;
      self.verified = false;
      self.$axios({
        method: "POST",
        url: self.endPoint + "/gde/verify",
        data: {
          names: self.names,
          regions: self.regions,
          segments: self.segments
        }
      })
        .then(result => {
          if (result.data.verifyStatus) {
            self.verified = true;
            self.errors = null
            return Promise.resolve(self.makeitems());
          }
          /*
          if (
            !self.fromSave &&
            result.data.errors.length === 1
            && result.data.errors[0].includes("GDE-I-MAPBAD")
          ) {
            self.verified = true;
            return Promise.resolve(self.makeitems());
          }
          */
           self.errors = result.data.errors
           self.errorDialog = true
          return Promise.reject(result.data.errors);
        })
        /*
        .catch(error => {
          if (!self.errors) {
            self.errors = JSON.stringify(error,null,4);
          }
          switch (self.addType) {
            case "name":
              delete self.names[self.selectedItem.name.NAME];
              break;
            case "segment":
              delete self.segments[self.selectedItem.segment.NAME];
              break;
            case "region":
              delete self.regions[this.selectedItem.region.NAME];
              break;
            default:
              break;
          }
          self.verified = false;
          self.errorDialog = true
        });
        */
      self.verified = true;
    },
    async savedata() {
      const self = this;
      self.$axios({
        method: "POST",
        url: self.endPoint + "/gde/save",
        data: {
          names: self.names,
          regions: self.regions,
          segments: self.segments,
          deletedItems: self.deletedItems
        }
      })
        .then(result => {
          self.deletedItems = [];
          self.fromSave = true;
          if (result.data.verifyStatus) {
            self.getdata();
            self.verified = true;
            self.modified = false;
            self.saved = true;
            self.savedToggle = !self.saved;
            self.fromSave = false;
            self.unsavedItems = {
              names: [],
              regions: [],
              segments: []
            };
            self.errors = null
            self.notify("Data Saved!", true);
            // self.verified = false;
            return Promise.resolve(true);
          }
          self.fromSave = false;
          self.notify("Data Not Saved!", false);
          self.errorDialog = true
          self.verified = false;
          self.errors = result.data.errors
          return Promise.reject(result.data.errors);
        })
        .catch(error => {
          self.deletedItems = [];
          if (!self.errors) {
            self.errors = JSON.stringify(error,null,4);
          }
          self.saved = false;
          self.saved = !self.saved;
          self.verified = false;
          self.errorDialog = true
        });
    },
    notify(message, type) {
      let color = "positive";
      if (!type) {
        color = "negative";
      }
      this.$q.notify({
        message: message,
        color: color
      });
    }
  }
};
</script>
<style scoped>
pre {
    white-space: pre-wrap;       /* Since CSS 2.1 */
    white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
    white-space: -pre-wrap;      /* Opera 4-6 */
    white-space: -o-pre-wrap;    /* Opera 7 */
    word-wrap: break-word;       /* Internet Explorer 5.5+ */
}
</style>