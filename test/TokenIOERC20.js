const TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");
const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20 = artifacts.require("./TokenIOERC20.sol")
const TokenIOFeeContract = artifacts.require("./TokenIOFeeContract.sol")
const { mode, development, production } = require('../token.config.js')
const { utils } = require('ethers')

const { AUTHORITY_DETAILS: { firmName, authorityAddress }, TOKEN_DETAILS, FEE_PARAMS } = mode
    == 'production' ? production : development //set stage

contract("TokenIOERC20", function(accounts) {
    // pull in usdx params
    const USDx = TOKEN_DETAILS[0]

    // create test accounts
    const TEST_ACCOUNT_1 = accounts[0]
    const TEST_ACCOUNT_2 = accounts[1]
    const TEST_ACCOUNT_3 = accounts[2]

    const DEPOSIT_AMOUNT = 10000
    const TRANSFER_AMOUNT = (DEPOSIT_AMOUNT/4)

    /* PARAMETERS */

    it(`TOKEN_PARAMS
        :should correctly set parameters according to c 'token.config.js'
        [name, symbol, tla, decimals]`, async () => {
        const TOKEN_NAME = USDx.tokenName;
        const TOKEN_SYMBOL = USDx.tokenSymbol
        const TOKEN_TLA = USDx.tokenTLA
        const TOKEN_VERSION = USDx.tokenVersion
        const TOKEN_DECIMALS = USDx.tokenDecimals


        const erc20 = await TokenIOERC20.deployed()
        const name = await erc20.name()
        const symbol = await erc20.symbol()
        const tla = await erc20.tla()
        const version = await erc20.version()
        const decimals = await erc20.decimals()

        assert.equal(name, TOKEN_NAME, "Token name should be set in the storage contract.")
        assert.equal(symbol, TOKEN_SYMBOL, "Token symbol should be set in the storage contract.")
        assert.equal(tla, TOKEN_TLA, "Token tla should be set in the storage contract.")
        assert.equal(version, TOKEN_VERSION, "Token version should be set in the storage contract.")
        assert.equal(decimals, TOKEN_DECIMALS, "Token decimals should be set in the storage contract.")
    })


    it(`FEE_PARAMS
        :should correctly set fee parameters according to config file 'token.config.js'
        [bps, min, max, flat, account]`, async () => {
        const TOKEN_FEE_BPS = FEE_PARAMS.feeBps
        const TOKEN_FEE_MIN = FEE_PARAMS.feeMin
        const TOKEN_FEE_MAX = FEE_PARAMS.feeMax
        const TOKEN_FEE_FLAT = FEE_PARAMS.feeFlat
        const TOKEN_FEE_ACCOUNT = (await TokenIOFeeContract.deployed()).address

        const erc20 = await TokenIOERC20.deployed()
        const feeParams = await erc20.getFeeParams()
        const feeBps = feeParams[0]
        const feeMin = feeParams[1]
        const feeMax = feeParams[2]
        const feeFlat = feeParams[3]
        const feeAccount = feeParams[4]

        assert.equal(feeBps, TOKEN_FEE_BPS, "Token feeBps should be set in the storage contract.")
        assert.equal(feeMin, TOKEN_FEE_MIN, "Token feeMin should be set in the storage contract.")
        assert.equal(feeMax, TOKEN_FEE_MAX, "Token feeMax should be set in the storage contract.")
        assert.equal(feeFlat, TOKEN_FEE_FLAT, "Token feeFlat should be set in the storage contract.")
        assert.equal(feeAccount, TOKEN_FEE_ACCOUNT, "Token feeAccount should be set in the storage contract.")
    })

    /* GETTERS */

    it(`BALANCE_OF
        :should get balance of account1`, async () => {
        const erc20 = await TokenIOERC20.deployed()
        await erc20.setParams(...Object.keys(TOKEN_DETAILS[0]).map((param) => { return TOKEN_DETAILS[0][param] }))

        const balance = await erc20.balanceOf(TEST_ACCOUNT_1)
        assert.equal(balance, 0)
    })

    it(`ALLOWANCE
        :should return allowance of account2 on behalf of account 1`, async () => {
          const erc20 = await TokenIOERC20.deployed()
          await erc20.setParams(...Object.keys(TOKEN_DETAILS[0]).map((param) => { return TOKEN_DETAILS[0][param] }))

          const allowance = await erc20.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
          assert.equal(allowance, 0)
    })

    /* PUBLIC FUNCTIONS */

    it(`TRANSFER
        :should supply uints, debiting the sender and crediting the receiver
        balance1: 100 --> 0
        balance2:   0 --> 98`, async () => {
        const storage = await TokenIOStorage.deployed()
        const erc20 = await TokenIOERC20.deployed()
        const CA = await TokenIOCurrencyAuthority.deployed();

        const kycReceipt1 = await CA.approveKYC(TEST_ACCOUNT_1, true, "Token, Inc.")
        const kycReceipt2= await CA.approveKYC(TEST_ACCOUNT_2, true, "Token, Inc.")
        const kycReceipt3= await CA.approveKYC(TEST_ACCOUNT_3, true, "Token, Inc.")

        await erc20.setParams(...Object.keys(TOKEN_DETAILS[0]).map((param) => { return TOKEN_DETAILS[0][param] }))
        await storage.allowOwnership(erc20.address)
        const tokenSymbol = await erc20.symbol()
        const depositReceipt = await CA.deposit(tokenSymbol, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")

        const balance1 = +(await erc20.balanceOf(TEST_ACCOUNT_1)).toString()
        const balance2 = +(await erc20.balanceOf(TEST_ACCOUNT_2)).toString()

        assert.equal(balance1, DEPOSIT_AMOUNT)
        assert.equal(balance2, 0)

        const transferReceipt = await erc20.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT)
        const balance1b = +(await erc20.balanceOf(TEST_ACCOUNT_1)).toString()
        const balance2b = +(await erc20.balanceOf(TEST_ACCOUNT_2)).toString()

        // calc fees
        const TX_FEES = +(await erc20.calculateFees(TRANSFER_AMOUNT)).toString()

        // calculate correct current balance
        assert.equal(balance1b, (DEPOSIT_AMOUNT-TRANSFER_AMOUNT-TX_FEES))
        assert.equal(balance2b, TRANSFER_AMOUNT)
    })


    it(`APPROVE
        :should give allowance of remaining balance of account 1 to account 2
        allowances[account1][account2]: 0 --> 100`, async () => {
        const storage = await TokenIOStorage.deployed()
        const erc20 = await TokenIOERC20.deployed()
        const CA = await TokenIOCurrencyAuthority.deployed();

        const balance1a = +(await erc20.balanceOf(TEST_ACCOUNT_1))
        const balance1b = +(await erc20.balanceOf(TEST_ACCOUNT_2))


        const approveReceipt = await erc20.approve(TEST_ACCOUNT_2, balance1a)
        const allowance = +(await erc20.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()

        assert.notEqual(allowance, 0, "Allowance should not equal zero.")
        assert.equal(allowance, balance1a, "Allowance should be the same value as the balance of account 1")
    })

    it(`TRANSFER_FROM
        :account 2 should spend funds transfering from account1 to account 3  on behalf of account1`, async () => {
        const storage = await TokenIOStorage.deployed()
        const erc20 = await TokenIOERC20.deployed()
        const CA = await TokenIOCurrencyAuthority.deployed();


        const TEST_ACT_1_BEG_BALANCE = +(await erc20.balanceOf(TEST_ACCOUNT_1)).toString()
        const TEST_ACT_2_BEG_BALANCE = +(await erc20.balanceOf(TEST_ACCOUNT_2)).toString()
        const TEST_ACT_3_BEG_BALANCE = +(await erc20.balanceOf(TEST_ACCOUNT_3)).toString()

        assert.notEqual(TEST_ACT_1_BEG_BALANCE, 0, "Balance of account 1 should not equal zero.")
        assert.notEqual(TEST_ACT_2_BEG_BALANCE, 0, "Balance of account 2 should not equal zero.")

        const BEG_ALLOWANCE = await erc20.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
        assert.equal(BEG_ALLOWANCE, TEST_ACT_1_BEG_BALANCE)

        const TRANSFER_FROM_AMOUNT = (TEST_ACT_1_BEG_BALANCE/2);
        const transferFromReceipt = await erc20.transferFrom(TEST_ACCOUNT_1, TEST_ACCOUNT_3, TRANSFER_FROM_AMOUNT, { from: TEST_ACCOUNT_2 })

        const TX_FEES = +(await erc20.calculateFees(TRANSFER_FROM_AMOUNT)).toString()
        const TEST_ACT_1_END_BALANCE = +(await erc20.balanceOf(TEST_ACCOUNT_1))
        assert.equal(TEST_ACT_1_END_BALANCE, (TEST_ACT_1_BEG_BALANCE-TRANSFER_FROM_AMOUNT-TX_FEES), "Ending balance should be net of transfer amount and fees")

        const TEST_ACT_3_END_BALANCE = +(await erc20.balanceOf(TEST_ACCOUNT_3)).toString()
        assert.equal(TEST_ACT_3_END_BALANCE, TRANSFER_FROM_AMOUNT, "TEST_ACCOUNT_3 Balance should equal transfer amount");

        const END_ALLOWANCE = +(await erc20.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()
        assert.equal(END_ALLOWANCE, (TEST_ACT_1_BEG_BALANCE-TRANSFER_FROM_AMOUNT), "Allowance should be reduced by amount transferred")

    })
})