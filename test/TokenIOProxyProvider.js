var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOProxyProvider = artifacts.require("./TokenIOProxyProvider.sol");
var TokenIOERC20FeesApply = artifacts.require("./TokenIOERC20FeesApply.sol");

const { mode, development, production } = require('../token.config.js');
const {
    AUTHORITY_DETAILS: { firmName, authorityAddress },
    TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS['USDx']

contract("TokenIOProxyProvider", function(accounts) {

    it("Should confirm AUTHORITY_ACCOUNT has been set appropriately", async () => {
        const proxyProvider = await TokenIOProxyProvider.deployed();
				const token = await TokenIOERC20FeesApply.deployed();

				// proxyProvider.updateProxiedContract()

        const proxyContract = await proxyProvider.getProxyContract('TokenIOERC20FeesApply');
				console.log('token.address', token.address)
				console.log('proxyContract', proxyContract);
				// const decimals = +(await token.decimals.call()).toString()
				// console.log('decimals', decimals);

    });

});
