/*
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
*/

const { expect } = require("chai");
const { exec } = require("child_process");
const { deflateRawSync } = require("zlib");

describe("Main Navigation Module Tests", async () => {
  it("Navigate to the main navigation page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await delay(1500);
    await page.waitForSelector("#mn-navigation-panels");
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/`
    );
  });
  it("Check that the page contains the navigation panels", async () => {
    expect(await page.$("#mn-navigation-panels")).to.not.equal(null);
  });

  it("Expanding the system management navigation panel", async () => {
    const elem = await page.$("#mn-system-management-expand-btn");
    await elem.click()
    await delay(1500)
    expect(await page.$("#mn-system-management-expand-panel")).to.not.equal(null);
  });

  it("Clicking on 'running processes module'", async () => {
    const elem = await page.$("#mn-system-management-app-runningprocess");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/processes`
    );
  });

  it("Navigating back to the navigation module", async () => {
    const elem = await page.$("#main-navigation-page");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/`
    );
  });

  it("Expanding the system management navigation panel", async () => {
    const elem = await page.$("#mn-system-management-expand-btn");
    await elem.click()
    await delay(1500)
    expect(await page.$("#mn-system-management-expand-panel")).to.not.equal(null);
  });

  it("Clicking on 'gde module'", async () => {
    const elem = await page.$("#mn-system-management-app-gde");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/gde`
    );
  });

  it("Navigating back to the navigation module", async () => {
    const elem = await page.$("#main-navigation-page");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/`
    );
  });

  it("Expanding the system explorer navigation panel", async () => {
    const elem = await page.$("#mn-system-explorer-expand-btn");
    await elem.click()
    await delay(1500)
    expect(await page.$("#mn-system-explorer-expand-panel")).to.not.equal(null);
  });

  it("Clicking on 'routines explorer module'", async () => {
    const elem = await page.$("#mn-system-explorer-app-routines");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/routines`
    );
  });

  it("Navigating back to the navigation module", async () => {
    const elem = await page.$("#main-navigation-page");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/`
    );
  });

  it("Expanding the system explorer navigation panel", async () => {
    const elem = await page.$("#mn-system-explorer-expand-btn");
    await elem.click()
    await delay(1500)
    expect(await page.$("#mn-system-explorer-expand-panel")).to.not.equal(null);
  });

  it("Clicking on 'globals explorer module'", async () => {
    const elem = await page.$("#mn-system-explorer-app-globals");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/globals`
    );
  });

  it("Navigating back to the navigation module", async () => {
    const elem = await page.$("#main-navigation-page");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/`
    );
  });

  it("Expanding the system explorer navigation panel", async () => {
    const elem = await page.$("#mn-system-explorer-expand-btn");
    await elem.click()
    await delay(1500)
    expect(await page.$("#mn-system-explorer-expand-panel")).to.not.equal(null);
  });

  it("Clicking on 'octo explorer module'", async () => {
    const elem = await page.$("#mn-system-explorer-app-octo");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/octo-sql`
    );
  });

  it("Navigating back to the navigation module", async () => {
    const elem = await page.$("#main-navigation-page");
    await elem.click()
    await delay(1500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/`
    );
  });

function delay(time) {
  return new Promise(function(resolve) {
    setTimeout(resolve, time);
  });
}

async function clickOnElement(elem, x = null, y = null) {
  const rect = await page.evaluate(el => {
    const { top, left, width, height } = el.getBoundingClientRect();
    return { top, left, width, height };
  }, elem);
  const _x = x !== null ? x : rect.width / 2;
  const _y = y !== null ? y : rect.height / 2;

  await page.mouse.click(rect.left + _x, rect.top + _y);
}
})
