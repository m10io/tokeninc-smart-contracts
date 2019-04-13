const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOCurrencyAuthorityProxy = artifacts.require("./TokenIOCurrencyAuthorityProxy.sol");
const TokenIOERC20Proxy = artifacts.require("./TokenIOERC20Proxy.sol")
const TokenIOFeeContractProxy = artifacts.require("./TokenIOFeeContractProxy.sol")
const { mode, development, production } = require('../token.config.js')
const { utils } = require('ethers')

const { AUTHORITY_DETAILS: { firmName, authorityAddress }, TOKEN_DETAILS, FEE_PARAMS } = mode
    == 'production' ? production : development //set stage

contract("TokenIOERC20Proxy", function(accounts) {
    // pull in usdx params
    const USDx = TOKEN_DETAILS['USDx']

    // create test accounts
    const TEST_ACCOUNT_1 = accounts[0]
    const TEST_ACCOUNT_2 = accounts[1]
    const TEST_ACCOUNT_3 = accounts[2]

    const DEPOSIT_AMOUNT = 10000e2
    const LIMIT_AMOUNT = (DEPOSIT_AMOUNT/2)
    const TRANSFER_AMOUNT = (DEPOSIT_AMOUNT/4)

    const TOKEN_NAME = USDx.tokenName
    const TOKEN_SYMBOL = USDx.tokenSymbol
    const TOKEN_TLA = USDx.tokenTLA
    const TOKEN_VERSION = USDx.tokenVersion
    const TOKEN_DECIMALS = USDx.tokenDecimals

    const TOKEN_FEE_BPS = FEE_PARAMS.feeBps
    const TOKEN_FEE_MIN = FEE_PARAMS.feeMin
    const TOKEN_FEE_MAX = FEE_PARAMS.feeMax
    const TOKEN_FEE_FLAT = FEE_PARAMS.feeFlat
    const TOKEN_FEE_MSG = FEE_PARAMS.feeMsg

    before(async function () {
      this.tokenIOERC20Proxy = await TokenIOERC20Proxy.deployed();
      this.tokenIOFeeContractProxy = await TokenIOFeeContractProxy.deployed();
      this.tokenIOStorage = await TokenIOStorage.deployed();
      this.tokenIOCurrencyAuthorityProxy = await TokenIOCurrencyAuthorityProxy.deployed();
    });

    /* PARAMETERS */

    describe("TOKEN_PARAMS: should correctly set parameters according to c 'token.config.js' [name, symbol, tla, decimals]", function () {
      it("Should pass", async function () {

        const name = await this.tokenIOERC20Proxy.name()
        const symbol = await this.tokenIOERC20Proxy.symbol()
        const tla = await this.tokenIOERC20Proxy.tla()
        const version = await this.tokenIOERC20Proxy.version()
        const decimals = await this.tokenIOERC20Proxy.decimals()

        assert.equal(name, TOKEN_NAME, "Token name should be set in the storage contract.")
        assert.equal(symbol, TOKEN_SYMBOL, "Token symbol should be set in the storage contract.")
        assert.equal(tla, TOKEN_TLA, "Token tla should be set in the storage contract.")
        assert.equal(version, TOKEN_VERSION, "Token version should be set in the storage contract.")
        assert.equal(decimals, TOKEN_DECIMALS, "Token decimals should be set in the storage contract.")
      })
    })

    describe("FEE_PARAMS: should correctly set fee parameters according to config file 'token.config.js' [bps, min, max, flat, account]", function () {
      it("Should pass", async function () {
        const TOKEN_FEE_ACCOUNT = this.tokenIOFeeContractProxy.address

        const feeParams = await this.tokenIOERC20Proxy.getFeeParams()
        const feeBps = feeParams[0]
        const feeMin = feeParams[1]
        const feeMax = feeParams[2]
        const feeFlat = feeParams[3]
        const feeMsg = feeParams[4]
        const feeAccount = feeParams[5]

        assert.equal(feeBps, TOKEN_FEE_BPS, "Token feeBps should be set in the storage contract.")
        assert.equal(feeMin, TOKEN_FEE_MIN, "Token feeMin should be set in the storage contract.")
        assert.equal(feeMax, TOKEN_FEE_MAX, "Token feeMax should be set in the storage contract.")
        assert.equal(feeFlat, TOKEN_FEE_FLAT, "Token feeFlat should be set in the storage contract.")
        assert.equal(feeMsg, TOKEN_FEE_MSG, "Token feeMsg should be set in the storage contract.")
        assert.equal(feeAccount, TOKEN_FEE_ACCOUNT, "Token feeAccount should be set in the storage contract.")
      })
    })

    /* GETTERS */

    describe("BALANCE_OF: should get balance of account1", function () {
      it("Should pass", async function () {
        const balance = await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_1)
        assert.equal(balance, 0)
      })
    })

    describe("ALLOWANCE: should return allowance of account2 on behalf of account 1", function () {
      it("Should pass", async function () {
          const allowance = await this.tokenIOERC20Proxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
          assert.equal(allowance, 0)
      })
    })

    /* PUBLIC FUNCTIONS */
    describe("TRANSFER: should supply uints, debiting the sender and crediting the receiver", function () {
      it("Should pass", async function () {
        const kycReceipt1 = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_1, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt2= await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_2, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt3= await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_3, true, LIMIT_AMOUNT, "Token, Inc.")

        await this.tokenIOStorage.allowOwnership(this.tokenIOERC20Proxy.address)
        const tokenSymbol = await this.tokenIOERC20Proxy.symbol()
        const depositReceipt = await this.tokenIOCurrencyAuthorityProxy.deposit(tokenSymbol, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")

        const balance1 = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const balance2 = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_2)).toString()

        assert.equal(balance1, DEPOSIT_AMOUNT)
        assert.equal(balance2, 0)

        const transferReceipt = await this.tokenIOERC20Proxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT)
        const balance1b = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const balance2b = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_2)).toString()

        // calc fees
        const TX_FEES = +(await this.tokenIOERC20Proxy.calculateFees(TRANSFER_AMOUNT)).toString()

        // check spending limit remaining
        const SPENDING_LIMIT = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingLimit(TEST_ACCOUNT_1)).toString()
        const SPENDING_REMAINING = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()

        assert.equal(SPENDING_REMAINING, (SPENDING_LIMIT - TRANSFER_AMOUNT),
            "Remaining spending amount should equal the spending limit minus the transfer amount")

        // calculate correct current balance
        assert.equal(balance1b, (DEPOSIT_AMOUNT-TRANSFER_AMOUNT-TX_FEES))
        assert.equal(balance2b, TRANSFER_AMOUNT)
      })
    })

    describe("APPROVE:should give allowance of remaining balance of account 1 to account 2 allowances[account1][account2]: 0 --> 100", function () {
      it("Should pass", async function () {
        const balance1a = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_1))
        const balance1b = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_2))

        const approveReceipt = await this.tokenIOERC20Proxy.approve(TEST_ACCOUNT_2, balance1a)
        const allowance = +(await this.tokenIOERC20Proxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()

        assert.notEqual(allowance, 0, "Allowance should not equal zero.")
        assert.equal(allowance, balance1a, "Allowance should be the same value as the balance of account 1")
      })
    })

    describe("TRANSFER_FROM: account 2 should spend funds transfering from account1 to account 3  on behalf of account1", function () {
      it("Should pass", async function () {
        const TEST_ACT_1_BEG_BALANCE = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const TEST_ACT_2_BEG_BALANCE = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_2)).toString()
        const TEST_ACT_3_BEG_BALANCE = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_3)).toString()

        assert.notEqual(TEST_ACT_1_BEG_BALANCE, 0, "Balance of account 1 should not equal zero.")
        assert.notEqual(TEST_ACT_2_BEG_BALANCE, 0, "Balance of account 2 should not equal zero.")

        const BEG_ALLOWANCE = await this.tokenIOERC20Proxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
        assert.equal(BEG_ALLOWANCE, TEST_ACT_1_BEG_BALANCE)

        const TRANSFER_FROM_AMOUNT = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()
        const transferFromReceipt = await this.tokenIOERC20Proxy.transferFrom(TEST_ACCOUNT_1, TEST_ACCOUNT_3, TRANSFER_FROM_AMOUNT, { from: TEST_ACCOUNT_2 })

        const TX_FEES = +(await this.tokenIOERC20Proxy.calculateFees(TRANSFER_FROM_AMOUNT)).toString()
        const TEST_ACT_1_END_BALANCE = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_1))
        assert.equal(TEST_ACT_1_END_BALANCE, (TEST_ACT_1_BEG_BALANCE-TRANSFER_FROM_AMOUNT-TX_FEES), "Ending balance should be net of transfer amount and fees")

        const TEST_ACT_3_END_BALANCE = +(await this.tokenIOERC20Proxy.balanceOf(TEST_ACCOUNT_3)).toString()
        assert.equal(TEST_ACT_3_END_BALANCE, TRANSFER_FROM_AMOUNT, "TEST_ACCOUNT_3 Balance should equal transfer amount");

        const END_ALLOWANCE = +(await this.tokenIOERC20Proxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()
        assert.equal(END_ALLOWANCE, (TEST_ACT_1_BEG_BALANCE-TRANSFER_FROM_AMOUNT), "Allowance should be reduced by amount transferred")
      })
    })

    describe("Should attempt to transfer more than the daily limit for the account and fail", function () {
      it("Should pass", async function () {
        const SPENDING_REMAINING = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()
        assert.equal(0, SPENDING_REMAINING, "Expect daily spending limit to be zero")

        try {
            const TRANSFER_AMOUNT = 100e2
            const TRANSFER_TX = await this.tokenIOERC20Proxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT)
        } catch (error) {
            assert.equal(error.message.match(RegExp('revert')).length, 1, "Expect transaction to revert due to excessive spending limit");
        }
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
        const tokenSymbol = await this.tokenIOERC20Proxy.symbol()
        const depositReceipt = await this.tokenIOCurrencyAuthorityProxy.deposit(tokenSymbol, TEST_ACCOUNT_3, DEPOSIT_AMOUNT, "Token, Inc.")
        const payload = web3.eth.abi.encodeFunctionCall({
            name: 'approve',
            type: 'function',
            inputs: [{
                type: 'address',
                name: 'spender'
            },{
                type: 'uint256',
                name: 'amount'
            }, {
                type: 'address',
                name: 'sender'
            }]
        }, [TEST_ACCOUNT_2, DEPOSIT_AMOUNT, TEST_ACCOUNT_3]);

        await this.tokenIOERC20Proxy.call(payload, { from: TEST_ACCOUNT_3 });
      });
    });

    describe("Deprecate interface", function () {
      it("Should pass", async function () {
        const kycReceipt1 = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_1, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt2= await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_2, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt3= await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_3, true, LIMIT_AMOUNT, "Token, Inc.")

        await this.tokenIOStorage.allowOwnership(this.tokenIOERC20Proxy.address)
        const tokenSymbol = await this.tokenIOERC20Proxy.symbol()
        const depositReceipt = await this.tokenIOCurrencyAuthorityProxy.deposit(tokenSymbol, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")

        await this.tokenIOERC20Proxy.deprecateInterface();

        try {
           const { receipt: { status } } = await this.tokenIOERC20Proxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT);
        } catch (error) {
           assert.equal(error.message.match(RegExp('revert')).length, 1, "Expected interface is not deprecated");
        }
      })
    })

})
