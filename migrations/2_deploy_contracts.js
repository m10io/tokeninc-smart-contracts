var Promise = require('bluebird')

var SafeMath = artifacts.require("./SafeMath.sol");
var TokenIOLib = artifacts.require("./TokenIOLib.sol");
var TokenIOStorage = artifacts.require("./TokenIOStorage.sol");
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");
var TokenIOAuthority = artifacts.require("./TokenIOAuthority.sol");
var TokenIOFX = artifacts.require("./TokenIOFX.sol");
var TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");


// NOTE: When using truffle console, if the config file changes ensure to restart
// truffle console before attempting to `migrate --reset` as the config Variables
// seem to be cached between each migration run.
// TODO: Report issue on truffle github

const { mode, development, production } = require('../token.config.js');
const {
    AUTHORITY_DETAILS: { firmName, authorityAddress },
    TOKEN_DETAILS
} = mode == 'production' ? production : development;

module.exports = function(deployer, network, accounts) {
    var storage, token, authority, currencyAuthority, fxContract;
    // Deploy SafeMath Library
    deployer.deploy(SafeMath).then(() => {
        // Link SafeMath library to both TokenIO & TokenIOLib
        return deployer.link(SafeMath, [ TokenIOLib ]);
    }).then(() => {
        return deployer.deploy(TokenIOLib)
    }).then(() => {
        return deployer.link(TokenIOLib, [ TokenIOStorage, TokenIOERC20, TokenIOAuthority, TokenIOCurrencyAuthority, TokenIOFX ]);
    }).then(() => {
        // Deploy TokenIOStorage
        return deployer.deploy(TokenIOStorage)
    }).then((_storage) => {
        storage = _storage
        return deployer.deploy(TokenIOERC20, _storage.address)
        // return deployTokens(deployer, network, accounts, storage, TOKEN_DETAILS)
    }).then((_token) => {
        token = _token
        return storage.allowOwnership(_token.address)
    }).then((receipt) => {
        return token.setParams(...Object.keys(TOKEN_DETAILS[0]).map((k) => { return TOKEN_DETAILS[0][k] }))
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
        return deployer.deploy(TokenIOFX, storage.address)
    }).then((_fxContract) => {
        fxContract = _fxContract
        // Allow the currency authority contract to use the Storage contract
        return storage.allowOwnership(fxContract.address)
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
