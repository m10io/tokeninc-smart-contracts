var ethers = require('ethers');
var Promise = require('bluebird')
var TokenIO = artifacts.require("./TokenIO.sol");


/*
 * Tests should be run on development network, as it allows multiple accounts to be
 * unlocked and funded by default;
 *
 */

// Global Variables

const INITIAL_DEPOSIT_AMOUNT = 100e2 // 100.00


contract("TokenIO", function(accounts) {

  it("Should allow account to request to deposit funds to increase requested funds of account.", async () => {
    const AUTHORITY_ACCOUNT = accounts[0];
    const CUSTOMER_ACCOUNT = accounts[1];

    const token = await TokenIO.deployed();

    const DEPOSIT_TX = await token.deposit(INITIAL_DEPOSIT_AMOUNT, { from: CUSTOMER_ACCOUNT })
    const DEPOSIT_LOGGED_AMOUT = +DEPOSIT_TX.logs[0].args.amount.toString()
    const DEPOSIT_LOGGED_OWNER = DEPOSIT_TX.logs[0].args.owner
    const REQUESTED_FUNDS = +(await token.requestedFundsOf(CUSTOMER_ACCOUNT)).toString()

    assert.equal(DEPOSIT_TX.receipt.status, "0x01", "Transaction should succeed");
    assert.equal(DEPOSIT_LOGGED_OWNER, CUSTOMER_ACCOUNT, "Expected deposit by customer account");
    assert.equal(DEPOSIT_LOGGED_AMOUT, INITIAL_DEPOSIT_AMOUNT, "Expected deposited amount to equal deposit amount");
    assert.equal(REQUESTED_FUNDS, INITIAL_DEPOSIT_AMOUNT, "Expected requested funds to equal deposit amount");

  })

  it("Should approve deposit amount for customer and increase the balance of the account and increase total supply.", async () => {
    const AUTHORITY_ACCOUNT = accounts[0];
    const CUSTOMER_ACCOUNT = accounts[1];

  	const token = await TokenIO.deployed();

    const TOTAL_SUPPLY_BEGINNING = +(await token.totalSupply()).toString()
    assert.equal(TOTAL_SUPPLY_BEGINNING, 0, "Total supply should equal zero before any funds are approved for deposit.")

    const APPROVE_DEPOSIT_TX = await token.approveDeposit(CUSTOMER_ACCOUNT, INITIAL_DEPOSIT_AMOUNT, { from: AUTHORITY_ACCOUNT })
    const CUSTOMER_BALANCE = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()
    const REQUESTED_FUNDS = +(await token.requestedFundsOf(CUSTOMER_ACCOUNT)).toString()
    const TOTAL_SUPPLY_END = +(await token.totalSupply()).toString()

    assert.equal(APPROVE_DEPOSIT_TX.receipt.status, "0x01", "Transaction should succeed");
    assert.equal(CUSTOMER_BALANCE, INITIAL_DEPOSIT_AMOUNT, "Customer balanace should equal amount deposited.");
    assert.equal(REQUESTED_FUNDS, 0, "Requested funds for customer should be reset to zero after deposit is approved.")
    assert.equal(TOTAL_SUPPLY_END, INITIAL_DEPOSIT_AMOUNT, "Total supply should equal amount deposited")

  })

  it("Should withdraw half of customer funds and decrease account balance and total supply.", async () => {
    const AUTHORITY_ACCOUNT = accounts[0];
    const CUSTOMER_ACCOUNT = accounts[1];

    const token = await TokenIO.deployed();

    const WITHDRAW_AMOUNT = INITIAL_DEPOSIT_AMOUNT / 2;

    const CUSTOMER_BALANCE_BEGINNING = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.equal(CUSTOMER_BALANCE_BEGINNING, INITIAL_DEPOSIT_AMOUNT, "Customer balanace should equal amount deposited.");

    const TOTAL_SUPPLY_BEGINNING = +(await token.totalSupply()).toString()
    assert.equal(TOTAL_SUPPLY_BEGINNING, INITIAL_DEPOSIT_AMOUNT, "Total supply should equal amount deposited.");

    const WITHDRAW_TX = await token.withdraw(CUSTOMER_ACCOUNT, WITHDRAW_AMOUNT, { from: AUTHORITY_ACCOUNT })
    assert.equal(WITHDRAW_TX.receipt.status, "0x01", "Transaction should succeed");
    assert.equal(WITHDRAW_TX.logs[0].args.amount, WITHDRAW_AMOUNT, "Transaction should succeed");

    const CUSTOMER_BALANCE_END = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.equal(CUSTOMER_BALANCE_END, WITHDRAW_AMOUNT, "Customer balanace should equal half of initial deposit amount");

    const TOTAL_SUPPLY_END = +(await token.totalSupply()).toString()
    assert.equal(TOTAL_SUPPLY_END, WITHDRAW_AMOUNT, "Total supply should equal half of initial deposit amount");

  })

  it("Should freeze customer account funds and force transfer", async () => {
    const AUTHORITY_ACCOUNT = accounts[0];
    const CUSTOMER_ACCOUNT = accounts[1];

    const token = await TokenIO.deployed();

    const CUSTOMER_BALANCE_BEGINNING = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()

    const FREEZE_TX = await token.freeze(CUSTOMER_ACCOUNT, CUSTOMER_BALANCE_BEGINNING)

    assert.equal(FREEZE_TX.receipt.status, "0x01", "Transaction should succeed")

    const CUSTOMER_BALANCE_END = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.equal(CUSTOMER_BALANCE_END, 0, "Customer balance should equal zero")

    // const 

  })

  it("Should pause contract and disallow state changing methods")
  it("Should unfreeze account with frozen funds, increasing account balance")
  it("Should fail to force transfer funds from unfrozen account")
  it("Should transfer ownership of contract to another authority account")
  it("Should set an allowance for funds to be transferred by a delegate/spender account")
  it("Should forbid account and prohibit accounts from transacting")
  it("Should fail to set values in the storage unless owner")
  it("Should send transaction fees to fee account")
  it("Should fail unfreeze account with no frozen funds")



});



/**
 * UTILITY FUNCTIONS FOR COMMON TESTING PATTERNS
 */
