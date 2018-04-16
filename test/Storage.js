var web3 = require('web3')
var Storage = artifacts.require("./Storage.sol");

contract('Storage', function(accounts) {

  it("It should deploy the storage contract, and ensure the owner is set.", async () => {

    const key = web3.utils.soliditySha3("storage.allowed",accounts[0])

    let storage = await Storage.deployed();

    let STEP_1_RESULT = await storage.getBool.call(key)
    assert.equal(STEP_1_RESULT, true, "Assert the owner was set in the contract");
    
  })

});
