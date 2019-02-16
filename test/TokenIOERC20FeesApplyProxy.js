const TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");
const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20FeesApply = artifacts.require("./TokenIOERC20FeesApply.sol")
const TokenIOERC20FeesApplyProxy = artifacts.require("./TokenIOERC20FeesApplyProxy.sol")
const TokenIOFeeContract = artifacts.require("./TokenIOFeeContract.sol")
const { mode, development, production } = require('../token.config.js')
const { utils } = require('ethers')

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

    beforeEach(async function () {
      this.tokenIOStorage = await TokenIOStorage.deployed()
      this.tokenIOERC20FeesApply = await TokenIOERC20FeesApply.deployed()
      this.tokenIOCurrencyAuthority = await TokenIOCurrencyAuthority.deployed();
      this.tokenIOERC20FeesApplyProxy = await TokenIOERC20FeesApplyProxy.new(this.tokenIOERC20FeesApply.address);
      await this.tokenIOERC20FeesApply.allowOwnership(this.tokenIOERC20FeesApplyProxy.address);
      await this.tokenIOERC20FeesApply.initProxy(this.tokenIOERC20FeesApplyProxy.address);
    });
    /* PARAMETERS */

    describe('transfer', function () {
      it('Should pass', async function () {
        const kycReceipt1 = await this.tokenIOCurrencyAuthority.approveKYC(TEST_ACCOUNT_1, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt2 = await this.tokenIOCurrencyAuthority.approveKYC(TEST_ACCOUNT_2, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt3 = await this.tokenIOCurrencyAuthority.approveKYC(TEST_ACCOUNT_3, true, LIMIT_AMOUNT, "Token, Inc.")

        await this.tokenIOERC20FeesApplyProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, FEE_CONTRACT, 0);
        const tokenSymbol = await this.tokenIOERC20FeesApplyProxy.symbol()
        assert.equal(tokenSymbol, 'USDx', "Incorrect token symbol")
        const depositReceipt = await this.tokenIOCurrencyAuthority.deposit(tokenSymbol, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")

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
        const SPENDING_LIMIT = +(await this.tokenIOCurrencyAuthority.getAccountSpendingLimit(TEST_ACCOUNT_1)).toString()
        const SPENDING_REMAINING = +(await this.tokenIOCurrencyAuthority.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()

        assert.equal(SPENDING_REMAINING, (SPENDING_LIMIT),
            "Remaining spending amount should remain equal to set limit amount")

        // calculate correct current balance
        console.log("BALANCE: " + balance1b)
        assert.equal(balance1b, (DEPOSIT_AMOUNT-TRANSFER_AMOUNT-TX_FEES))
        assert.equal(balance2b, TRANSFER_AMOUNT)
      });
    });

    describe('approve', function () {
      it('Should pass', async function () {
        const kycReceipt1 = await this.tokenIOCurrencyAuthority.approveKYC(TEST_ACCOUNT_1, true, LIMIT_AMOUNT, "Token, Inc.")
        await this.tokenIOERC20FeesApplyProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, FEE_CONTRACT, 0);
        const tokenSymbol = await this.tokenIOERC20FeesApplyProxy.symbol()
        assert.equal(tokenSymbol, 'USDx', "Incorrect token symbol")
        const depositReceipt = await this.tokenIOCurrencyAuthority.deposit(tokenSymbol, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")

        const balance1a = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1))
        const balance1b = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2))
        console.log(balance1a)

        const approveReceipt = await this.tokenIOERC20FeesApplyProxy.approve(TEST_ACCOUNT_2, balance1a)
        const allowance = +(await this.tokenIOERC20FeesApply.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()

        assert.notEqual(allowance, 0, "Allowance should not equal zero.")
        assert.equal(allowance, balance1a, "Allowance should be the same value as the balance of account 1")
      });
    });

    describe('transferFrom', function () {
      it('Should pass', async function () {
        const TEST_ACT_1_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const TEST_ACT_2_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString()
        const TEST_ACT_3_BEG_BALANCE = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_3)).toString()

        assert.notEqual(TEST_ACT_1_BEG_BALANCE, 0, "Balance of account 1 should not equal zero.")
        assert.notEqual(TEST_ACT_2_BEG_BALANCE, 0, "Balance of account 2 should not equal zero.")

        const BEG_ALLOWANCE = await this.tokenIOERC20FeesApplyProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
        assert.equal(BEG_ALLOWANCE, TEST_ACT_1_BEG_BALANCE)

        const TRANSFER_FROM_AMOUNT = +(await this.tokenIOCurrencyAuthority.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()
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

    describe('balanceOf', function () {
      it('Should pass', async function () {
        const balance = +(await this.tokenIOERC20FeesApplyProxy.balanceOf(TEST_ACCOUNT_2)).toString()
        assert.equal(balance, TRANSFER_AMOUNT, "first account should contain all the deposit initially")
      });
    });

    describe('allowance', function () {
      it('Should pass', async function () {
        const allowance = await this.tokenIOERC20FeesApplyProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
        assert.equal(allowance.toNumber(), 249848)
      });
    });

    describe('setParams', function () {
      it('Should pass', async function () {
        await this.tokenIOERC20FeesApplyProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, FEE_CONTRACT, 0);

        let decimals = await this.tokenIOERC20FeesApplyProxy.decimals();
        assert.equal(decimals, TOKEN_DECIMALS, "Token decimals should be set in the storage contract.")
      });
    });

    describe('name', function () {
      it('Should pass', async function () {
        await this.tokenIOERC20FeesApplyProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, FEE_CONTRACT, 0);

        let name = await this.tokenIOERC20FeesApplyProxy.name();
        assert.equal(name, TOKEN_NAME, "Token name should be set in the storage contract.")
      });
    });

    describe('symbol', function () {
      it('Should pass', async function () {
        await this.tokenIOERC20FeesApplyProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, FEE_CONTRACT, 0);

        let symbol = await this.tokenIOERC20FeesApplyProxy.symbol();
        assert.equal(symbol, TOKEN_SYMBOL, "Token symbol should be set in the storage contract.")
      });
    });

    describe('version', function () {
      it('Should pass', async function () {
        await this.tokenIOERC20FeesApplyProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, FEE_CONTRACT, 0);

        let version = await this.tokenIOERC20FeesApplyProxy.version();
        assert.equal(version, TOKEN_VERSION, "Token version should be set in the storage contract.")
      });
    });

    describe('tla', function () {
      it('Should pass', async function () {
        await this.tokenIOERC20FeesApplyProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, FEE_CONTRACT, 0);

        let tla = await this.tokenIOERC20FeesApplyProxy.tla();
        assert.equal(tla, TOKEN_TLA, "Token tla should be set in the storage contract.")
      });
    });

    describe('Total Supply', function () {
      it('Should pass', async function () {
        let totalSupply = await this.tokenIOERC20FeesApplyProxy.totalSupply();
        assert.equal(totalSupply.toNumber(), DEPOSIT_AMOUNT, "Token name should be set in the storage contract.")
      });
    });

})