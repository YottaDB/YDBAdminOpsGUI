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

describe("Routines Module Tests", async () => {
  it("Navigate to the routines page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/routines/`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#routines_header");
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/routines/`
    );
  });

  it("Check that the page contains the breadcrumbs", async () => {
    expect(await page.$("#breadcrumbs")).to.not.equal(null);
  });

  it("Check page header to exist and equal 'Routines'", async () => {
    expect(
      await page.$eval("#routines_header", node => node.innerText)
    ).to.equal("Routines");
  });

  it("Routine count has to be higher than zero", async () => {
    let btnClick = await page.$("#showsyscheckbox");
    await btnClick.click();
    await delay(500);
    expect(
      await page.$eval("#routine_count_section", node => node.innerText)
    ).to.not.equal("0 Routines");
  });

  it("Routines column is populated with more than 0 routines", async () => {
    expect(
      await page.$$eval("#routines_column", nodes => Number(nodes.length))
    ).to.be.above(0);
  });

  it("Testing routine YDBWEBRTNSTEST is not present in the routine list", async () => {
    let searchInput = await page.$(".routine_search_input");
    await searchInput.focus();
    await page.keyboard.press("Backspace");
    await delay(500);
    await searchInput.type("YDBWEBRTNSTEST");
    await delay(500);
    await page.keyboard.press("Enter");
    await delay(500);
    expect(
      await page.$$eval("#routines_column", nodes => Number(nodes.length))
    ).to.be.equal(
      0,
      "Routine YDBWEBRTNSTEST already exists, Please delete it manually and try running the tests again!"
    );
  });


  it("Add YDBWEBRTNSTEST routine to the routine list as an empty routine", async () => {
    let btnClick = await page.$("#rtn-btn-add");
    await btnClick.click();
    await delay(500);
    let rtnInput = await page.$(".rtn-add-input");
    await rtnInput.focus();
    await page.keyboard.press("Backspace");
    await delay(500);
    await rtnInput.type("YDBWEBRTNSTEST");
    await delay(500);
    await page.keyboard.press("Enter");
    await delay(500);
    let btnSave = await page.$("#rtn-btn-save");
    await btnSave.click();
    await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
  });


  it("Check that routine YDBWEBRTNSTEST is present in the routines list", async () => {
    let searchInput = await page.$(".routine_search_input");
    await searchInput.focus();
    await page.keyboard.press("Backspace");
    await searchInput.type("YDBWEBRTNSTEST");
    await page.keyboard.press("Enter");
    await delay(500);
    if (
      (await page.$$eval("#routines_column", nodes => Number(nodes.length))) === 0
    ) {
      throw new Error('Expecting to find routine YDBWEBRTNSTEST')
    }
      await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
    let rtn = await page.$("#column-YDBWEBRTNSTEST");
    await rtn.click()
    await delay(500);
  });

  it("Filling YDBWEBRTNSTEST with the routine content needed for testing", async () => {
    // This just moves the cursor, as there is an autofocus bug when choosing an already open routine
    await page.keyboard.type("\t");
    await page.keyboard.press('End');
    await page.keyboard.press('Enter');
    await page.keyboard.type("\t;");
    await page.keyboard.press('Enter');
    await page.keyboard.type(";");
    await page.keyboard.press('Enter');
    await page.keyboard.type(";");
    await page.keyboard.press('Enter');
    await page.keyboard.type(";");
    await page.keyboard.press('Enter');
    await page.keyboard.press('Home');
    await page.keyboard.type("TEST W 1 Q");
    await page.keyboard.press('Enter');
  })


  it("Saving routine YDBWEBRTNSTEST", async () =>{
    btnSave = await page.$("#rtn-btn-save");
    await btnSave.click();
    await delay(1000);
  })

  it("Executing D TEST^YDBWEBRTNSTEST, expecting 1", async () =>{
    exec("$ydb_dist/yottadb -run %XCMD 'D TEST^YDBWEBRTNSTEST'", (error, stdout, stderr) => {
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
  })

  it("Selecting YDBWEBRTNSTEST from the routines list", async () =>{
    await delay(500);
    searchInput = await page.$(".routine_search_input");
    await searchInput.focus();
    await page.keyboard.press("Backspace");
    await delay(500);
    await searchInput.type("YDBWEBRTNSTEST");
    await delay(500);
    await page.keyboard.press("Enter");
    await delay(500);
    rtn = await page.$("#column-YDBWEBRTNSTEST");
    await rtn.click()
    await delay(500);
  })

  it("Deleting routine YDBWEBRTNSTEST", async () =>{
    let btnDelelete = await page.$("#rtn-btn-delete");
    await btnDelelete.click();
    await delay(500);
    await page.keyboard.press("Enter");
    await delay(500);
    await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
  })

  it("Checking that the routine YDBWEBRTNSTEST doesn't exist anymore", async () => {
      await delay(500);
      searchInput = await page.$(".routine_search_input");
      await searchInput.focus();
      await page.keyboard.press("Backspace");
      await delay(500);
      await searchInput.type("YDBWEBRTNSTEST");
      await delay(500);
      await page.keyboard.press("Enter");
      await delay(500);
      expect(
        await page.$$eval("#routines_column", nodes => Number(nodes.length))
      ).to.be.equal(
        0
      );
  });

  it("Testing [Show System generated routines button]]", async () => {
    let routinesCount = await page.$$eval("#routines_column", nodes => Number(nodes.length))
    let btnClick = await page.$("#showsyscheckbox");
    await btnClick.click();
    searchInput = await page.$(".routine_search_input");
    await searchInput.focus();
    for (let i=0; i<25; i++){
      await page.keyboard.press("Backspace");
    }
    await searchInput.type('*')
    await page.keyboard.press("Enter");
    await delay(500);
    let generatedCount = await page.$$eval("#routines_column", nodes => Number(nodes.length))
    expect(
      generatedCount
    ).to.be.above(
      routinesCount
    );
});

  function delay(time) {
    return new Promise(function(resolve) {
      setTimeout(resolve, time);
    });
  }
});
