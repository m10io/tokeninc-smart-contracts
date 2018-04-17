var web3 = require('web3')
var Storage = artifacts.require("./Storage.sol");

contract('Storage', function(accounts) {

  it("Should deploy the storage contract, and ensure the owner is set.", async () => {

    // Set Contract
    const storage = await Storage.deployed();

    // Set Keys
    const STORAGE_ALLOWED_KEY = web3.utils.soliditySha3("storage.allowed", accounts[0])

    // Step 1
    const STEP_1_RESULT = await storage.getBool.call(STORAGE_ALLOWED_KEY)
    assert.equal(STEP_1_RESULT, true, "Assert the owner was set in the contract");

  })

});
