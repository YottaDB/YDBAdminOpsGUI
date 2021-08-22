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

describe("Documentation Module Tests", async () => {
  it("Navigate to the documentation page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/documentation/`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#documentation_iframe");
    await delay(1500);
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/documentation/`
    );
  });

  it("Check that the page navigated to the administration and operations guide", async () => {
    await page.waitForSelector("#documentation_loaded_confirmation");
    await delay(1500);
    const elementHandle = await page.$eval('#documentation_iframe', node => node.innerHTML)
    expect(elementHandle.includes('https://docs.yottadb.com/AdminOpsGuide/index.html')).to.be.true
});


it("Navigate to the administration and operations guide", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/documentation/administration_and_operations`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#documentation_iframe");
    await delay(1500);
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/documentation/administration_and_operations`
    );
  });

  it("Check that the page navigated to the administration and operations guide", async () => {
    await page.waitForSelector("#documentation_loaded_confirmation");
    await delay(1500);
    const elementHandle = await page.$eval('#documentation_iframe', node => node.innerHTML)
    expect(elementHandle.includes('https://docs.yottadb.com/AdminOpsGuide/index.html')).to.be.true
});

  it("Navigate to the multi-language_programmers_guide", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/documentation/multi-language_programmers_guide`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#documentation_iframe");
    await delay(1500);
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/documentation/multi-language_programmers_guide`
    );
  });

  it("Check that the page navigated to the multi-language_programmers_guide", async () => {
    await page.waitForSelector("#documentation_loaded_confirmation");
    await delay(1500);
    const elementHandle = await page.$eval('#documentation_iframe', node => node.innerHTML)
    expect(elementHandle.includes('https://docs.yottadb.com/MultiLangProgGuide/index.html')).to.be.true
  });


it("Navigate to the m_programmers_guide", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/documentation/m_programmers_guide`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#documentation_iframe");
    await delay(1500);
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/documentation/m_programmers_guide`
    );
  });

  it("Check that the page navigated to the m_programmers_guide", async () => {
    await page.waitForSelector("#documentation_loaded_confirmation");
    await delay(1500);
    const elementHandle = await page.$eval('#documentation_iframe', node => node.innerHTML)
    expect(elementHandle.includes('https://docs.yottadb.com/ProgrammersGuide/index.html')).to.be.true
  });


it("Navigate to the messages_and_recovery_procedures", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/documentation/messages_and_recovery_procedures`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#documentation_iframe");
    await delay(1500);
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/documentation/messages_and_recovery_procedures`
    );
  });

  it("Check that the page navigated to the messages_and_recovery_procedures", async () => {
    await page.waitForSelector("#documentation_loaded_confirmation");
    await delay(1500);
    const elementHandle = await page.$eval('#documentation_iframe', node => node.innerHTML)
    expect(elementHandle.includes('https://docs.yottadb.com/MessageRecovery/index.html')).to.be.true
  });


it("Navigate to the acculturation_guide", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/documentation/acculturation_guide`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#documentation_iframe");
    await delay(1500);
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/documentation/acculturation_guide`
    );
  });

  it("Check that the page navigated to the acculturation_guide", async () => {
    await page.waitForSelector("#documentation_loaded_confirmation");
    await delay(1500);
    const elementHandle = await page.$eval('#documentation_iframe', node => node.innerHTML)
    expect(elementHandle.includes('https://docs.yottadb.com/AcculturationGuide/acculturation.html')).to.be.true
  });


it("Navigate to the octo_documentation", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/documentation/octo_documentation`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#documentation_iframe");
    await delay(1500);
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/documentation/octo_documentation`
    );
  });

  it("Check that the page navigated to the octo_documentation", async () => {
    await page.waitForSelector("#documentation_loaded_confirmation");
    await delay(1500);
    const elementHandle = await page.$eval('#documentation_iframe', node => node.innerHTML)
    expect(elementHandle.includes('https://docs.yottadb.com/Octo/index.html')).to.be.true
  });


it("Navigate to the Plugins Page", async () => {
    await page.goto(`http://localhost:${MDevPort}/YottaDB/documentation/plugins`, {
      timeout: 0,
      waitUntil: "domcontentloaded"
    });
    await page.waitForSelector("#documentation_iframe");
    await delay(1500);
    expect(await page.url()).to.equal(
      `http://localhost:${MDevPort}/YottaDB/documentation/plugins`
    );
  });
  
  it("Check that the page navigated to is Plugins", async () => {
    await page.waitForSelector("#documentation_loaded_confirmation");
    await delay(1500);
    const elementHandle = await page.$eval('#documentation_iframe', node => node.innerHTML)
    expect(elementHandle.includes('https://docs.yottadb.com/Plugins/index.html')).to.be.true
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

});
