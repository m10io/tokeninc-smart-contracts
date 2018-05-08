var web3 = require("web3")
var Storage = artifacts.require("./Storage.sol");
var TokenIO = artifacts.require("./TokenIO.sol");
var MultiSig = artifacts.require("./MultiSig.sol");

module.exports = function(done) {
    const TOKEN_AMOUNT = 1000
    let token;
    TokenIO.deployed().then(function(_token) {
      token = _token;
      console.log(`Transfer ${TOKEN_AMOUNT} Tokens to MultiSig Contract at ${MultiSig.address}`)
      console.time('transfer-token')
      return token.transfer(MultiSig.address, TOKEN_AMOUNT, { privateFor: [] })
    }).then(function(receipt) {
      console.timeEnd('transfer-token')
      console.log(receipt)
      return token.balanceOf.call(MultiSig.address)
    }).then(function(balance) {
      console.log(`${MultiSig.address} Token Balance: ${balance.toNumber()}`)
      done()
    }).catch((error) => {
      console.log(error)
      done()
    })
}
