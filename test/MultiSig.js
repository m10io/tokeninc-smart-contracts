var web3 = require('web3')
var Storage = artifacts.require("./Storage.sol");
var MultiSig = artifacts.require("./MultiSig.sol");

contract('MultiSig', function(accounts) {

  it("It should deploy the MultiSig contract, and ensure the storage contract is allowed.", async () => {

    let storage = await Storage.deployed()
    let multiSig = await MultiSig.deployed(storage.address);
    let key = web3.utils.soliditySha3("storage.allowed", multiSig.address)

    let STEP_1_RESULT = await storage.setBool(key, multiSig.address);
    assert.equal(STEP_1_RESULT['receipt']['status'], '0x01', "Assert the transaction was successful");

    let STEP_2_RESULT = await storage.getBool(key);
    assert.equal(STEP_2_RESULT, true, "Assert the MultiSig contract is allowed by the storage contract");

  })

});
