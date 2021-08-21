/*
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
*/


const puppeteer = require('puppeteer');
const { PuppeteerScreenRecorder } = require('puppeteer-screen-recorder');
const { expect } = require('chai');
const _ = require('lodash');
const globalVariables = _.pick(global, ['browser', 'expect']);
const serverPort = 8089;



// puppeteer options
const opts = {
  headless: true,
  timeout: 100000,
  args: ['--no-sandbox']
};
const Config = {
  followNewTab: true,
  fps: 25,
  ffmpeg_Path: null,
  videoFrame: {
    width: 1024,
    height: 768,
  },
  aspectRatio: '4:3',
};

before (async function () {
  global.expect = expect;
  global.browser = await puppeteer.launch(opts);
  global.page = await global.browser.newPage();
  global.recorder = new PuppeteerScreenRecorder(page);
  await page.setViewport({ width: 1024, height: 768 });
  global.MDevPort = serverPort ;
  await recorder.start('./tests/results/'+Date.now()+'.mp4');
});

// close browser and reset global variables
after (async function () {
  await recorder.stop();
  await browser.close();
  global.browser = globalVariables.browser;
  global.expect = globalVariables.expect;
});