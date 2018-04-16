var web3 = require("web3")
var Storage = artifacts.require("./Storage.sol");
var MultiSig = artifacts.require("./MultiSig.sol");

contract("MultiSig", function(accounts) {

  it("It should deploy the MultiSig contract, and ensure the storage contract is allowed.", async () => {

    // Set Contracts
    const storage = await Storage.deployed()
    const multiSig = await MultiSig.deployed(storage.address);

    // Set KEYS
    const STORAGE_ALLOWED_KEY = web3.utils.soliditySha3("storage.allowed", multiSig.address)
    const MULTISIG_OWNER_KEY = web3.utils.soliditySha3("multisig.owner", accounts[1])

    // Step 1
    const STEP_1_RESULT = await storage.setBool(STORAGE_ALLOWED_KEY, multiSig.address);
    assert.equal(STEP_1_RESULT["receipt"]["status"], "0x01", "Assert the transaction was successful");

    // Step 2
    const STEP_2_RESULT = await storage.getBool(STORAGE_ALLOWED_KEY);
    assert.equal(STEP_2_RESULT, true, "Assert the MultiSig contract is allowed by the storage contract");

    // Step 3
    const STEP_3_RESULT = await multiSig.initializeOwners([ accounts[1], accounts[2], accounts[3], accounts[4], accounts[5] ]);
    assert.equal(STEP_3_RESULT["receipt"]["status"], "0x01", "Assert the transaction was successful");

    // Step 4
    const STEP_4_RESULT = await storage.getBool(MULTISIG_OWNER_KEY)
    assert.equal(STEP_2_RESULT, true, "Assert the address is an owner of the MultiSig Contract");

  })

});
