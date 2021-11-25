/*
#################################################################
#                                                               #
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
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

describe("Running Dashboard Module Tests", async () => {
  it("Navigate to the Dashboard page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/dashboard`);
    await page.waitForSelector("table.peekbyname");
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/dashboard`
    );
  });

  it("Check that the DEFAULT region exists", async () => {
    const regions = await page.$$eval("h4", e => e.map(item => item.textContent));
    expect(regions).to.be.an('array').that.includes("DEFAULT");
  });

  it("Check that the Peek By Name data is returned", async () => {
    const peektables = await page.$$('table.peekbyname');
    const firsttable = peektables[0];
    const columns = await firsttable.$$eval('tr', rows => {
	    return Array.from(rows, row => {
		    const columns = row.querySelectorAll('td');
		    return Array.from(columns, column => column.innerText);
	    });
    })
    const firstcolumns = columns.map(c => c[0]);
    expect(firstcolumns).to.be.an('array').that.includes('Maximum record size');
  });
});
