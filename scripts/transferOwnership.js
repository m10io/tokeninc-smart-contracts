var TokenIO = artifacts.require("./TokenIO.sol");

module.exports = function(done) {
    TokenIO.deployed().then(function(instance) {
      return instance.transferOwnership('0xb724961bB8ca933dc02e5b06F6Adc7850128D6D0')
  }).then(function(transferred) {
      console.log('transferred', transferred)
      done()
    }).catch((error) => {
      console.log(error)
      done()
    })
}
