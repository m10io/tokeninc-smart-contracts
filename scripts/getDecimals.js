var TokenIO = artifacts.require("./TokenIO.sol");

module.exports = function(done) {
    TokenIO.deployed().then((token) => {
		return token.decimals()
    }).then(function(decimals) {
		console.log('decimals', decimals.toString())
		done()
    }).catch((error) => {
		console.log(error)
		done()
    })
}
