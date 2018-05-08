var web3 = require("web3")
var Storage = artifacts.require("./Storage.sol");
var TokenIO = artifacts.require("./TokenIO.sol");
var MultiSig = artifacts.require("./MultiSig.sol");

module.exports = function(done) {
    const STORAGE_ACCESS_TOKENIO_KEY = web3.utils.soliditySha3("storage.allowed", TokenIO.address)
    const STORAGE_ACCESS_MULTISIG_KEY = web3.utils.soliditySha3("storage.allowed", MultiSig.address)

    let storage;
    Storage.deployed().then(function(_storage) {
      storage = _storage;

      return storage.getBool(STORAGE_ACCESS_TOKENIO_KEY)
    }).then(function(isSet) {
      console.log('TokenIO Contract Storage Access: ', isSet)

      return storage.getBool(STORAGE_ACCESS_MULTISIG_KEY)
    }).then(function(isSet) {
      console.log('MultiSig Contract Storage Access: ', isSet)

      done()
    }).catch((error) => {
      console.log(error)
      done()
    })
}
