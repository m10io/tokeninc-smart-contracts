var web3 = require("web3")
var TokenIO = artifacts.require("./TokenIO.sol");

/*
 * Tests should be run on development network, as it allows multiple accounts to be
 * unlocked and funded by default
 */

contract("TokenIO", function(accounts) {

  it("Should allow the TokenIO contract to access the storage contract.", async () => {
    const token = await TokenIO.deployed();

    const TOKEN_NAME_KEY = web3.utils.soliditySha3("token.name")

    const STEP_1_RESULT = await token.getString.call(TOKEN_NAME_KEY)
    assert.equal(STEP_1_RESULT, "USD by token.io", "Assert the token name can be accessed through storage primative");

  })


});
