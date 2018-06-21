var SafeMath = artifacts.require("./SafeMath.sol");
var TokenIOLib = artifacts.require("./TokenIOLib.sol");
var TokenIOStorage = artifacts.require("./TokenIOStorage.sol");
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");
var TokenIOAuthority = artifacts.require("./TokenIOAuthority.sol");
var TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");


// NOTE: When using truffle console, if the config file changes ensure to restart
// truffle console before attempting to `migrate --reset` as the config Variables
// seem to be cached between each migration run.
// TODO: Report issue on truffle github

const { mode, development, production } = require('../token.config.js');
const {
  AUTHORITY_DETAILS: { firmName, authorityAddress },
  TOKEN_DETAILS: { USDx }
} = mode == 'production' ? production : development;

module.exports = function(deployer, network, accounts) {
	var storage, token, authority, currencyAuthority;
	// Deploy SafeMath Library
	deployer.deploy(SafeMath).then(() => {
		// Link SafeMath library to both TokenIO & TokenIOLib
		return deployer.link(SafeMath, [ TokenIOLib ]);
	}).then(() => {
    return deployer.deploy(TokenIOLib)
  }).then(() => {
    return deployer.link(TokenIOLib, [ TokenIOStorage, TokenIOERC20, TokenIOAuthority, TokenIOCurrencyAuthority ]);
  }).then(() => {
    // Deploy TokenIOStorage
    return deployer.deploy(TokenIOStorage)
  }).then((_storage) => {
    storage = _storage
    // Deploy TokenIOERC20
		return deployer.deploy(TokenIOERC20, storage.address)
	}).then((_token) => {
		token = _token
    // Allow ERC20 contract to use the Storage contract
    return storage.allowOwnership(token.address)
  }).then((receipt) => {
    // console.log('receipt', receipt)
    // Set ERC20 Params after allowed by Storage
    return token.setParams(...USDx)
  }).then((receipt) => {
    // console.log('receipt', receipt)
    // Deploy TokenIOAuthority
    return deployer.deploy(TokenIOAuthority, storage.address)
  }).then((_authority) => {
    authority = _authority
    // Allow the authority contract to use the Storage contract
    return storage.allowOwnership(authority.address)
  }).then((receipt) => {
    // console.log('receipt', receipt)
    // Deploy TokenIOCurrencyAuthority
    return deployer.deploy(TokenIOCurrencyAuthority, storage.address)
  }).then((_currencyAuthority) => {
    currencyAuthority = _currencyAuthority
    // Allow the currency authority contract to use the Storage contract
    return storage.allowOwnership(currencyAuthority.address)
  }).then((receipt) => {
    // console.log('receipt', receipt)
    return authority.setRegisteredFirm(firmName, true)
  }).then((receipt) => {
    // console.log('receipt', receipt)
    return authority.setRegisteredAuthority(firmName, accounts[0], true)
  }).then((receipt) => {
    // console.log('receipt', receipt)
	}).catch((error) => {
		console.log('DEPLOYMENT ERROR: ', error)
	})
}
