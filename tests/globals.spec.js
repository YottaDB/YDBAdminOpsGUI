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

const { expect } = require("chai");
const { exec } = require("child_process");
const { deflateRawSync } = require("zlib");

describe("Globals Module Tests", async () => {
  it("Navigate to the globals page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/globals/`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await delay(500);
    await page.waitForSelector("#globals_header");
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/globals/`
    );
  });

  it("Check that the page contains the breadcrumbs", async () => {
    expect(await page.$("#breadcrumbs")).to.not.equal(null);
  });

  it("Check page header to exist and equal 'Globals'", async () => {
    expect(
      await page.$eval("#globals_header", node => node.innerText)
    ).to.equal("Globals");
  });

  it("Check that global ^YDBGLBLMDLTST doesn't exist", async () => {
    let searchInput = await page.$(".input_globals_search");
    await searchInput.focus();
    await page.keyboard.press("Backspace");
    await delay(500);
    await searchInput.type("YDBGLBLMDLTST");
    await delay(500);
    await page.keyboard.press("Enter");
    await delay(500);
    expect(
      await page.$$eval("#globals_column", nodes => Number(nodes.length))
    ).to.be.equal(
      0,
      "Global YDBGLBLMDLTST already exists, Please kill it manually and try running the tests again!"
    );
  });


  it("Creating Global ^YDBGLBLMDLTST", async () =>{
    exec("$ydb_dist/yottadb -run TESTADDGLOBAL^%YDBWEBGLBLS", async (error, stdout, stderr) => {
      if (error) {
          throw new Error (error)
      }
      if (stderr) {
        throw new Error (stderr)
      }
      if (Number(stdout) !== 1){
        throw new Error (stdout)
      }
     
  });
  await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
});




it("Check that global ^YDBGLBLMDLTST exists", async () => {
  let searchInput = await page.$(".input_globals_search");
  await searchInput.focus();
  await page.keyboard.press("Backspace");
  await delay(500);
  await searchInput.type("YDBGLBLMDLTST");
  await delay(500);
  await page.keyboard.press("Enter");
  await delay(500);
  expect(
    await page.$$eval("#globals_column", nodes => Number(nodes.length))
  ).to.be.equal(
    1
  );
});

it("Selecting ^YDBGLBLMDLTST from the globals list", async () =>{
  await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
  await delay(500);
  let searchInput = await page.$(".input_globals_search");
  await searchInput.focus();
  await page.keyboard.press("Backspace");
  await delay(500);
  await searchInput.type("YDBGLBLMDLTST");
  await delay(500);
  await page.keyboard.press("Enter");
  await delay(500);
  let glbl = await page.$("#column-YDBGLBLMDLTST");
  await glbl.click()
  await delay(500)
})

it("Checking that the correct subscript is present", async () =>{
  expect(
    await page.$eval("#global_tree", node => String(node.innerHTML).includes('^YDBGLBLMDLTST("LEVEL1")'))
  ).to.be.true
})

it("Checking that the correct value of the global at that subscript", async () =>{
  expect(
    await page.$eval("#global_tree", node => String(node.innerHTML).includes('VALUE'))
  ).to.be.true
})

it("Opening editing dialog to edit the value of the global", async () =>{
  const elem = await page.$(".q-tree__node-header-content");
  await clickOnElement(elem);
  await delay(5000)
})

it("Checking that correct global is selected", async () =>{
  expect(
    await page.$eval("#right_drawer_global_editor_title", node => String(node.innerHTML)==='^YDBGLBLMDLTST("LEVEL1")')
  ).to.be.true
})

it("Typing new global value", async () =>{
  const elem = await page.$("#codeMirrorGlobals");
  await clickOnElement(elem);
  await delay(500)
  await page.keyboard.type("-modified-by-gui");
})


it("Saving the new value of the global", async () =>{
  const elem = await page.$(".right_drawer_button_save");
  await elem.click()
  await delay(500)
  await page.keyboard.press("Enter");
 
})

it("Checking that the new value is reflected in the database", async () =>{
  exec("$ydb_dist/yottadb -run TESTCHECKGLOBAL^%YDBWEBGLBLS", async (error, stdout, stderr) => {
    if (error) {
        throw new Error (error)
    }
    if (stderr) {
      throw new Error (stderr)
    }
    if (String(stdout) !== 'VAUE-modified-by-gui'){
      throw new Error (stdout)
    }
   
});
})

it("Selecting ^YDBGLBLMDLTST from the globals list", async () =>{
  await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
  await delay(500);
  let searchInput = await page.$(".input_globals_search");
  await searchInput.focus();
  await page.keyboard.press("Backspace");
  await delay(500);
  await searchInput.type("YDBGLBLMDLTST");
  await delay(500);
  await page.keyboard.press("Enter");
  await delay(500);
  let glbl = await page.$("#column-YDBGLBLMDLTST");
  await glbl.click()
})




it("Creating Global ^YDBGLBLMDLTST thru the databse", async () =>{
  exec("$ydb_dist/yottadb -run TESTADDGLOBAL^%YDBWEBGLBLS", async (error, stdout, stderr) => {
    if (error) {
        throw new Error (error)
    }
    if (stderr) {
      throw new Error (stderr)
    }
    if (Number(stdout) !== 1){
      throw new Error (stdout)
    }
   
});

await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
});

it("Selecting ^YDBGLBLMDLTST from the globals list", async () =>{
  await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
  await delay(500);
  let searchInput = await page.$(".input_globals_search");
  await searchInput.focus();
  await page.keyboard.press("Backspace");
  await delay(500);
  await searchInput.type("YDBGLBLMDLTST");
  await delay(500);
  await page.keyboard.press("Enter");
  await delay(500);
  let glbl = await page.$("#column-YDBGLBLMDLTST");
  await glbl.click()
})
it("Opening editing dialog to kill the global", async () =>{
  await delay(500)
  const elem = await page.$(".q-tree__node-header-content");
  await clickOnElement(elem);
  await delay(500)
})

it("Killing the global from the gui", async () =>{
  await delay(500)
  const elem = await page.$(".right_drawer_button_kill");
  await elem.click()
  await delay(500)
  await page.keyboard.press("Enter");
  await delay(500)
})


it("Checking with the database that the global is killed", async () =>{
  exec("$ydb_dist/yottadb -run TESTCHECKKILLEDGLOBAL^%YDBWEBGLBLS", async (error, stdout, stderr) => {
    if (error) {
        throw new Error (error)
    }
    if (stderr) {
      throw new Error (stderr)
    }
    if (Number(stdout) !== 1){
      throw new Error (stdout)
    }
   
});

await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
});

it("Check that global ^YDBGLBLMDLTST doesn't exist thru the gui", async () => {
  let searchInput = await page.$(".input_globals_search");
  await searchInput.focus();
  await page.keyboard.press("Backspace");
  await delay(500);
  await searchInput.type("YDBGLBLMDLTST");
  await delay(500);
  await page.keyboard.press("Enter");
  await delay(500);
  expect(
    await page.$$eval("#globals_column", nodes => Number(nodes.length))
  ).to.be.equal(
    0
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