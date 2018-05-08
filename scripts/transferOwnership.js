var TokenIO = artifacts.require("./TokenIO.sol");

module.exports = function(done) {
    TokenIO.deployed().then(function(instance) {
      return instance.transferOwnership('0x8908A7D71Fbb9005D8BC41037A452333AbD5ac9f')
  }).then(function(transferred) {
      console.log('transferred', transferred)
      done()
    }).catch((error) => {
      console.log(error)
      done()
    })
}
