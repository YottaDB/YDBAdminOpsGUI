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
const exp = require("constants");
const util = require("util");
const execProm = util.promisify(exec);

describe("GDE Module Tests", async () => {
  it("Navigate to the GDE module page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/gde/`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await delay(500);
    await page.waitForSelector("#gde_header");
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/gde/`
    );
  });

  it("Check that the page contains the breadcrumbs", async () => {
    await delay(500);
    expect(await page.$("#breadcrumbs")).to.not.equal(null);
  });

  it("Check page header to exist and equal 'Global Directory Editor (GDE)'", async () => {
    await delay(500);
    expect(
      await page.$eval("#gde_header", node => node.innerText)
    ).to.equal("Global Directory Editor (GDE)");
  });

  it("Check that there is atleast one [name] mapping", async () => {
    await delay(500);
    expect(
      await page.$$eval(".gde_name_mapping", nodes => nodes.length)
    ).to.be.above(0);
  });

  it("Check that there is atleast one [region] mapping", async () => {
    await delay(500);
    expect(
      await page.$$eval(".gde_region_mapping", nodes => nodes.length)
    ).to.be.above(0);
  });

  it("Check that there is atleast one segment mapping", async () => {
    await delay(500);
    expect(
      await page.$$eval(".gde_segment_mapping", nodes => nodes.length)
    ).to.be.above(0);
  });

  it("Check that there is atleast one [map] mapping", async () => {
    await delay(500);
    expect(
      await page.$$eval(".gde_map_mapping", nodes => nodes.length)
    ).to.be.above(0);
  });

  it("Checking that there is no mapping for YDBTEST", async () => {
    await delay(500);
    expect(
      await page.$$eval('#gdeYDBTEST', nodes => nodes.length)
    ).to.equal(0);
  });
  

  it("Adding a new mapping YDBTEST expecting %GDE-I-VERIFY, Verification OK", async () => {
    await delay(1500);
    let btnClick = await page.$("#gde_btn_add_segment");
    await btnClick.click();
    await delay(1500);
    let gdeInput = await page.$(".gde_input_add_segment_field");
    await gdeInput.focus();
    await gdeInput.type("YDBTEST");
    await delay(1500);
    gdeInput = await page.$(".gde_input_add_segment_file_field");
    await gdeInput.focus();
    await gdeInput.type("./tests/ydbtest.dat");
    await delay(1500);
    await page.keyboard.press("Enter");
    await page.waitForSelector("#gde_add_status_dialog")
    expect(
      await page.$eval("#gde_add_status_dialog", node => node.innerText.includes('%GDE-I-VERIFY, Verification OK'))
    ).to.be.true
  });

  it("Dismissing the status dialog", async () => {
      await delay(1000)
      let dialogOkBtn = await page.$("#gde_input_add_segment_ok_button")
      dialogOkBtn.click()
      await delay(1000);
  });  

  it("Checking that the [name] mapping exists for YDBTEST", async () => {
    await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
    await delay(2000);
    if (!await page.$('#gdeYDBTEST')){
      await delay(1500);
      let btnClick = await page.$("#gde_btn_add_segment");
      await btnClick.click();
      await delay(1500);
      let gdeInput = await page.$(".gde_input_add_segment_field");
      await gdeInput.focus();
      await gdeInput.type("YDBTEST");
      await delay(1500);
      gdeInput = await page.$(".gde_input_add_segment_file_field");
      await gdeInput.focus();
      await gdeInput.type("./tests/ydbtest.dat");
      await delay(1500);
      await page.keyboard.press("Enter");
      await delay(1000)
      let dialogOkBtn = await page.$("#gde_input_add_segment_ok_button")
      dialogOkBtn.click()
      await delay(1000);
      await page.reload({ waitUntil: ["networkidle0", "domcontentloaded"] });
    }

    await page.waitForSelector('#gdeYDBTEST')
    expect(
      await page.$$eval('#gdeYDBTEST', nodes => nodes.length)
    ).to.equal(1);
  });

  it("Selecting the [name] mapping YDBTEST", async () => {
    await delay(500);
    const btnAction = await page.$('#gdeYDBTEST')
    await btnAction.click()
    await delay(1000)
  });

  it("Editing the Name mapping for YDBTEST", async () => {
    await delay(500);
    const btnAction = await page.$('#gde_name_btn_edit');
    await btnAction.click()
    await page.waitForSelector(".selectedItem-name-NAME")
  });

  it("Checking that the value of Name equals YDBTEST", async () => {
    await delay(500);
    expect(
      await page.$$eval('[data-test-name-edit-value*="YDBTEST"]', nodes => nodes.length)
    ).to.equal(1);
  });


  it("Checking that the value of Region equals YDBTEST", async () => {
    await delay(500);
    const value = await page.$eval('#selectedItem-name-REGION', node => node.innerHTML.includes('YDBTEST'))
    await delay(500)
    expect(value).to.be.true
  });

  it("Dismissing the [name] editing box", async () => {
    await delay(500);
    const btnAction = await page.$('#selectedItem-name-REGION-btn');
    await btnAction.click()
    await delay(1000);
  });

  it("Applying the changes", async () => {
    await delay(500);
    const btnAction = await page.$('#btn-apply-changes');
    await btnAction.click()
    await delay(1000);
  });


  it("Checking that the [region] mapping exists for YDBTEST", async () => {
    await delay(500);
    await page.waitForSelector('#gde-data-region-action-class-YDBTEST');
    expect(
      await page.$$eval('#gde-data-region-action-class-YDBTEST', nodes => nodes.length)
    ).to.equal(1);
  });

  it("Selecting the [name] mapping YDBTEST", async () => {
    await delay(500);
    const btnAction = await page.$('#gde-data-region-action-class-YDBTEST');
    await btnAction.click()
    await delay(1000)
  });


  it("Clicking on the [region] details button", async () => {
    await delay(500);
    const btnAction = await page.$('#gde_region_btn_details');
    await btnAction.click()
    await delay(1000);
  });


  it("Checking that the details are populated", async () => {
    await delay(500);
    await page.waitForSelector('#region-details-dialog');
    expect(
      !await page.$('#region-details-dialog')
    ).to.be.false;
  });
  

  it("Dismissing the details dialog", async () => {
    await delay(500);
    const btnAction = await page.$('#region-details-dialog-btn-ok');
    await btnAction.click()
    await delay(1000);
  });
  
  it("Clicking on the [region] edit button", async () => {
    await delay(500);
    const btnAction = await page.$('.gde_region_btn_edit');
    await btnAction.click()
    await delay(1000);
  });

  it("Checking that the region fields dialog opened", async () => {
    await delay(500);
    await page.waitForSelector('#edit-region-dialog');
    expect(
      !await page.$('#edit-region-dialog')
    ).to.be.false;
  });
  
  it("Editing the value of the Key Size to something very high 100000", async () => {
    await delay(500);
    await page.waitForSelector('.region-edit-key-size');
    let gdeInput = await page.$(".region-edit-key-size");
    await gdeInput.focus();
    await delay(500);
    for (let i=0;i<100;i++){
    await page.keyboard.press("Backspace")
    }
    await delay(500);
    await page.keyboard.type("100000")
    await delay(500)
    const btnAction = await page.$('.edit-region-details');
    await btnAction.click()
  });

  it("Applying the changes", async () => {
    await delay(500);
    const btnAction = await page.$('#btn-apply-changes');
    await btnAction.click()
    await delay(1000);
  });


  it("Expecting error dialog", async () => {
    await delay(500);
    await page.waitForSelector('#error-dialog-card');
    expect(
      !await page.$('#error-dialog-card')
    ).to.be.false;
  });

  it("Dismissing error dialog", async () => {
    await delay(500);
    const btnAction = await page.$('#error-dialog-card-btn-ok');
    await btnAction.click()
    await delay(1000);
  });

  it("Selecting the [name] mapping YDBTEST", async () => {
    await delay(500);
    const btnAction = await page.$('#gde-data-region-action-class-YDBTEST');
    await btnAction.click()
    await delay(1000)
  });

  it("Clicking on the [region] edit button", async () => {
    await page.waitForSelector('.gde_region_btn_edit');
    const btnAction = await page.$('.gde_region_btn_edit');
    await btnAction.click()
    await delay(1000);
  });

  it("Checking that the [region] fields dialog opened", async () => {
    await delay(500);
    expect(
      !await page.$('#edit-region-dialog')
    ).to.be.false;
  });
  
  it("Editing the value of the Record Size to something very high 100000000", async () => {
    await delay(500);
    let gdeInput = await page.$(".region-edit-record-size");
    await gdeInput.focus();
    await delay(500);
    for (let i=0;i<100;i++){
    await page.keyboard.press("Backspace")
    }
    await delay(500);
    await page.keyboard.type("100000000")
    await delay(500)
    const btnAction = await page.$('.edit-region-details');
    await btnAction.click()
  });

  it("Applying the changes", async () => {
    await delay(500);
    const btnAction = await page.$('#btn-apply-changes');
    await btnAction.click()
    await delay(1000);
  });


  it("Expecting error dialog", async () => {
    await delay(500);
    await page.waitForSelector('#error-dialog-card');
    expect(
      !await page.$('#error-dialog-card')
    ).to.be.false;
  });

  it("Dismissing error dialog", async () => {
    await delay(500);
    const btnAction = await page.$('#error-dialog-card-btn-ok');
    await btnAction.click()
    await delay(1000);
  });

  it("Selecting the [name] mapping YDBTEST", async () => {
    await delay(500);
    const btnAction = await page.$('#gde-data-region-action-class-YDBTEST');
    await btnAction.click()
    await delay(1000)
  });


  it("Clicking on the [region] edit button", async () => {
    await delay(500);
    const btnAction = await page.$('.gde_region_btn_edit');
    await btnAction.click()
    await delay(1000);
  });

  it("Checking that the [region] fields dialog opened", async () => {
    await delay(500);
    await page.waitForSelector('#edit-region-dialog');
    expect(
      !await page.$('#edit-region-dialog')
    ).to.be.false;
  });
  
  it("Editing the value of the Key Size to 1019", async () => {
    await delay(500);
    await page.waitForSelector('.region-edit-key-size');
    let gdeInput = await page.$(".region-edit-key-size");
    await gdeInput.focus();
    await delay(500);
    for (let i=0;i<100;i++){
    await page.keyboard.press("Backspace")
    }
    await delay(500);
    await page.keyboard.type("1019")
    await delay(500)
  });

  it("Editing the value of the Record Size to 1048576", async () => {
    await delay(500);
    let gdeInput = await page.$(".region-edit-record-size");
    await gdeInput.focus();
    await delay(500);
    for (let i=0;i<100;i++){
    await page.keyboard.press("Backspace")
    }
    await delay(500);
    await page.keyboard.type("1048576")
    await delay(500)
    const btnAction = await page.$('.edit-region-details');
    await btnAction.click()
  });


  it("Applying the changes", async () => {
    await delay(500);
    const btnAction = await page.$('#btn-apply-changes');
    await btnAction.click()
    await delay(1000);
  });


  it("Not expecting error dialog", async () => {
    await delay(1000);
    expect(
      !!await page.$('#error-dialog-card')
    ).to.be.false;
  });

  it("Checking that the database file is not created", async () => {
    let response = await run_shell_command(`$ydb_dist/yottadb -run ^%XCMD 'write $zsearch("./tests/ydbtest.dat")]""'`)
    expect(
      parseInt(response.stdout)
    ).to.equal(0);
  });

  it("Creating database file", async () => {
    await delay(500);
    let btnClick = await page.$("#btn-create-db");
    await btnClick.click();
    await delay(500);
    await page.waitForSelector('.gde_create_database_file');
    let gdeInput = await page.$(".gde_create_database_file");
    await gdeInput.focus();
    await delay(500);
    for (let i=0;i<100;i++){
    await page.keyboard.press("Backspace")
    }
    await delay(500);
    await page.keyboard.type("YDBTEST")
    await delay(500)
    btnClick = await page.$("#gde-test-btn-create-db-ok");
    await btnClick.click();
  });

  it("Expecting status message", async () => {
    await delay(500);
    await page.waitForSelector('#gde-status-message');
    expect(
      !!await page.$('#gde-status-message')
    ).to.be.true;
  });

  it("Expecting status message to contain /tests/ydbtest.dat created", async () => {
    await delay(500);
    await page.waitForSelector('#gde-status-message');
    expect(
      await page.$eval('#gde-status-message', node => node.innerText.includes('/tests/ydbtest.dat created'))
    ).to.be.true;
  });

  it("Dismissing status message", async () => {
    await delay(500);
    let btnClick = await page.$("#gde-status-message-btn-ok");
    await btnClick.click();
  });

  it("Checking that the database file is created", async () => {
    await delay(500);
    let response = await run_shell_command(`$ydb_dist/yottadb -run ^%XCMD 'write $zsearch("./tests/ydbtest.dat")]""'`)
    expect(
      parseInt(response.stdout)
    ).to.equal(1);
  });

  it("Checking that the new record size for [region] YDBTEST is of length 1048576 characters", async () => {
    await delay(500);
    let response = await run_shell_command(`$ydb_dist/yottadb -run ^%XCMD 'set ^YDBTEST=" ",$zpiece(^YDBTEST," ",1048576)=" " write $zlength(^YDBTEST) kill ^YDBTEST'`)
    expect(
      parseInt(response.stdout)
    ).to.equal(1048576);
  });

  it("Checking that the new key size for [region] YDBTEST is of length 1000 characters", async () => {
    await delay(500);
    let response = await run_shell_command(`$ydb_dist/yottadb -run ^%XCMD 'set a=" ",$zpiece(a," ",1000)=" " set ^YDBTEST(a)=$zlength(a) write ^YDBTEST(a) kill ^YDBTEST'`)
    expect(
      parseInt(response.stdout)
    ).to.equal(1000);
  });

  it("Deleting database file", async () => {
    await delay(500);
    let btnClick = await page.$("#btn-delete-db");
    await btnClick.click();
    await delay(500);
    await page.waitForSelector('#delDialogTesting');
    let gdeInput = await page.$(".gde-delete-database-file");
    await gdeInput.focus();
    await delay(500);
    for (let i=0;i<100;i++){
    await page.keyboard.press("Backspace")
    }
    await delay(500);
    await page.keyboard.type("YDBTEST")
    await delay(500)
    btnClick = await page.$("#delete-segment-ok-btn");
    await btnClick.click();
  });

  it("Expecting status message", async () => {
    await page.waitForSelector('#gde-delete-status-dialog');
    expect(
      !!await page.$('#gde-delete-status-dialog')
    ).to.be.true;
  });

  it("Expecting status message to contain '%GDE-I-VERIFY, Verification OK'", async () => {
    await delay(500);
    await page.waitForSelector('#gde-delete-status-dialog');
    expect(
      await page.$eval('#gde-delete-status-dialog', node => node.innerText.includes('%GDE-I-VERIFY, Verification OK'))
    ).to.be.true;
  });

  it("Dismissing status message dialog", async () => {
    let dialog = await page.$('#gde-delete-status-dialog')
    dialog.focus()
    await delay(500);
    await page.keyboard.press("Enter")
    await delay(1500);
    if (await page.$("#gde-del-status-ok-btn")){
      let btnClick = await page.$("#gde-del-status-ok-btn");
      await btnClick.click();
    }
    await delay(1500);
    expect(
      !!await page.$("#gde-del-status-ok-btn")
    ).to.be.false;
  });

  it("Checking that the database file is still there", async () => {
    let response = await run_shell_command(`$ydb_dist/yottadb -run ^%XCMD 'write $zsearch("./tests/ydbtest.dat")]""'`)
    expect(
      parseInt(response.stdout)
    ).to.equal(1);
  });

  it("Deleting the database file", async () => {
    let response = await run_shell_command(`rm ./tests/ydbtest.dat && echo "deleted"`)
    expect(
      String(response.stdout)
    ).to.equal('deleted\n');
  });

  it("Checking that the [name] mapping does not exist for YDBTEST", async () => {
    await delay(1500);
    expect(
      await page.$$eval('[data-name-action-trigger*="YDBTEST"]', nodes => nodes.length)
    ).to.equal(0);
  });

  it("Cleaning up...", async () => {
    await delay(1500);
    await run_shell_command(`$ydb_dist/mupip create`)
    await delay(1500)
    await run_shell_command(`$ydb_dist/yottadb -run 'do Stop^%YDBWEB hang 1 d Start^%YDBWEB'`)

  });

async function run_shell_command(command) {
  let result;
  try {
    result = await execProm(command);
  } catch(ex) {
     result = ex;
  }
  if ( Error[Symbol.hasInstance](result) )
      return ;

  return result;
}

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
  await page.mouse.move(rect.left + _x, rect.top + _y);
  await page.mouse.click(rect.left + _x, rect.top + _y);
}
async function autoScroll(page){
  await page.evaluate(async () => {
      await new Promise((resolve, reject) => {
          var totalHeight = 0;
          var distance = 100;
          var timer = setInterval(() => {
              var scrollHeight = document.body.scrollHeight;
              window.scrollBy(0, distance);
              totalHeight += distance;

              if(totalHeight >= scrollHeight){
                  clearInterval(timer);
                  resolve();
              }
          }, 100);
      });
  });
}

async function scrollDown(page){
  await page.evaluate(async () => {
      await new Promise((resolve, reject) => {
          var distance = 25;
          window.scrollBy(0, distance);
          resolve()
      });
  });
}
})