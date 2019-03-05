const TokenIOCurrencyAuthorityProxy = artifacts.require("./TokenIOCurrencyAuthorityProxy.sol");
const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20FeesApplyProxy = artifacts.require("./TokenIOERC20FeesApplyProxy.sol")
const { mode, development, production } = require('../token.config.js')

const { AUTHORITY_DETAILS: { firmName, authorityAddress }, TOKEN_DETAILS, FEE_PARAMS } = mode
    == 'production' ? production : development //set stage

contract("TokenIOERC20FeesApplyProxy", function(accounts) {
    // pull in usdx params
    const USDx = TOKEN_DETAILS['USDx']

    // create test accounts
    const TEST_ACCOUNT_1 = accounts[0]
    const TEST_ACCOUNT_2 = accounts[1]
    const TEST_ACCOUNT_3 = accounts[2]

    const DEPOSIT_AMOUNT = 10000e2
    const LIMIT_AMOUNT = (DEPOSIT_AMOUNT/2)
    const TRANSFER_AMOUNT = (DEPOSIT_AMOUNT/4)

    const TOKEN_NAME = USDx.tokenName;
    const TOKEN_SYMBOL = USDx.tokenSymbol
    const TOKEN_TLA = USDx.tokenTLA
    const TOKEN_VERSION = USDx.tokenVersion
    const FEE_CONTRACT = USDx.feeContract
    const TOKEN_DECIMALS = USDx.tokenDecimals

    before(async function () {
      this.tokenIOStorage = await TokenIOStorage.deployed()
      this.tokenIOCurrencyAuthorityProxy = await TokenIOCurrencyAuthorityProxy.deployed();
      this.tokenIOERC20FeesApplyProxy = await TokenIOERC20FeesApplyProxy.deployed();
    });

    /* PARAMETERS */
    describe('TOKEN_PARAMS:should correctly set parameters according to token.config.js [name, symbol, tla, decimals]', function () {
      it(`should pass`, async function () {
        assert.equal(await this.tokenIOERC20FeesApplyProxy.name(), TOKEN_NAME, "Token name should be set in the storage contract.")
        assert.equal(await this.tokenIOERC20FeesApplyProxy.symbol(), TOKEN_SYMBOL, "Token symbol should be set in the storage contract.")
        assert.equal(await this.tokenIOERC20FeesApplyProxy.tla(), TOKEN_TLA, "Token tla should be set in the storage contract.")
        assert.equal(await this.tokenIOERC20FeesApplyProxy.version(), TOKEN_VERSION, "Token version should be set in the storage contract.")
        assert.equal(await this.tokenIOERC20FeesApplyProxy.decimals(), TOKEN_DECIMALS, "Token decimals should be set in the storage contract.")
      })
    });

    describe('TRANSFER:should supply uints, debiting the sender and crediting the receiver', function () {
      it('Should pass', async function () {
        await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_1, true, LIMIT_AMOUNT, "Token, Inc.")
        await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_2, true, LIMIT_AMOUNT, "Token, Inc.")
        await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_3, true, LIMIT_AMOUNT, "Token, Inc.")
        await this.tokenIOCurrencyAuthorityProxy.deposit(await this.tokenIOERC20FeesApplyProxy.symbol(), TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.");

        const balance1 = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const balance2 = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString()

        assert.equal(balance1, DEPOSIT_AMOUNT, "first account should contain all the deposit initially")
        assert.equal(balance2, 0, "Second account should have zero balance")

        const transferReceipt = await this.tokenIOERC20FeesApplyProxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT)

        const balance1b = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const balance2b = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString()

        // calc fees
        const TX_FEES = +(await this.tokenIOERC20FeesApplyProxy.calculateFees(TRANSFER_AMOUNT)).toString()

        // check spending limit remaining
        // Spending limit should remain unchanged!
        const SPENDING_LIMIT = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingLimit(TEST_ACCOUNT_1)).toString()
        const SPENDING_REMAINING = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()

        assert.equal(SPENDING_REMAINING, (SPENDING_LIMIT),
            "Remaining spending amount should remain equal to set limit amount")

        // calculate correct current balance
        assert.equal(balance1b, (DEPOSIT_AMOUNT-TRANSFER_AMOUNT-TX_FEES))
        assert.equal(balance2b, TRANSFER_AMOUNT)
      });
    });

    describe('APPROVE: should give allowance of remaining balance of account 1 to account 2', function () {
      it('Should pass', async function () {
        const balance1a = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1))

        const approveReceipt = await this.tokenIOERC20FeesApplyProxy.approve(TEST_ACCOUNT_2, balance1a)
        const allowance = +(await this.tokenIOERC20FeesApplyProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()

        assert.notEqual(allowance, 0, "Allowance should not equal zero.")
        assert.equal(allowance, balance1a, "Allowance should be the same value as the balance of account 1")
      });
    });

    describe('TRANSFER_FROM: account 2 should spend funds transfering from account1 to account 3  on behalf of account1', function () {
      it('Should pass', async function () {

        const TEST_ACT_1_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const TEST_ACT_2_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString()
        const TEST_ACT_3_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_3)).toString()

        assert.notEqual(TEST_ACT_1_BEG_BALANCE, 0, "Balance of account 1 should not equal zero.")
        assert.notEqual(TEST_ACT_2_BEG_BALANCE, 0, "Balance of account 2 should not equal zero.")

        const BEG_ALLOWANCE = await this.tokenIOERC20FeesApplyProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)

        assert.equal(BEG_ALLOWANCE, TEST_ACT_1_BEG_BALANCE)

        const TRANSFER_FROM_AMOUNT = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()
        const transferFromReceipt = await this.tokenIOERC20FeesApplyProxy.transferFrom(TEST_ACCOUNT_1, TEST_ACCOUNT_3, TRANSFER_FROM_AMOUNT, { from: TEST_ACCOUNT_2 })
        const TX_FEES = +(await this.tokenIOERC20FeesApplyProxy.calculateFees(TRANSFER_FROM_AMOUNT)).toString()
        
        const TEST_ACT_1_END_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1))
        assert.equal(TEST_ACT_1_END_BALANCE, (TEST_ACT_1_BEG_BALANCE-TRANSFER_FROM_AMOUNT-TX_FEES), "Ending balance should be net of transfer amount and fees")

        const TEST_ACT_3_END_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_3)).toString()
        assert.equal(TEST_ACT_3_END_BALANCE, TRANSFER_FROM_AMOUNT, "TEST_ACCOUNT_3 Balance should equal transfer amount");

        const END_ALLOWANCE = +(await this.tokenIOERC20FeesApplyProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()
        assert.equal(END_ALLOWANCE, (TEST_ACT_1_BEG_BALANCE-TRANSFER_FROM_AMOUNT-TX_FEES), "Allowance should be reduced by amount transferred")
      });
    });

    describe('calculateFees', function () {
      it('Should pass', async function () {
        const TX_FEES = +(await this.tokenIOERC20FeesApplyProxy.calculateFees(TRANSFER_AMOUNT)).toString()
        assert.notEqual(TX_FEES, 0, "TX fee should not equal zero.")
      });
    });

    describe('BALANCE_OF: should get balance of account1', function () {
      it('Should pass', async function () {
        const TEST_ACT_1_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const TEST_ACT_2_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString()
        const TEST_ACT_3_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_3)).toString()

        const balance = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString()
        assert.equal(balance, TRANSFER_AMOUNT, "first account should contain all the deposit initially")
      });
    });

    describe('ALLOWANCE: should return allowance of account2 on behalf of account 1', function () {
      it('Should pass', async function () {
        const allowance = await this.tokenIOERC20FeesApplyProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
        assert.equal(allowance.toNumber(), 249848)
      });
    });

    describe('staticCall', function () {
      it('Should pass', async function () {
        const payload = web3.eth.abi.encodeFunctionSignature('name()')
        const encodedResult = await this.tokenIOERC20FeesApplyProxy.staticCall(payload);
        const result = web3.eth.abi.decodeParameters(['string'], encodedResult);
        assert.equal(result[0], TOKEN_NAME)
      });
    });

    describe('call', function () {
      it('Should pass', async function () {
        const TEST_ACT_1_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const TEST_ACT_2_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString()

        const payload = web3.eth.abi.encodeFunctionCall({
            name: 'transfer',
            type: 'function',
            inputs: [{
                type: 'address',
                name: 'to'
            },{
                type: 'uint256',
                name: 'amount'
            },{
                type: 'address',
                name: 'sender'
            }]
        }, [TEST_ACCOUNT_2, 1, TEST_ACCOUNT_1]);

        await this.tokenIOERC20FeesApplyProxy.call(payload);
        const TX_FEES = +(await this.tokenIOERC20FeesApplyProxy.calculateFees(1)).toString()
        assert.equal(+(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1)).toString(), TEST_ACT_1_BEG_BALANCE - 1 - TX_FEES)
        assert.equal(+(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString(), TEST_ACT_2_BEG_BALANCE + 1)
      });
    });

})