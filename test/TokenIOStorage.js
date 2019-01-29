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

const USDx = TOKEN_DETAILS['USDx']

// Goal of this unit test is to check if the token values can be accessible directly from the contract;
// Test deprecating a contract and rehydrating a new token contract with the updated version,
//
// Recover the previous values of the original contract


contract("TokenIOStorage", function(accounts) {

	const TEST_ACCOUNT_1 = accounts[0]
	const TEST_ACCOUNT_2 = accounts[1]
	const DEPOSIT_AMOUNT = 10000e2
  const SPENDING_LIMIT = DEPOSIT_AMOUNT/2

	it("Should get the token details directly from the storage contract", async () => {
		const storage = await TokenIOStorage.deployed()
		const token = await TokenIOERC20.deployed()

		const TOKEN_SUPPLY_ID = utils.solidityKeccak256(['string', 'string'], ['token.supply', 'USDx'])

		const TOKEN_SUPPLY_STORAGE = +(await storage.getUint(TOKEN_SUPPLY_ID)).toString()
		assert.equal(TOKEN_SUPPLY_STORAGE, 0, "Token Supply should begin at zero supply")

		const TOKEN_SUPPLY_CONTRACT = +(await token.totalSupply()).toString()
		assert.equal(TOKEN_SUPPLY_STORAGE, TOKEN_SUPPLY_CONTRACT, "Token supply should be the same value as the storage value")

	})


	it("Should approve kyc and deposit funds into TEST_ACCOUNT_2 and ensure balance is the same for multiple interface contracts", async () => {
		const CA = await TokenIOCurrencyAuthority.deployed()
		const storage = await TokenIOStorage.deployed()
		const token = await TokenIOERC20.deployed()

		const APPROVE_AND_DEPOSIT = await CA.approveKYCAndDeposit('USDx', TEST_ACCOUNT_2, DEPOSIT_AMOUNT, SPENDING_LIMIT, "Token, Inc.")
		assert.equal(APPROVE_AND_DEPOSIT['receipt']['status'], "0x1", "Transaction should succeed.")

		const TOKEN_SUPPLY = +(await CA.getTokenSupply('USDx')).toString()
		assert.equal(TOKEN_SUPPLY, DEPOSIT_AMOUNT, "Token supply for USDx should equal the deposit amount")

		const TOKEN_SUPPLY_ID = utils.solidityKeccak256(['string', 'string'], ['token.supply', 'USDx'])

		const TOKEN_SUPPLY_STORAGE = +(await storage.getUint(TOKEN_SUPPLY_ID)).toString()
		assert.equal(TOKEN_SUPPLY_STORAGE, DEPOSIT_AMOUNT, "Token Supply should equal the deposited amount")

		const TOKEN_SUPPLY_CONTRACT = +(await token.totalSupply()).toString()
		assert.equal(TOKEN_SUPPLY_STORAGE, TOKEN_SUPPLY_CONTRACT, "Token supply should be the same value as the storage value")

	})

	it("Should set, get, and delete a uint256 value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = utils.solidityKeccak256(['string'], ['uint256'])
		const value = 100
		const SET_TX = await storage.setUint(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = +(await storage.getUint(id)).toString()
		assert.equal(value, GET_VALUE_BEG, "Uint value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteUint(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = +(await storage.getUint(id)).toString()
		assert.equal(0, GET_VALUE_END, "Uint value should be deleted from storage.")
	})

	it("Should set, get, and delete a string value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = utils.solidityKeccak256(['string'], ['string'])
		const value = 'testing'
		const SET_TX = await storage.setString(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getString(id)
		assert.equal(value, GET_VALUE_BEG, "String value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteString(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getString(id)
		assert.equal("", GET_VALUE_END, "String value should be deleted from storage.")
	})

	it("Should set, get, and delete a address value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = utils.solidityKeccak256(['string'], ['address'])
		const value = accounts[0]
		const SET_TX = await storage.setAddress(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getAddress(id)
		assert.equal(value, GET_VALUE_BEG, "Address value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteAddress(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getAddress(id)
		assert.equal("0x0000000000000000000000000000000000000000", GET_VALUE_END, "Address value should be deleted from storage.")
	})

	it("Should set, get, and delete a bytes value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = utils.solidityKeccak256(['string'], ['bytes'])
		const value = "0x112358132134"
		const SET_TX = await storage.setBytes(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getBytes(id)
		assert.equal(value, GET_VALUE_BEG, "Bytes value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteBytes(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getBytes(id)
		assert.equal("0x", GET_VALUE_END, "Bytes value should be deleted from storage.")
	})

	it("Should set, get, and delete a bool value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = utils.solidityKeccak256(['string'], ['bool'])
		const value = true
		const SET_TX = await storage.setBool(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getBool(id)
		assert.equal(value, GET_VALUE_BEG, "Bool value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteBool(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getBool(id)
		assert.equal(false, GET_VALUE_END, "Bool value should be deleted from storage.")
	})

	it("Should set, get, and delete a int256 value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = utils.solidityKeccak256(['string'], ['int256'])
		const value = -100
		const SET_TX = await storage.setInt(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = +(await storage.getInt(id)).toString()
		assert.equal(value, GET_VALUE_BEG, "Int value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteInt(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = +(await storage.getInt(id)).toString()
		assert.equal(0, GET_VALUE_END, "Int value should be deleted from storage.")
	})

	it("Should set, get and delete token name value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = "0x166a8e28b4afdb04d6ce602644452c71e9f5f885"; // test account
		const value = "test"
		const SET_TX = await storage.setTokenName(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getTokenName(id)
		assert.equal(value, GET_VALUE_BEG, "Int value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteTokenName(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getTokenName(id)
		assert.equal("", GET_VALUE_END, "String value should be deleted from storage.")
	})

	it("Should set, get and delete token symbol value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = "0x166a8e28b4afdb04d6ce602644452c71e9f5f885"; // test account
		const value = "test symbol"
		const SET_TX = await storage.setTokenSymbol(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getTokenSymbol(id)
		assert.equal(value, GET_VALUE_BEG, "Int value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteTokenSymbol(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getTokenSymbol(id)
		assert.equal("", GET_VALUE_END, "String value should be deleted from storage.")
	})

	it("Should set, get and delete TLA value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = "0x166a8e28b4afdb04d6ce602644452c71e9f5f885"; // test account
		const value = "test TLA"
		const SET_TX = await storage.setTokenTLA(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getTokenTLA(id)
		assert.equal(value, GET_VALUE_BEG, "Int value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteTokenTLA(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getTokenTLA(id)
		assert.equal("", GET_VALUE_END, "String value should be deleted from storage.")
	})

	it("Should set, get and delete token version value", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = "0x166a8e28b4afdb04d6ce602644452c71e9f5f885"; // test account
		const value = "test Token version"
		const SET_TX = await storage.setTokenVersion(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getTokenVersion(id)
		assert.equal(value, GET_VALUE_BEG, "Int value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteTokenVersion(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getTokenVersion(id)
		assert.equal("", GET_VALUE_END, "String value should be deleted from storage.")
	})

	it("Should set, get and delete token fee contract", async () => {
		const storage = await TokenIOStorage.deployed()
		const id = "0x166a8e28b4afdb04d6ce602644452c71e9f5f885"; // test account
		const value = "0x3fd181cf0594b266ee8187e1dad94de229c98192"
		const SET_TX = await storage.setTokenFeeContract(id, value)
		assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_BEG = await storage.getTokenFeeContract(id)
		assert.equal(value, GET_VALUE_BEG, "Int value should be the same value retrieved from storage.")

		const DELETE_TX = await storage.deleteTokenFeeContract(id)
		assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const GET_VALUE_END = await storage.getTokenFeeContract(id)
		assert.equal("0x0000000000000000000000000000000000000000", GET_VALUE_END, "String value should be deleted from storage.")
	})

	it("Should not allow an unauthorized account to set or delete a storage value", async () => {
		try {
			const storage = await TokenIOStorage.deployed()
			const id = utils.solidityKeccak256(['string'], ['int256'])
			const value = -100
			const SET_TX = await storage.setInt(id, value, { from: TEST_ACCOUNT_2 })
			assert.equal(SET_TX['receipt']['status'], "0x1", "Transaction should succeed.")

			const GET_VALUE_BEG = +(await storage.getInt(id)).toString()
			assert.equal(value, GET_VALUE_BEG, "Int value should be the same value retrieved from storage.")

			const DELETE_TX = await storage.deleteInt(id, { from: TEST_ACCOUNT_2 })
			assert.equal(DELETE_TX['receipt']['status'], "0x1", "Transaction should succeed.")

			const GET_VALUE_END = +(await storage.getInt(id)).toString()
			assert.equal(0, GET_VALUE_END, "Int value should be deleted from storage.")
		} catch (error) {
			assert.equal(error.message.match(RegExp('revert')).length, 1, "Expect transaction to revert due unauthorized account");
		}
	})


})
