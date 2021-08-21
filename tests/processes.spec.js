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
const fs = require('fs')
const util = require("util");
const execProm = util.promisify(exec);

describe("Running Processes Module Tests", async () => {
  it("Navigate to the running processes page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/processes/`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await delay(500);
    await page.waitForSelector("#processes_header");
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/processes/`
    );
  });

  it("Check that the page contains the breadcrumbs", async () => {
    await delay(500);
    expect(await page.$(".q-breadcrumbs")).to.not.equal(null);
  });

  it("Check that the page header exists and equals 'Running Processes'", async () => {
    await delay(500);
    expect(
      await page.$eval("#processes_header", node => node.innerText)
    ).to.equal("Running Processes");
  });

  it("Check that there is at least one process running", async () => {
    await delay(500);
    await page.waitForSelector("#processes_table");
    expect(
      await page.$$eval(".table_row_processes_list", nodes => nodes.length)
    ).to.above(0);
  });

  let pid
  it("Getting process details", async () => {
    await delay(500)
    let link = await page.$(".table_cell_process", node => node)
    pid = await page.$eval(".table_cell_process", nodes => nodes.innerText)
    await link.click()
    await delay(500)
  });

  it("Checking that the page navigated to the process details", async () => {
    await delay(500)
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/process/${pid}`
    );
  });

  it("Checking that the process details tab is selected", async () => {
    await delay(500)
    expect(await page.$("#details_panel")).to.not.equal(null);
  });



  it("Checking that the process details panel contains text", async () => {
    await delay(500)
    expect(await page.$eval("#details_panel_pre", nodes => nodes.innerText.length)).to.be.above(0);
  });

  it("Navigating to the variables tab", async () => {
    await delay(500)
    let link = await page.$("#variables_tab")
    await link.click()
    await delay(500)
  });

  it("Checking that the variables tab is selected", async () => {
    await delay(500)
    expect(await page.$("#variables_panel")).to.not.equal(null);
  });


  it("Checking that the variables panel contains text", async () => {
    await delay(500)
    expect(await page.$eval("#variables_panel_pre", nodes => nodes.innerText.length)).to.be.above(0);
  });


  it("Navigating to the intrinsic variables tab", async () => {
    await delay(500)
    let link = await page.$("#ivariables_tab")
    await link.click()
    await delay(500)
  });

  it("Checking that the intrinsic tab is selected", async () => {
    await delay(500)
    expect(await page.$("#ivariables_panel")).to.not.equal(null);
  });


  it("Checking that the intrinsic panel contains text", async () => {
    await delay(500)
    expect(await page.$eval("#ivariables_panel_pre", nodes => nodes.innerText.length)).to.be.above(0);
  });

  it("Navigating to the process details tab", async () => {
    await delay(500)
    let link = await page.$("#process_details_tab")
    await link.click()
    await delay(500)
  });


  it("Checking that the process details tab is selected", async () => {
    await delay(500)
    expect(await page.$("#details_panel")).to.not.equal(null);
  });



  it("Checking that the process details panel contains text", async () => {
    await delay(500)
    expect(await page.$eval("#details_panel_pre", nodes => nodes.innerText.length)).to.be.above(0);
  });

it("Navigating back to the process list", async () => {
  await delay(500)
  let link = await page.$("#btn-go-back")
  await link.click()
  await delay(500)
});

let processID
it("Creating a new process in the database and navigating to it", async () => {
  processID = await run_shell_command("$ydb_dist/yottadb -run TestLongProcess^%YDBWEBPRSC")
  await delay(500)
  let link = await page.$("#btn-refresh")
  await link.click()
  await page.waitForSelector("#btn-pid-"+processID.stdout);
  await page.screenshot({path: 'tests/results/'+Date.now()+'.png'});
  link = await page.$("#btn-pid-"+processID.stdout)
   await link.click()
   await delay(500)

  });

  it("Checking that the page navigated to the process details", async () => {
    await delay(500)
    expect(await page.url().includes(`/YottaDB/process/${processID.stdout}`)).to.be.true
  });


  it("Killing the newly created process", async () => {
    await delay(500)
    let link = await page.$("#btn-kill")
    await link.click()
    await delay(1500)
    await page.keyboard.press("Enter");
    await delay(2500);
  });

  it("Checking with the OS that the process has been killed", async () => {
    let status = await run_shell_command(`$ydb_dist/yottadb -run ^%XCMD 'write $zgetjpi(${processID.stdout},"isprocalive")'`)
    expect(Number(parseInt(status.stdout))).to.equal(0)
  });



  it("Check that there is atleast one process running", async () => {
    await page.waitForSelector("#processes_table");
    expect(
      await page.$$eval(".table_row_processes_list", nodes => nodes.length)
    ).to.above(0);
  });


  it("Check that the page does not contain the killed process", async () => {
    expect(await page.$("#btn-pid-"+processID.stdout)).to.be.equal(null);
  });


function delay(time) {
  return new Promise(function(resolve) {
    setTimeout(resolve, time);
  });
}
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
