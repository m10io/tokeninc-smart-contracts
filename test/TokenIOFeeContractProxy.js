var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOERC20Proxy = artifacts.require("./TokenIOERC20Proxy.sol");
var TokenIOFeeContractProxy = artifacts.require("./TokenIOFeeContractProxy.sol");
var TokenIOCurrencyAuthorityProxy = artifacts.require("./TokenIOCurrencyAuthorityProxy.sol");

const { mode, development, production } = require('../token.config.js');

const {
  AUTHORITY_DETAILS: { firmName, authorityAddress },
  TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS['USDx']


contract("TokenIOFeeContractProxy", function(accounts) {

	const TEST_ACCOUNT_1 = accounts[0]
	const TEST_ACCOUNT_2 = accounts[1]
	const TEST_ACCOUNT_3 = accounts[2]
	const DEPOSIT_AMOUNT = 10000e2 // 1 million USD; 2 decimal representation
	const TRANSFER_AMOUNT = DEPOSIT_AMOUNT/4
	const SPENDING_LIMIT = DEPOSIT_AMOUNT

	const TOKEN_NAME = USDx.tokenName;
    const TOKEN_SYMBOL = USDx.tokenSymbol
    const TOKEN_TLA = USDx.tokenTLA
    const TOKEN_VERSION = USDx.tokenVersion
    const TOKEN_DECIMALS = USDx.tokenDecimals

	before(async function () {
      this.tokenIOERC20Proxy = await TokenIOERC20Proxy.deployed();
      this.tokenIOFeeContractProxy = await TokenIOFeeContractProxy.deployed();
      this.tokenIOCurrencyAuthorityProxy = await TokenIOCurrencyAuthorityProxy.deployed();

      await this.tokenIOERC20Proxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, this.tokenIOFeeContractProxy.address, 0);
    });

	describe('Should transfer an amount of funds and send the fees to the fee contract', function () {
		it("Should pass", async function () {
			const APPROVE_ACCOUNT_1_TX = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_1, true, SPENDING_LIMIT, "Token, Inc.")
			const APPROVE_ACCOUNT_2_TX = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_2, true, SPENDING_LIMIT, "Token, Inc.")
			const APPROVE_ACCOUNT_3_TX = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_3, true, SPENDING_LIMIT, "Token, Inc.")

			assert.equal(APPROVE_ACCOUNT_1_TX['receipt']['status'], "0x1", "Transaction should succeed.")
			assert.equal(APPROVE_ACCOUNT_2_TX['receipt']['status'], "0x1", "Transaction should succeed.")

			const DEPOSIT_TX = await this.tokenIOCurrencyAuthorityProxy.deposit('USDx', TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")
			assert.equal(DEPOSIT_TX['receipt']['status'], "0x1", "Transaction should succeed.")

			const TRANSFER_TX = await this.tokenIOERC20Proxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT)
			assert.equal(TRANSFER_TX['receipt']['status'], "0x1", "Transaction should succeed.")

			const FEE_CONTRACT_BALANCE = +(await this.tokenIOERC20Proxy.balanceOf(this.tokenIOFeeContractProxy.address)).toString();
			const TX_FEES = +(await this.tokenIOERC20Proxy.calculateFees(TRANSFER_AMOUNT)).toString()
			assert.equal(FEE_CONTRACT_BALANCE, TX_FEES, "Fee contract should have a balance equal to the transaction fees")

		})
	});

	describe('Should allow the fee contract to transfer an amount of tokens', function () {
		it("Should pass", async function () {
			const TEST_ACCOUNT_3_BALANCE_BEG = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_3)).toString()
			assert.equal(0, TEST_ACCOUNT_3_BALANCE_BEG, "TEST_ACCOUNT_3 should have a starting balance of zero.")

			const FEE_BALANCE = +(await this.tokenIOFeeContractProxy.getTokenBalance('USDx')).toString()
			const TRANSFER_COLLECTED_FEES_TX = await this.tokenIOFeeContractProxy.transferCollectedFees('USDx', TEST_ACCOUNT_3, FEE_BALANCE, "0x")

			assert.equal(TRANSFER_COLLECTED_FEES_TX['receipt']['status'], "0x1", "Transaction should succeed.")

			const TEST_ACCOUNT_3_BALANCE_END = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_3)).toString()
			assert.equal(FEE_BALANCE, TEST_ACCOUNT_3_BALANCE_END, "TEST_ACCOUNT_3 should have successfully received the amount of the fee balance.")

		})
	})

	describe('staticCall', function () {
      it('Should pass', async function () {
        const payload = web3.eth.abi.encodeFunctionSignature('name()')
        const encodedResult = await this.tokenIOERC20Proxy.staticCall(payload);
        const result = web3.eth.abi.decodeParameters(['string'], encodedResult);
        assert.equal(result[0], TOKEN_NAME)
      });
    });

    describe('call', function () {
      it('Should pass', async function () {
      	await this.tokenIOERC20Proxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT)
      	const FEE_BALANCE = +(await this.tokenIOFeeContractProxy.getTokenBalance('USDx')).toString()
        const payload = web3.eth.abi.encodeFunctionCall({
            name: 'transferCollectedFees',
            type: 'function',
            inputs: [{
                type: 'string',
                name: 'currency'
            },{
                type: 'address',
                name: 'to'
            },{
                type: 'uint256',
                name: 'amount'
            },{
                type: 'bytes',
                name: 'data'
            }]
        }, ['USDx', TEST_ACCOUNT_3, FEE_BALANCE, "0x"]);

        await this.tokenIOFeeContractProxy.call(payload);
      });
    });

    describe('Deprecate interface', function () {
       it('Should pass', async function () {
        const APPROVE_ACCOUNT_1_TX = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_1, true, SPENDING_LIMIT, "Token, Inc.")
        const APPROVE_ACCOUNT_2_TX = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_2, true, SPENDING_LIMIT, "Token, Inc.")
        const APPROVE_ACCOUNT_3_TX = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_3, true, SPENDING_LIMIT, "Token, Inc.")

        assert.equal(APPROVE_ACCOUNT_1_TX['receipt']['status'], "0x1", "Transaction should succeed.")
        assert.equal(APPROVE_ACCOUNT_2_TX['receipt']['status'], "0x1", "Transaction should succeed.")

        const DEPOSIT_TX = await this.tokenIOCurrencyAuthorityProxy.deposit('USDx', TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")
        assert.equal(DEPOSIT_TX['receipt']['status'], "0x1", "Transaction should succeed.")

        await this.tokenIOERC20Proxy.deprecateInterface();

        try {
            const { receipt: { status } } = await this.tokenIOERC20Proxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT);
        } catch (error) {
            assert.equal(error.message.match(RegExp('revert')).length, 1, "Expected interface is not deprecated");
        }
      });
   });

})
