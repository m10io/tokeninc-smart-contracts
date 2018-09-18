var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");
var TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");

const { mode, development, production } = require('../token.config.js');
const {
  AUTHORITY_DETAILS: { firmName, authorityAddress },
  TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS['USDx']

contract("TokenIOCurrencyAuthority", function(accounts) {

  // Global Test Variables;
  const AUTHORITY_ACCOUNT = accounts[0];
  const DEPOSIT_TO_ACCOUNT = accounts[1];
  const CURRENCY_SYMBOL = USDx.tokenSymbol
  const DEPOSIT_AMOUNT = 1123581321e2
  const LIMIT_AMOUNT = 5000e2
  const WITHDRAW_AMOUNT = 81321e2
  const FIRM_NAME = firmName;

  it("Should ensure the AUTHORITY_ACCOUNT cannot receive deposited funds on behalf of an account until the account is KYC'd", async () => {
      const CA = await TokenIOCurrencyAuthority.deployed();

      try {
          const { receipt: { status, logs } } = await CA.deposit(CURRENCY_SYMBOL, DEPOSIT_TO_ACCOUNT, DEPOSIT_AMOUNT, FIRM_NAME)
          assert.equal(status, "0x0", "Transaction should fail.");
      } catch (error) {
          assert.equal(error.message.match(RegExp('revert')).length, 1, "Expect transaction to revert due to KYC approval not met");
      }
  })

  it("Should ensure the AUTHORITY_ACCOUNT can approve and deposit funds for an account", async () => {
    const CA = await TokenIOCurrencyAuthority.deployed();
    const erc20 = await TokenIOERC20.deployed()

    const { receipt: { status } } = await CA.approveKYCAndDeposit(CURRENCY_SYMBOL, DEPOSIT_TO_ACCOUNT, DEPOSIT_AMOUNT, LIMIT_AMOUNT, FIRM_NAME)
    assert.equal(status, "0x1", "Transaction receipt status should be 0x1 successful.");

    const BALANCE = +(await erc20.balanceOf(DEPOSIT_TO_ACCOUNT)).toString()
    const TOTAL_SUPPLY = +(await erc20.totalSupply()).toString()

    assert.equal(TOTAL_SUPPLY, DEPOSIT_AMOUNT, "Total supply should equal the amount deposited.")
    assert.equal(BALANCE, DEPOSIT_AMOUNT, "Account balance should equal the amount deposited.")

  })

  it("Should ensure the AUTHORITY_ACCOUNT can withdraw funds from an approved account", async () => {
      const CA = await TokenIOCurrencyAuthority.deployed();
      const erc20 = await TokenIOERC20.deployed()

      const { receipt: { status, logs } } = await CA.withdraw(CURRENCY_SYMBOL, DEPOSIT_TO_ACCOUNT, DEPOSIT_AMOUNT, FIRM_NAME)
      assert.equal(status, "0x1", "Transaction receipt status should be 0x1 successful.");

      const BALANCE = +(await erc20.balanceOf(DEPOSIT_TO_ACCOUNT)).toString()
      const TOTAL_SUPPLY = +(await erc20.totalSupply()).toString()

      assert.equal(TOTAL_SUPPLY, 0, "Total supply should equal 0 after amount is withdrawn.")
      assert.equal(BALANCE, 0, "Account balance should equal 0 after amount is withdrawn.")
  })

  it("Should ensure the AUTHORITY_ACCOUNT can freeze account and disallow depositing funds to an account", async () => {
    const CA = await TokenIOCurrencyAuthority.deployed();
    const erc20 = await TokenIOERC20.deployed()

    const KYC_TX_RESULT = await CA.freezeAccount(DEPOSIT_TO_ACCOUNT, true, FIRM_NAME);
    assert.equal(KYC_TX_RESULT.receipt.status, "0x1", "Transaction receipt status should be 0x1 successful.");

    try {
        const { receipt: { status, logs } } = await CA.deposit(CURRENCY_SYMBOL, DEPOSIT_TO_ACCOUNT, DEPOSIT_AMOUNT, FIRM_NAME)
        assert.equal(status, "0x1", "Transaction receipt status should be 0x1 successful.");

        // const TX_FEES = +(await erc20.calculateFees(DEPOSIT_AMOUNT)).toString()
        const BALANCE = +(await erc20.balanceOf(DEPOSIT_TO_ACCOUNT)).toString()
        const TOTAL_SUPPLY = +(await erc20.totalSupply()).toString()

        assert.equal(TOTAL_SUPPLY, DEPOSIT_AMOUNT, "Total supply should equal the amount deposited.")
        assert.equal(BALANCE, DEPOSIT_AMOUNT, "Account balance should equal the amount deposited.")
    } catch (error) {
        assert.equal(error.message.match(RegExp('revert')).length, 1, "Expect transaction to revert due to KYC approval not met");
    }


  });







});
