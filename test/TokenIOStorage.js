var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOStorage = artifacts.require("./TokenIOStorage.sol");
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");
var TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");

const { mode, development, production } = require('../token.config.js');

const {
  AUTHORITY_DETAILS: { firmName, authorityAddress },
  TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS[0]

// Goal of this unit test is to check if the token values can be accessible directly from the contract;
// Test deprecating a contract and rehydrating a new token contract with the updated version,
//
// Recover the previous values of the original contract


contract("TokenIOERC20", function(accounts) {

	const TEST_ACCOUNT_1 = accounts[1]
	const DEPOSIT_AMOUNT = 100000

	it("Should get the token details directly from the storage contract", async () => {
		const storage = await TokenIOStorage.deployed()
		const token = await TokenIOERC20.deployed()

		const TOKEN_SUPPLY_ID = utils.solidityKeccak256(
			['string', 'string'],
			['token.supply', 'USDx']
		)

		const TOKEN_SUPPLY_STORAGE = +(await storage.getUint(TOKEN_SUPPLY_ID)).toString()
		assert.equal(TOKEN_SUPPLY_STORAGE, 0, "Token Supply should begin at zero supply")

		const TOKEN_SUPPLY_CONTRACT = +(await token.totalSupply()).toString()
		assert.equal(TOKEN_SUPPLY_STORAGE, TOKEN_SUPPLY_CONTRACT, "Token supply should be the same value as the storage value")

	})


	it("Should approve kyc and deposit funds into TEST_ACCOUNT_1", async () => {
		const CA = await TokenIOCurrencyAuthority.deployed()
		const storage = await TokenIOStorage.deployed()
		const token = await TokenIOERC20.deployed()

		const APPROVE_AND_DEPOSIT = await CA.approveKYCAndDeposit('USDx', TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")
		assert.equal(APPROVE_AND_DEPOSIT['receipt']['status'], "0x1", "Transaction should succeed.")

		const TOKEN_SUPPLY = +(await CA.getTokenSupply('USDx')).toString()
		assert.equal(TOKEN_SUPPLY, DEPOSIT_AMOUNT, "Token supply for USDx should equal the deposit amount")

		const TOKEN_SUPPLY_ID = utils.solidityKeccak256(['string', 'string'], ['token.supply', 'USDx'])

		const TOKEN_SUPPLY_STORAGE = +(await storage.getUint(TOKEN_SUPPLY_ID)).toString()
		assert.equal(TOKEN_SUPPLY_STORAGE, DEPOSIT_AMOUNT, "Token Supply should equal the deposited amount")

		const TOKEN_SUPPLY_CONTRACT = +(await token.totalSupply()).toString()
		assert.equal(TOKEN_SUPPLY_STORAGE, TOKEN_SUPPLY_CONTRACT, "Token supply should be the same value as the storage value")

	})


})
