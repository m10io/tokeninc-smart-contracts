var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOFeeContractProxy = artifacts.require("./TokenIOFeeContractProxy.sol");
var TokenIOMerchantProxy = artifacts.require("./TokenIOMerchantProxy.sol");
var TokenIOERC20Proxy = artifacts.require("./TokenIOERC20Proxy.sol");
var TokenIOCurrencyAuthorityProxy = artifacts.require("./TokenIOCurrencyAuthorityProxy.sol");

const { mode, development, production } = require('../token.config.js');

const {
  AUTHORITY_DETAILS: { firmName, authorityAddress },
  TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS['USDx']


contract("TokenIOMerchantProxy", function(accounts) {

	const TEST_ACCOUNT_1 = accounts[0]
	const TEST_ACCOUNT_2 = accounts[1]
	const MERCHANT_ACCOUNT = TEST_ACCOUNT_2
	const TEST_ACCOUNT_3 = accounts[2]
	const DEPOSIT_AMOUNT = 10000e2 // 1 million USD; 2 decimal representation
	const TRANSFER_AMOUNT = DEPOSIT_AMOUNT/4
  	const SPENDING_LIMIT = DEPOSIT_AMOUNT/2
	const MERCHANT_PAYS_FEES = true;

	const TOKEN_NAME = USDx.tokenName
    const TOKEN_SYMBOL = USDx.tokenSymbol
    const TOKEN_TLA = USDx.tokenTLA
    const TOKEN_VERSION = USDx.tokenVersion
    const TOKEN_DECIMALS = USDx.tokenDecimals

	it("Should transfer an amount of funds to merchant and send the fees to the fee contract", async () => {
		const CAProxy = await TokenIOCurrencyAuthorityProxy.deployed()
		const merchantProxy = await TokenIOMerchantProxy.deployed()
		const tokenProxy = await TokenIOERC20Proxy.deployed()
		const feeContractProxy = await TokenIOFeeContractProxy.deployed();

      	await merchantProxy.setParams(feeContractProxy.address)
		await tokenProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, feeContractProxy.address, 10000);

		const APPROVE_ACCOUNT_1_TX = await CAProxy.approveKYC(TEST_ACCOUNT_1, true, SPENDING_LIMIT, "Token, Inc.")
		const APPROVE_ACCOUNT_2_TX = await CAProxy.approveKYC(TEST_ACCOUNT_2, true, SPENDING_LIMIT, "Token, Inc.")
		const APPROVE_ACCOUNT_3_TX = await CAProxy.approveKYC(TEST_ACCOUNT_3, true, SPENDING_LIMIT, "Token, Inc.")

		assert.equal(APPROVE_ACCOUNT_1_TX['receipt']['status'], "0x1", "Transaction should succeed.")
		assert.equal(APPROVE_ACCOUNT_2_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const DEPOSIT_TX = await CAProxy.deposit(TOKEN_SYMBOL, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")
		assert.equal(DEPOSIT_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const TRANSFER_TX = await merchantProxy.pay(TOKEN_SYMBOL, MERCHANT_ACCOUNT, TRANSFER_AMOUNT, MERCHANT_PAYS_FEES, "0x0")
		assert.equal(TRANSFER_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const FEE_CONTRACT_BALANCE = +(await tokenProxy.balanceOf(feeContractProxy.address)).toString();
		const TX_FEES = +(await merchantProxy.calculateFees(TRANSFER_AMOUNT)).toString()
		assert.equal(FEE_CONTRACT_BALANCE, TX_FEES, "Fee contract should have a balance equal to the transaction fees")

		const MERCHANT_ACCOUNT_BALANCE = +(await tokenProxy.balanceOf(MERCHANT_ACCOUNT)).toString();
		assert.equal(MERCHANT_ACCOUNT_BALANCE, (TRANSFER_AMOUNT-TX_FEES), "Merchant account should have a balance equal to the transaction amount minus fees")

	})

	it("Should allow the fee contract to transfer an amount of tokens", async () => {
		const tokenProxy = await TokenIOERC20Proxy.deployed()
		const feeContractProxy = await TokenIOFeeContractProxy.deployed()

		await tokenProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, feeContractProxy.address, 10000);

		const TEST_ACCOUNT_3_BALANCE_BEG = +(await tokenProxy.balanceOf(TEST_ACCOUNT_3)).toString()
		assert.equal(0, TEST_ACCOUNT_3_BALANCE_BEG, "TEST_ACCOUNT_3 should have a starting balance of zero.")

		const FEE_BALANCE = +(await feeContractProxy.getTokenBalance(TOKEN_SYMBOL)).toString()
		const TRANSFER_COLLECTED_FEES_TX = await feeContractProxy.transferCollectedFees(TOKEN_SYMBOL, TEST_ACCOUNT_3, FEE_BALANCE, "0x")

		assert.equal(TRANSFER_COLLECTED_FEES_TX['receipt']['status'], "0x1", "Transaction should succeed.")

		const TEST_ACCOUNT_3_BALANCE_END = +(await tokenProxy.balanceOf(TEST_ACCOUNT_3)).toString()
		assert.equal(FEE_BALANCE, TEST_ACCOUNT_3_BALANCE_END, "TEST_ACCOUNT_3 should have successfully received the amount of the fee balance.")

	})

	describe('staticCall', function () {
      it('Should pass', async function () {
      	const merchantProxy = await TokenIOMerchantProxy.deployed()
        const payload = web3.eth.abi.encodeFunctionCall({
            name: 'calculateFees',
            type: 'function',
            inputs: [{
                type: 'uint256',
                name: 'amount'
            }]
        }, [TRANSFER_AMOUNT]);
        const encodedResult = await merchantProxy.staticCall(payload);
        const result = web3.eth.abi.decodeParameters(['uint256'], encodedResult);
        assert.equal(result[0] > 0, true)
      });
    });

    describe('call', function () {
      it('Should pass', async function () {
      	const merchantProxy = await TokenIOMerchantProxy.deployed()
        const payload = web3.eth.abi.encodeFunctionCall({
            name: 'pay',
            type: 'function',
            inputs: [{
                type: 'string',
                name: 'currency'
            },{
                type: 'address',
                name: 'merchant'
            },{
                type: 'uint256',
                name: 'amount'
            },{
            	type: 'bool',
            	name: 'merchantPaysFees'
            },{
                type: 'bytes',
                name: 'data'
            },{
                type: 'address',
                name: 'sender'
            }]
        }, [TOKEN_SYMBOL, MERCHANT_ACCOUNT, TRANSFER_AMOUNT, MERCHANT_PAYS_FEES, "0x0", TEST_ACCOUNT_1]);

        await merchantProxy.call(payload);
      });
    });



})
