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

describe("Octo Module Tests", async () => {
  it("Navigating to the OCTO Tables page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/octo-sql`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await delay(500);
    await page.waitForSelector("#octo_header");
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/octo-sql`
    );
  });

  it("Checking that the page contains the breadcrumbs", async () => {
    await delay(500);
    expect(await page.$("#breadcrumbs")).to.not.equal(null);
  });

  it("Checking that the page header exists and equals 'OCTO Tables'", async () => {
    await delay(1500);
    expect(
      await page.$eval("#octo_header", node => node.innerText)
    ).to.equal("OCTO Tables");
  });


  await Promise.all([
    selectSqlTable('CUSTOMERS'),
    checkTableIsInTheList('CUSTOMERS'),
    checkTableIsPopulated('CUSTOMERS'),
    checkTableTotalCount('CUSTOMERS',91),
    checkTableIsPopulated('CUSTOMERS'),
    executeSQL('SELECT * FROM CUSTOMERS LIMIT 5;'),
    checkTableTotalCount('CUSTOMERS',5),
    selectSqlTable('PG_ATTRDEF'),
    checkTableIsInTheList('PG_ATTRDEF'),
    checkTableIsEmpty('PG_ATTRDEF'),
    checkTableTotalCount('PG_ATTRDEF',0),
    executeSQL('SELECT * FROM PG_ATTRDEF LIMIT 5;'),
    checkTableTotalCount('PG_ATTRDEF',0),
    selectSqlTable('EMPLOYEES'),
    checkTableIsInTheList('EMPLOYEES'),
    checkTableIsPopulated('EMPLOYEES'),
    checkTableTotalCount('EMPLOYEES',10),
    executeSQL('SELECT * FROM EMPLOYEES LIMIT 5;'),
    checkTableIsPopulated('EMPLOYEES'),
    checkTableTotalCount('EMPLOYEES',5),
    selectSqlTable('ORDERS'),
    checkTableIsInTheList('ORDERS'),
    checkTableIsPopulated('ORDERS'),
    checkTableTotalCount('ORDERS',100),
    executeSQL('SELECT * FROM ORDERS;'),
    checkTableIsPopulated('ORDERS'),
    checkTableTotalCount('ORDERS',196),
    selectSqlTable('ORDERDETAILS'),
    checkTableIsInTheList('ORDERS'),
    checkTableIsPopulated('ORDERS'),
    checkTableTotalCount('ORDERDETAILS',100),
    checkTableIsPopulated('CUSTOMERS'),
    executeSQL('SELECT * FROM ORDERDETAILS limit 100;'),
    checkTableTotalCount('ORDERDETAILS',100),
  ]);


async function checkTableIsInTheList(table){
  it(`Checking that the table ${table} is in the table list`,async ()=>{
    expect(
      await page.$$eval("#octo_column", nodes => Number(nodes.length))
    ).to.be.above(
      0
    );
  })
}
async function executeSQL(statement){
  it(`Executing SQL statement: ${statement}`, async () =>{
  const elem = await page.$("#codeMirrorTables");
  await clickOnElement(elem);
  await page.keyboard.press("End");
  for (let i=0;i<1000;i++){
    await page.keyboard.press("Backspace");
  }
  await page.keyboard.type(statement);
  let exBtn = await page.$('#octo-execute-btn')
  exBtn.click();
  await delay(500);
  await page.$('table#sqltable-light');
})
}
async function selectSqlTable(table){
  it(`Selecting the table ${table} from the tables list`, async () =>{
    let searchInput = await page.$(".input_octo_tables_search");
    await searchInput.focus();
    for (let i=0;i<100;i++){
      await page.keyboard.press("Backspace");
    }
    await searchInput.type(table);
    await page.keyboard.press("Enter");
    await delay(500);
    let tbl = await page.$("#column-"+table);
    await tbl.click()
    await delay(500)
  })
}


async function checkTableTotalCount(table,count){
  it(`Checking that the table ${table} contains (${count} rows)`, async () => {
    expect(
      await page.$$eval('table#sqltable-light tbody > tr', nodes => nodes.length)
    ).to.equal(count);
  });
}

async function checkTableIsPopulated(table){
    it(`Checking that table ${table} is populated with data`, async () => {
      await delay(500);
      expect(
        await page.$$eval('table#sqltable-light tbody > tr', nodes => nodes.length)
      ).to.above(2);
    });
}

async function checkTableIsEmpty(table){
  it(`Checking that table ${table} is not populated with data`, async () => {
    await delay(500);
    expect(
      await page.$$eval('table#sqltable-light tbody > tr', nodes => nodes.length)
    ).to.equal(0);
  });
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

  await page.mouse.click(rect.left + _x, rect.top + _y);
}

async function moveToElement(elem, x = null, y = null) {
  const rect = await page.evaluate(el => {
    const { top, left, width, height } = el.getBoundingClientRect();
    return { top, left, width, height };
  }, elem);
  const _x = x !== null ? x : rect.width / 2;
  const _y = y !== null ? y : rect.height / 2;

  await page.mouse.move(rect.left + _x, rect.top + _y);
}


})
