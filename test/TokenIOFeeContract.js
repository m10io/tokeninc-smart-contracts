var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOFeeContract = artifacts.require("./TokenIOFeeContract.sol");
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");
var TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");

const { mode, development, production } = require('../token.config.js');

const {
  AUTHORITY_DETAILS: { firmName, authorityAddress },
  TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS[0]


contract("TokenIOFeeContract", function(accounts) {

	const TEST_ACCOUNT_1 = accounts[0]
	const TEST_ACCOUNT_2 = accounts[1]
	const DEPOSIT_AMOUNT = 2e8 // 1 million USD; 2 decimal representation
	const TRANSFER_AMOUNT = 1e8

	it("Should transfer an amount of funds and send the fees to the fee contract", async () => {
		const CA = await TokenIOCurrencyAuthority.deployed()
		const token = await TokenIOERC20.deployed()
		const feeContract = await TokenIOFeeContract.deployed()

		const APPROVE_ACCOUNT_1_TX = await CA.approveKYC(TEST_ACCOUNT_1, true, "Token, Inc.")
		const APPROVE_ACCOUNT_2_TX = await CA.approveKYC(TEST_ACCOUNT_2, true, "Token, Inc.")

		assert.equal(APPROVE_ACCOUNT_1_TX['receipt']['status'], "0x1", "Transaction should succeed.")
		assert.equal(APPROVE_ACCOUNT_2_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const DEPOSIT_TX = await CA.deposit('USDx', TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")
		assert.equal(DEPOSIT_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const TRANSFER_TX = await token.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT)
		assert.equal(TRANSFER_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const FEE_CONTRACT_BALANCE = +(await token.balanceOf(feeContract.address)).toString();
		const TX_FEES = +(await token.calculateFees(TRANSFER_AMOUNT)).toString()
		assert.equal(FEE_CONTRACT_BALANCE, TX_FEES, "Fee contract should have a balance equal to the transaction fees")


	})




})
