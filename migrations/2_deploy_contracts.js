var web3 = require("web3")
var Promise = require('bluebird')
var TokenIO = artifacts.require("./TokenIO.sol");
var TokenIOStorage = artifacts.require("./TokenIOStorage.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = async function(deployer, network) {
	var token, storage;
	// Deploy SafeMath Library
	deployer.deploy(SafeMath).then(() => {
		// Link SafeMath library to both TokenIO & TokenIOLib
		return deployer.link(SafeMath, [ TokenIO ]);
	}).then(() => {
		// Deploy TokenIO
		return deployer.deploy(TokenIO, "0x161b0754f5f9b34f6aA0460B3572cC94621135b2")
	}).then((_token) => {
		token = _token
		return token.decimals.call()
	}).then((decimals) => {
		console.log('decimals', decimals.toString())
	})
}
