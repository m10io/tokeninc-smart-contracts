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

const USDx = TOKEN_DETAILS['USDx']


contract("TokenIOFeeContract", function(accounts) {

	const TEST_ACCOUNT_1 = accounts[0]
	const TEST_ACCOUNT_2 = accounts[1]
	const TEST_ACCOUNT_3 = accounts[2]
	const DEPOSIT_AMOUNT = 10000e2 // 1 million USD; 2 decimal representation
	const TRANSFER_AMOUNT = DEPOSIT_AMOUNT/4
    const SPENDING_LIMIT = DEPOSIT_AMOUNT/2
    
	it("Should transfer an amount of funds and send the fees to the fee contract", async () => {
		const CA = await TokenIOCurrencyAuthority.deployed()
		const token = await TokenIOERC20.deployed()
		const feeContract = await TokenIOFeeContract.deployed()

		const APPROVE_ACCOUNT_1_TX = await CA.approveKYC(TEST_ACCOUNT_1, true, SPENDING_LIMIT, "Token, Inc.")
		const APPROVE_ACCOUNT_2_TX = await CA.approveKYC(TEST_ACCOUNT_2, true, SPENDING_LIMIT, "Token, Inc.")
		const APPROVE_ACCOUNT_3_TX = await CA.approveKYC(TEST_ACCOUNT_3, true, SPENDING_LIMIT, "Token, Inc.")

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

	it("Should allow the fee contract to transfer an amount of tokens", async () => {
		const feeContract = await TokenIOFeeContract.deployed()
		const token = await TokenIOERC20.deployed()

		const TEST_ACCOUNT_3_BALANCE_BEG = +(await token.balanceOf(TEST_ACCOUNT_3)).toString()
		assert.equal(0, TEST_ACCOUNT_3_BALANCE_BEG, "TEST_ACCOUNT_3 should have a starting balance of zero.")

		const FEE_BALANCE = +(await feeContract.getTokenBalance('USDx')).toString()
		const TRANSFER_COLLECTED_FEES_TX = await feeContract.transferCollectedFees('USDx', TEST_ACCOUNT_3, FEE_BALANCE, "0x")

		assert.equal(TRANSFER_COLLECTED_FEES_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const TEST_ACCOUNT_3_BALANCE_END = +(await token.balanceOf(TEST_ACCOUNT_3)).toString()
		assert.equal(FEE_BALANCE, TEST_ACCOUNT_3_BALANCE_END, "TEST_ACCOUNT_3 should have successfully received the amount of the fee balance.")

	})




})
