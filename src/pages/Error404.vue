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
  <q-layout>
    <q-header
      elevated
      class="text-white"
      height-hint="61.59"
      :style="theme==='light'?'background: #FA780A':'background: #3C176A'"
    >
      <q-toolbar class="q-py-sm q-px-md">

        <q-btn
          round
          dense
          flat
          :ripple="false"
          style="margin-right:10px"
          :to="'/'"
        >
          <q-avatar size="42px">
            <img
              src="~assets/logo.png"
              class="rotating"
              style="background-color:white;"
            />
          </q-avatar>
        </q-btn>
      </q-toolbar>
    </q-header>

    <q-page-container style="max-width:1920px;margin:0 auto">
      <div class="text-center q-pa-md flex flex-center">
    <div>
         <div class="row flex flex-center q-pa-md" :style="'padding-top:50px'">
    <img
      v-if="!$q.dark.isActive"
      alt="Quasar logo"
      src="~assets/YottaDB_logo-light.svg"
      style="max-width:35vw"
    >
    <img
      v-if="$q.dark.isActive"
      alt="Quasar logo"
      src="~assets/YottaDB_logo-dark.svg"
      style="max-width:35vw"
    >
    </div>
      <div style="font-size: 30vh">
        404
      </div>

      <div class="text-h2" style="opacity:.4">
        Oops. Nothing here...
      </div>

      <q-btn
        class="q-mt-xl"
        color="white"
        text-color="blue"
        unelevated
        to="/"
        label="Go Home"
        size="xl"
        no-caps
      />
    </div>
  </div>
    </q-page-container>
  </q-layout>
</template>

<script>
export default {
  name: "MyLayout",
  data() {
    return {
      theme: "light",
      lang: this.$i18n.locale,
      langOptions: [
        { value: 'en-us', label: 'EN' },
        { value: 'de', label: 'DE' }
      ]
    };
  },
  created(){
    this.theme = this.$q.localStorage.getItem("ydb-app-theme") || "light";
    if (this.theme === "dark") {
      this.$q.dark.set(true);
    } else {
      this.$q.dark.set(false);
    }
  },
  methods: {
    changeTheme() {
      if (this.theme === "light") {
        this.$q.dark.set(true);
        this.theme = "dark";
      } else {
        this.$q.dark.set(false);
        this.theme = "light";
      }
    }
  },
    watch: {
    lang(lang) {
      this.$i18n.locale = lang
    }
  }
};
</script>

<style lang="sass">
.GL
  &__select-GL__menu-link
    .default-type
      visibility: hidden
    &:hover
      background: #0366d6
      color: white
      .q-item__section--side
        color: white
      .default-type
        visibility: visible
  &__toolbar-link
    a
      color: white
      text-decoration: none
      &:hover
        opacity: 0.7
  &__menu-link:hover
    background: #0366d6
    color: white
  &__menu-link-signed-in,
  &__menu-link-status
    &:hover
      & > div
        background: white !important
  &__menu-link-status
    color: $blue-grey-6
    &:hover
      color: $light-blue-9
  &__toolbar-select.q-field--focused
    width: 450px !important
    .q-field__append
      display: none
</style>
<style scoped>
.rotating {
  transition: transform 1s ease-in-out;
}
.rotating:hover {
  transform: rotateZ(360deg);
}
</style>
