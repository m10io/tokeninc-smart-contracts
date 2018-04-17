var web3 = require("web3")

var Storage = artifacts.require("./Storage.sol");
var MultiSig = artifacts.require("./MultiSig.sol");
var TokenIO = artifacts.require("./TokenIO.sol");

/**
 * See http://truffleframework.com/tutorials/building-dapps-for-quorum-private-enterprise-blockchains
 * for deploying to Quorum environments
 */

module.exports = function(deployer, network) {

  if (network == 'develop') {
      var storage, token;
      deployer.deploy(Storage).then(function(_storage) {

        return deployer.deploy(MultiSig, Storage.address)
      }).then(function(_multisig) {

        return deployer.deploy(TokenIO, Storage.address)
      }).then(function(_token) {
        return Storage.deployed()
      }).then(function(_storage) {
        storage = _storage

        const ALLOW_MULTISIG = web3.utils.soliditySha3("storage.allowed", MultiSig.address)
        return storage.setBool(ALLOW_MULTISIG, true)
      }).then(function() {

        const ALLOW_TOKENIO = web3.utils.soliditySha3("storage.allowed", TokenIO.address)
        return storage.setBool(ALLOW_TOKENIO, true)
      }).then(function() {
        console.log('Contracts Deployed')
      }).catch(function(error) {
        console.log(error)
      })
  } else if (network == 'quorum'){
    var storage, token;
    deployer.deploy(Storage, { privateFor: [] }).then(function(_storage) {

      return deployer.deploy(MultiSig, Storage.address, { privateFor: [] })
    }).then(function(_multisig) {

      return deployer.deploy(TokenIO, Storage.address, { privateFor: [] })
    }).then(function(_token) {
      return Storage.deployed()
    }).then(function(_storage) {
      storage = _storage

      const ALLOW_MULTISIG = web3.utils.soliditySha3("storage.allowed", MultiSig.address)
      return storage.setBool(ALLOW_MULTISIG, true, { privateFor: [] })
    }).then(function() {

      const ALLOW_TOKENIO = web3.utils.soliditySha3("storage.allowed", TokenIO.address)
      return storage.setBool(ALLOW_TOKENIO, true, { privateFor: [] })
    }).then(function(receipt) {
      console.log('receipt', receipt)
      console.log('Contracts Deployed')
    }).catch(function(error) {
      console.log(error)
    })
  } else {
    console.log('unknown network')
  }
};
