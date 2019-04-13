const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOCurrencyAuthorityProxy = artifacts.require("./TokenIOCurrencyAuthorityProxy.sol");
const TokenIOERC20UnlimitedProxy = artifacts.require("./TokenIOERC20UnlimitedProxy.sol")
const TokenIOFeeContractProxy = artifacts.require("./TokenIOFeeContractProxy.sol")
const { mode, development, production } = require('../token.config.js')
const { utils } = require('ethers')

const { AUTHORITY_DETAILS: { firmName, authorityAddress }, TOKEN_DETAILS, FEE_PARAMS } = mode
    == 'production' ? production : development //set stage

contract("TokenIOERC20UnlimitedProxy", function(accounts) {
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

    before(async function () {
      this.tokenIOERC20UnlimitedProxy = await TokenIOERC20UnlimitedProxy.deployed();
      this.tokenIOFeeContractProxy = await TokenIOFeeContractProxy.deployed();
      this.tokenIOStorage = await TokenIOStorage.deployed();
      this.tokenIOCurrencyAuthorityProxy = await TokenIOCurrencyAuthorityProxy.deployed();

      await this.tokenIOERC20UnlimitedProxy.setParams(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_TLA, TOKEN_VERSION, TOKEN_DECIMALS, this.tokenIOFeeContractProxy.address, 10000);
    });

    /* PARAMETERS */

    describe("TOKEN_PARAMS:should correctly set parameters according to c 'token.config.js' [name, symbol, tla, decimals]", function () {
      it("Should pass", async function () {

        const name = await this.tokenIOERC20UnlimitedProxy.name()
        const symbol = await this.tokenIOERC20UnlimitedProxy.symbol()
        const tla = await this.tokenIOERC20UnlimitedProxy.tla()
        const version = await this.tokenIOERC20UnlimitedProxy.version()
        const decimals = await this.tokenIOERC20UnlimitedProxy.decimals()

        assert.equal(name, TOKEN_NAME, "Token name should be set in the storage contract.")
        assert.equal(symbol, TOKEN_SYMBOL, "Token symbol should be set in the storage contract.")
        assert.equal(tla, TOKEN_TLA, "Token tla should be set in the storage contract.")
        assert.equal(version, TOKEN_VERSION, "Token version should be set in the storage contract.")
        assert.equal(decimals, TOKEN_DECIMALS, "Token decimals should be set in the storage contract.")
      })
    })

    /* GETTERS */

    describe("BALANCE_OF:should get balance of account1", function () {
      it("Should pass", async function () {
        const balance = await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_1)
        assert.equal(balance, 0)
      })
    })

    describe("ALLOWANCE:should return allowance of account2 on behalf of account 1", function () {
      it("Should pass", async function () {
        const allowance = await this.tokenIOERC20UnlimitedProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
        assert.equal(allowance, 0)
      })
    })

    /* PUBLIC FUNCTIONS */

    describe("TRANSFER:should supply uints, debiting the sender and crediting the receiver", function () {
      it('Should fail due to not enough balance', async function () {
        try {
            const { receipt: { status } } = await this.tokenIOERC20UnlimitedProxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT);
        } catch (error) {
            assert.equal(error.message.match(RegExp('revert')).length, 1, "Not enough balance");
        }
      });

      it('Should fail due to amount must not be 0', async function () {
        try {
            const { receipt: { status } } = await this.tokenIOERC20UnlimitedProxy.transfer(TEST_ACCOUNT_2, 0);
        } catch (error) {
            assert.equal(error.message.match(RegExp('revert')).length, 1, "Amount of transfer must not be 0");
        }
      });

      it("Should pass", async function () {
        const kycReceipt1 = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_1, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt2= await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_2, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt3= await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_3, true, LIMIT_AMOUNT, "Token, Inc.")

        await this.tokenIOStorage.allowOwnership(this.tokenIOERC20UnlimitedProxy.address)
        const tokenSymbol = await this.tokenIOERC20UnlimitedProxy.symbol()
        const depositReceipt = await this.tokenIOCurrencyAuthorityProxy.deposit(tokenSymbol, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")

        const balance1 = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const balance2 = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_2)).toString()

        assert.equal(balance1, DEPOSIT_AMOUNT)
        assert.equal(balance2, 0)

        const transferReceipt = await this.tokenIOERC20UnlimitedProxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT)
        const balance1b = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const balance2b = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_2)).toString()

        // calc fees
        // const TX_FEES = +(await erc20.calculateFees(TRANSFER_AMOUNT)).toString()

        // check spending limit remaining
        // Spending limit should remain unchanged!
        const SPENDING_LIMIT = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingLimit(TEST_ACCOUNT_1)).toString()
        const SPENDING_REMAINING = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()

        assert.equal(SPENDING_REMAINING, (SPENDING_LIMIT),
            "Remaining spending amount should remain equal to set limit amount")

        // calculate correct current balance
        assert.equal(balance1b, (DEPOSIT_AMOUNT-TRANSFER_AMOUNT))
        assert.equal(balance2b, TRANSFER_AMOUNT)
      })
    })

    describe("APPROVE:should give allowance of remaining balance of account 1 to account 2 allowances[account1][account2]: 0 --> 100", function () {
      it('Should fail due to allowance > msg.sender token balance', async function () {
        const balance1a = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_1))
        try {
            const { receipt: { status } } = await this.tokenIOERC20UnlimitedProxy.approve(TEST_ACCOUNT_2, balance1a+1);
        } catch (error) {
            assert.equal(error.message.match(RegExp('revert')).length, 1, "Allowance > token balance");
        }
      });

      it("Should pass", async function () {
        const kycReceipt1 = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_1, true, LIMIT_AMOUNT, "Token, Inc.")

        await this.tokenIOStorage.allowOwnership(this.tokenIOERC20UnlimitedProxy.address)
        const tokenSymbol = await this.tokenIOERC20UnlimitedProxy.symbol()
        const depositReceipt = await this.tokenIOCurrencyAuthorityProxy.deposit(tokenSymbol, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")

        const balance1a = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_1))
        const balance1b = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_2))

        const approveReceipt = await this.tokenIOERC20UnlimitedProxy.approve(TEST_ACCOUNT_2, balance1a)
        const allowance = +(await this.tokenIOERC20UnlimitedProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()

        assert.notEqual(allowance, 0, "Allowance should not equal zero.")
        assert.equal(allowance, balance1a, "Allowance should be the same value as the balance of account 1")
      })

      it('Should fail due to allowance is not zero', async function () {
        const balance1a = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_1))
        try {
            const { receipt: { status } } = await this.tokenIOERC20UnlimitedProxy.approve(TEST_ACCOUNT_2, balance1a);
        } catch (error) {
            assert.equal(error.message.match(RegExp('revert')).length, 1, "Allowance is not zero");
        }
      });
    })

    describe("TRANSFER_FROM:account 2 should spend funds transfering from account1 to account 3  on behalf of account1", function () {
      it("Should pass", async function () {
        const TEST_ACT_1_BEG_BALANCE = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_1)).toString()
        const TEST_ACT_2_BEG_BALANCE = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_2)).toString()
        const TEST_ACT_3_BEG_BALANCE = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_3)).toString()

        assert.notEqual(TEST_ACT_1_BEG_BALANCE, 0, "Balance of account 1 should not equal zero.")
        assert.notEqual(TEST_ACT_2_BEG_BALANCE, 0, "Balance of account 2 should not equal zero.")
        
        const BEG_ALLOWANCE = await this.tokenIOERC20UnlimitedProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)
        assert.equal(BEG_ALLOWANCE, TEST_ACT_1_BEG_BALANCE)

        const TRANSFER_FROM_AMOUNT = +(await this.tokenIOCurrencyAuthorityProxy.getAccountSpendingRemaining(TEST_ACCOUNT_1)).toString()
        const transferFromReceipt = await this.tokenIOERC20UnlimitedProxy.transferFrom(TEST_ACCOUNT_1, TEST_ACCOUNT_3, TRANSFER_FROM_AMOUNT, { from: TEST_ACCOUNT_2 })

        // const TX_FEES = +(await erc20.calculateFees(TRANSFER_FROM_AMOUNT)).toString()
        const TEST_ACT_1_END_BALANCE = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_1))
        assert.equal(TEST_ACT_1_END_BALANCE, (TEST_ACT_1_BEG_BALANCE-TRANSFER_FROM_AMOUNT), "Ending balance should be net of transfer amount and fees")
        
        const TEST_ACT_3_END_BALANCE = +(await this.tokenIOERC20UnlimitedProxy.balanceOf(TEST_ACCOUNT_3)).toString()
        assert.equal(TEST_ACT_3_END_BALANCE, TRANSFER_FROM_AMOUNT, "TEST_ACCOUNT_3 Balance should equal transfer amount");

        const END_ALLOWANCE = +(await this.tokenIOERC20UnlimitedProxy.allowance(TEST_ACCOUNT_1, TEST_ACCOUNT_2)).toString()
        assert.equal(END_ALLOWANCE, (TEST_ACT_1_BEG_BALANCE-TRANSFER_FROM_AMOUNT), "Allowance should be reduced by amount transferred")
      })
    })

    describe('staticCall', function () {
      it('Should pass', async function () {
        const payload = web3.eth.abi.encodeFunctionSignature('name()')
        const encodedResult = await this.tokenIOERC20UnlimitedProxy.staticCall(payload);
        const result = web3.eth.abi.decodeParameters(['string'], encodedResult);
        assert.equal(result[0], TOKEN_NAME)
      });
    });

    describe('call', function () {
      it('Should pass', async function () {
        await this.tokenIOCurrencyAuthorityProxy.deposit(await this.tokenIOERC20UnlimitedProxy.symbol(), TEST_ACCOUNT_3, DEPOSIT_AMOUNT, "Token, Inc.")
        const payload = web3.eth.abi.encodeFunctionCall({
            name: 'approve',
            type: 'function',
            inputs: [{
                type: 'address',
                name: 'spender'
            },{
                type: 'uint256',
                name: 'amount'
            },{
                type: 'address',
                name: 'sender'
            }]
        }, [TEST_ACCOUNT_2, 1, TEST_ACCOUNT_3]);

        await this.tokenIOERC20UnlimitedProxy.call(payload);
      });
    });

    describe("Deprecate interface", function () {
      it("Should pass", async function () {
        const kycReceipt1 = await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_1, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt2= await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_2, true, LIMIT_AMOUNT, "Token, Inc.")
        const kycReceipt3= await this.tokenIOCurrencyAuthorityProxy.approveKYC(TEST_ACCOUNT_3, true, LIMIT_AMOUNT, "Token, Inc.")

        await this.tokenIOStorage.allowOwnership(this.tokenIOERC20UnlimitedProxy.address)
        const tokenSymbol = await this.tokenIOERC20UnlimitedProxy.symbol()
        const depositReceipt = await this.tokenIOCurrencyAuthorityProxy.deposit(tokenSymbol, TEST_ACCOUNT_1, DEPOSIT_AMOUNT, "Token, Inc.")

        await this.tokenIOERC20UnlimitedProxy.deprecateInterface();

        try {
           const { receipt: { status } } = await this.tokenIOERC20UnlimitedProxy.transfer(TEST_ACCOUNT_2, TRANSFER_AMOUNT);
        } catch (error) {
           assert.equal(error.message.match(RegExp('revert')).length, 1, "Expected interface is not deprecated");
        }
      })
    })

})
