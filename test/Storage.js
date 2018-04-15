var web3 = require('web3')
var Storage = artifacts.require("./Storage.sol");

contract('Storage', function(accounts) {

  it("It should deploy the storage contract, and ensure the owner is set.", function() {
    return Storage.deployed().then(function(instance) {
      const key = web3.utils.soliditySha3(
        "storage.allowed",
        accounts[0] // msg.sender
      )
      return instance.getBool.call(key);
    }).then(function(ownerSet) {
      assert.equal(ownerSet, true, "Assert the owner was set in the contract");
    })
  })

});
