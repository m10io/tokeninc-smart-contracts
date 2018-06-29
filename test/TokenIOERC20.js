
const TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");
const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20 = artifacts.require("./TokenIOERC20.sol")
const { mode, development, production } = require('../token.config.js')
const { utils } = require('ethers')

const { AUTHORITY_DETAILS: { firmName, authorityAddress }, TOKEN_DETAILS} = mode
    == 'production' ? production : development //set stage

contract("TokenIOERC20", function(accounts) {
    // pull in usdx params
    const USDx = TOKEN_DETAILS[0]

    // create test accounts
    const TEST_ACCOUNT_1 = accounts[1]
    const TEST_ACCOUNT_2 = accounts[2]

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
        const TOKEN_FEE_BPS = USDx.feeBps
        const TOKEN_FEE_MIN = USDx.feeMin
        const TOKEN_FEE_MAX = USDx.feeMax
        const TOKEN_FEE_FLAT = USDx.feeFlat
        const TOKEN_FEE_ACCOUNT = USDx.feeAccount

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

        const balance = await erc20.balanceOf(accounts[0])
        assert.equal(balance, 0)
    })

    it(`ALLOWANCE
        :should return allowance of account2 on behalf of account 1`, async () => {
          const erc20 = await TokenIOERC20.deployed()
          await erc20.setParams(...Object.keys(TOKEN_DETAILS[0]).map((param) => { return TOKEN_DETAILS[0][param] }))

          const allowance = await erc20.allowance(accounts[0], accounts[1])
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

        const kycReceipt1 = await CA.approveKYC(accounts[0], true, "Token, Inc.")
        const kycReceipt12= await CA.approveKYC(accounts[1], true, "Token, Inc.")

        await erc20.setParams(...Object.keys(TOKEN_DETAILS[0]).map((param) => { return TOKEN_DETAILS[0][param] }))
        await storage.allowOwnership(erc20.address)
        const tokenSymbol = await erc20.symbol()
        const depositReceipt = await CA.deposit(tokenSymbol, accounts[0], 200, "Token, Inc.")

        const balance1 = +(await erc20.balanceOf(accounts[0])).toString()
        const balance2 = +(await erc20.balanceOf(accounts[1])).toString()

        assert.equal(balance1, 200)
        assert.equal(balance2, 0)

        const transferReceipt = await erc20.transfer(TEST_ACCOUNT_1, 100)
        const balance1b = +(await erc20.balanceOf(accounts[0])).toString()
        const balance2b = +(await erc20.balanceOf(accounts[1])).toString()

        // calculate correct debit
        const feeParams = await erc20.getFeeParams()
        const feeBps = +(feeParams[0])
        const debitAmount = 100 + feeBps

        assert.equal(balance1b, 200 - debitAmount)
        assert.equal(balance2b, 100)
    })


    it(`APPROVE
        :should give 100 allowance to account 2
        allowances[account1][account2]: 0 --> 100`, async () => {
        const storage = await TokenIOStorage.deployed()
        const erc20 = await TokenIOERC20.deployed()
        const CA = await TokenIOCurrencyAuthority.deployed();

        const kycReceipt1 = await CA.approveKYC(accounts[0], true, "Token, Inc.")
        const kycReceipt12= await CA.approveKYC(accounts[1], true, "Token, Inc.")

        await erc20.setParams(...Object.keys(TOKEN_DETAILS[0]).map((param) => { return TOKEN_DETAILS[0][param] }))
        await storage.allowOwnership(erc20.address)
        const tokenSymbol = await erc20.symbol()
        const depositReceipt = await CA.deposit(tokenSymbol, accounts[0], 200, "Token, Inc.")

        const balance1a = +(await erc20.balanceOf(accounts[0]))
        const balance1b = +(await erc20.balanceOf(accounts[1]))

        const approveReceipt = await erc20.approve(accounts[1], 100)
        
        const allowance = await erc20.allowance(accounts[0], accounts[1])

        assert.equal(allowance, 100)
    })

    it(`TRANSFER_FROM
        :account 2 should spend funds transfering from account1 to account 3  on behalf of account1`, async () => {
        const storage = await TokenIOStorage.deployed()
        const erc20 = await TokenIOERC20.deployed()
        const CA = await TokenIOCurrencyAuthority.deployed();

        const kycReceipt1 = await CA.approveKYC(accounts[0], true, "Token, Inc.")
        const kycReceipt12= await CA.approveKYC(accounts[1], true, "Token, Inc.")


        await erc20.setParams(...Object.keys(TOKEN_DETAILS[0]).map((param) => { return TOKEN_DETAILS[0][param] }))

        await storage.allowOwnership(erc20.address)
        const tokenSymbol = await erc20.symbol()
        const depositReceipt = await CA.deposit(tokenSymbol, accounts[0], 2, "Token, Inc.")
        const balance1a = +(await erc20.balanceOf(accounts[0]))
        const balance1b = +(await erc20.balanceOf(accounts[1]))
        console.log('balance1a', balance1a)
        console.log('balance1b', balance1b)

        const approveReceipt = await erc20.approve(accounts[1], 100)

        const allowance = await erc20.allowance(accounts[0], accounts[1])
        console.log('allowance', allowance)
        assert.equal(allowance, 100)

        const transferFromReceipt = await erc20.transferFrom(accounts[0], 100, {from: accounts[1]})

        const balance2a = +(await erc20.balanceOf(accounts[0]))
        console.log('balance1', balance1)
        const balance2b = +(await erc20.balanceOf(accounts[1]))

        // calculate correct debit
        const feeParams = await erc20.getFeeParams()
        const feeBps = +(feeParams[0])

        assert.equal(balance1, 0)
        assert.equal(balance2, allowance - feeBps)
    })
})
