var web3 = require("web3")
var Storage = artifacts.require("./Storage.sol");
var TokenIO = artifacts.require("./TokenIO.sol");
var MultiSig = artifacts.require("./MultiSig.sol");


contract("TokenIO", function(accounts) {

  it("Should deploy the TokenIO contract, and get the total supply from the storage contract.", async () => {

    const storage = await Storage.deployed()
    const token = await TokenIO.deployed(storage.address);

    const STEP_1_RESULT = await token.totalSupply.call();
    assert.equal(STEP_1_RESULT.toNumber(), 2343200000, "Assert the transaction was successful");

  })

  it("Should transfer the balance to the MultiSig Contract", async () => {

    const storage = await Storage.deployed()
    const token = await TokenIO.deployed(storage.address);
    const multisig = await MultiSig.deployed(storage.address);

    const STEP_1_RESULT = await token.transfer(multisig.address, 2343200000)
    assert.equal(STEP_1_RESULT["receipt"]["status"], "0x01", "Assert the transaction was successful");

    const STEP_2_RESULT = await token.balanceOf(multisig.address)
    assert.equal(STEP_2_RESULT.toNumber(), 2343200000, "Assert the transaction was successful");

  })


});
