var web3 = require("web3")
var Storage = artifacts.require("./Storage.sol");
var TokenIO = artifacts.require("./TokenIO.sol");
var MultiSig = artifacts.require("./MultiSig.sol");

module.exports = function(done) {
    const SET_TOKENIO_KEY = web3.utils.soliditySha3("storage.allowed", TokenIO.address)

    let storage;
    Storage.deployed().then(function(_storage) {
      storage = _storage;

      console.log('SET_TOKENIO_KEY', SET_TOKENIO_KEY)
      console.time('set-bool')
      return storage.setBool(SET_TOKENIO_KEY, true)
    }).then(function(receipt) {
      console.timeEnd('set-bool')
      console.time('get-bool')
      return storage.getBool(SET_TOKENIO_KEY)
    }).then(function(isSet) {
      console.timeEnd('get-bool')
      console.log('TokenIO Contract Storage Access: ', isSet)
      done()
    }).catch((error) => {
      console.log(error)
      done()
    })
}
