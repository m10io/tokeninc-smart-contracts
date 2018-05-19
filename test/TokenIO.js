var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIO = artifacts.require("./TokenIO.sol");

const { mode, development, production } = require('../token.config.js');
const { admin, feeAccount } = mode == 'production' ? production : development;

/*
 * Tests should be run on development network, as it allows multiple accounts to be
 * unlocked and funded by default;
 *
 * TODO
 * - [ ] Ensure all expected event logs are emitted;
 * - [ ] Ensure 100% code coverage (every line should be executed in the contract);
 * - [ ]
 */


contract("TokenIO", function(accounts) {

  // Global Variables

  const INITIAL_DEPOSIT_AMOUNT = 100e2 // 100.00
  const AUTHORITY_ACCOUNT = accounts[0];
  const CUSTOMER_ACCOUNT = accounts[1];
  const RECEIVER_ACCOUNT = accounts[2];
  const SPENDER_ACCOUNT = accounts[3];

  it("Should allow account to request to deposit funds, and increase requested funds of account.", async () => {
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
    const token = await TokenIO.deployed();

    const CUSTOMER_BALANCE_BEGINNING = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()

    const FREEZE_TX = await token.freeze(CUSTOMER_ACCOUNT, CUSTOMER_BALANCE_BEGINNING, { from: AUTHORITY_ACCOUNT })

    assert.equal(FREEZE_TX.receipt.status, "0x01", "Transaction should succeed")

    const CUSTOMER_BALANCE_END = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.equal(CUSTOMER_BALANCE_END, 0, "Customer balance should equal zero")

    const CUSTOMER_FROZEN_BALANCE = +(await token.frozenBalanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.equal(CUSTOMER_FROZEN_BALANCE, CUSTOMER_BALANCE_BEGINNING, "Customer frozen balance should increase after funds are frozen.")

  })

  it("Should unfreeze customer account with frozen funds, increasing account balance", async () => {
    const token = await TokenIO.deployed();

    const FROZEN_BALANCE_BEG = +(await token.frozenBalanceOf(CUSTOMER_ACCOUNT)).toString()

    const UNFREEZE_TX = await token.unfreeze(CUSTOMER_ACCOUNT, FROZEN_BALANCE_BEG, { from: AUTHORITY_ACCOUNT })
    assert.equal(UNFREEZE_TX.receipt.status, "0x01", "Transaction should succeed")

    const FROZEN_BALANCE_END = +(await token.frozenBalanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.equal(FROZEN_BALANCE_END, 0, "Customer frozen balance should equal zero")

    const CUSTOMER_BALANCE = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.equal(CUSTOMER_BALANCE, FROZEN_BALANCE_BEG, "Customer balance should increase to origin frozen funds amount.")


  })

  it("Should pause contract and disallow state changing methods, and unpause contract", async () => {
    const token = await TokenIO.deployed();

    const PAUSE_TX = await token.pauseContract(true, { from: AUTHORITY_ACCOUNT })
    assert.equal(PAUSE_TX.receipt.status, "0x01", "Transaction should succeed")

    const IS_PAUSED = await token.checkPaused()
    assert.equal(IS_PAUSED, true, "Contract should be paused")

    const CUSTOMER_BALANCE = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()

    // Following transaction should fail when trying to transfer during paused contract
    token.transfer(RECEIVER_ACCOUNT, CUSTOMER_BALANCE, { from: CUSTOMER_ACCOUNT })
      .then(() => { assert.throw("Transaction should fail") })
      .catch((error) => {
        assert.equal(1, error.message.match(RegExp('revert')).length, "Transaction should revert")
      })

    const UNPAUSE_TX = await token.pauseContract(false, { from: AUTHORITY_ACCOUNT })
    assert.equal(UNPAUSE_TX.receipt.status, "0x01", "Transaction should succeed")


  })

  it("Should fail to force transfer funds from unfrozen account", async () => {
    const token = await TokenIO.deployed();

    const CUSTOMER_BALANCE = +(token.balanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.notEqual(CUSTOMER_BALANCE, 0, "Customer account should have a balance")

    token.forceTransfer(CUSTOMER_ACCOUNT, RECEIVER_ACCOUNT, CUSTOMER_BALANCE, { from: AUTHORITY_ACCOUNT })
      .then(() => {
        assert.throw("Transaction should fail.")
      })
      .catch((error) => {
        assert.equal(1, error.message.match(RegExp('revert')).length, "Transaction should revert")
      })

    const RECEIVER_BALANCE = +(await token.balanceOf(RECEIVER_ACCOUNT)).toString()
    assert.equal(RECEIVER_BALANCE, 0, "Receiver balance should equal zero")

  })

  it("Should transfer ownership of contract to another [RECEIVER] account", async () => {
    const token = await TokenIO.deployed();

    const TRANSFER_OWNERSHIP_TX = await token.transferOwnership(RECEIVER_ACCOUNT, { from: AUTHORITY_ACCOUNT })
    assert.equal(TRANSFER_OWNERSHIP_TX.receipt.status, "0x01", "Transaction should succeed")

    const IS_NEW_OWNER = await token.owner(RECEIVER_ACCOUNT)
    assert.equal(true, IS_NEW_OWNER, "Should have transferred ownership to new authority account")

  })

  it("Should transfer ownership back to the original authority account", async () => {
    const token = await TokenIO.deployed();

    // Transfer back to original authority account
    const RE_TRANSFER_OWNERSHIP_TX = await token.transferOwnership(AUTHORITY_ACCOUNT, { from: RECEIVER_ACCOUNT })
    assert.equal(RE_TRANSFER_OWNERSHIP_TX.receipt.status, "0x01", "Transaction should succeed")

    const IS_OWNER = await token.owner(AUTHORITY_ACCOUNT)
    assert.equal(true, IS_OWNER, "Should have transferred ownership to original authority account")
  })

  it("Should set an allowance for funds to be transferred by a delegate/spender account", async () => {
    const token = await TokenIO.deployed();

    const CUSTOMER_BALANCE = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()

    const APPROVAL_TX = await token.approve(SPENDER_ACCOUNT, CUSTOMER_BALANCE, { from: CUSTOMER_ACCOUNT })
    assert.equal(APPROVAL_TX.receipt.status, "0x01", "Transaction should succeed")

    const ALLOWANCE = +(await token.allowance(CUSTOMER_ACCOUNT, SPENDER_ACCOUNT))
    assert.equal(ALLOWANCE, CUSTOMER_BALANCE, "Spender allowance should be set to customer balance.")
  })


  it("Should forbid account and prohibit account from transacting", async () => {
    const token = await TokenIO.deployed();

    const FORBID_TX = await token.forbid(SPENDER_ACCOUNT, true, { from: AUTHORITY_ACCOUNT })
    assert.equal(FORBID_TX.receipt.status, "0x01", "Transaction should succeed")

    const ALLOWANCE = +(await token.allowance(CUSTOMER_ACCOUNT, SPENDER_ACCOUNT)).toString()

    token.transferFrom(CUSTOMER_ACCOUNT, RECEIVER_ACCOUNT, ALLOWANCE, { from: SPENDER_ACCOUNT })
      .then(() => { asser.throw("Transaction should fail.") })
      .catch((error) => {
        assert.equal(1, error.message.match(RegExp('revert')).length, "Transaction should revert")
      })

  })

  it("Should unforbid account and allow spender to transfer funds.", async () => {
    const token = await TokenIO.deployed();

    const IS_FORBID = await token.checkForbidden(SPENDER_ACCOUNT)
    assert.equal(IS_FORBID, true, "Spender account should be forbidden")

    const UNFORBID_TX = await token.forbid(SPENDER_ACCOUNT, false, { from: AUTHORITY_ACCOUNT })
    assert.equal(UNFORBID_TX.receipt.status, "0x01", "Transaction should succeed")

    const CUSTOMER_BALANCE = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()

    const ALLOWANCE = +(await token.allowance(CUSTOMER_ACCOUNT, SPENDER_ACCOUNT)).toString()
    assert.equal(ALLOWANCE, CUSTOMER_BALANCE, "Spender allowance should be set to customer balance.")
    assert.notEqual(ALLOWANCE, 0, "Allowance should not equal 0.")

    const IS_FORBIDDEN = await token.checkForbidden(SPENDER_ACCOUNT)
    assert.equal(IS_FORBIDDEN, false, "Spender account should not be forbidden")

    // NOTE: Cannot send full amount due to transaction fees exceeding balance.
    // Send quarter of funds available.
    const FUNDS = ALLOWANCE/4;

    const TRANSFER_TX = await token.transferFrom(CUSTOMER_ACCOUNT, RECEIVER_ACCOUNT, FUNDS, { from: SPENDER_ACCOUNT })
    assert.equal(TRANSFER_TX.receipt.status, "0x01", "Transaction should succeed")

  })

  it("Should reset spender allowance to zero.", async() => {
    const token = await TokenIO.deployed();

    const SPENDER_ALLOWANCE = +(await token.allowance(CUSTOMER_ACCOUNT, SPENDER_ACCOUNT)).toString()
    assert.notEqual(SPENDER_ALLOWANCE, 0, "Spender allowance should not be zero.")

    const RESET_APPROVAL_TX = await token.approve(SPENDER_ACCOUNT, 0, { from: CUSTOMER_ACCOUNT })
    assert.equal(RESET_APPROVAL_TX.receipt.status, "0x01", "Transaction should succeed")

    const UPDATED_ALLOWANCE = +(await token.allowance(CUSTOMER_ACCOUNT, SPENDER_ACCOUNT)).toString()
    assert.equal(UPDATED_ALLOWANCE, 0, "Spender allowance should be reset to zero.")
  })

  it("Should fail to set values in the storage unless owner", async () => {
    const token = await TokenIO.deployed();

    const ID = utils.solidityKeccak256(['string', 'address'], ['balance', CUSTOMER_ACCOUNT])

    token.setUint(ID, 1e8, { from: CUSTOMER_ACCOUNT })
      .then(() => { assert.throw("Transaction should throw") })
      .catch((error) => {
        assert.equal(1, error.message.match(RegExp('revert')).length, "Transaction should revert")
      })
  })


  it("Should ensure transaction fees were sent to the fee account", async () => {
    const token = await TokenIO.deployed();
    const FEE_BALANCE = +(await token.balanceOf(feeAccount)).toString()

    assert.notEqual(FEE_BALANCE, 0, "Balance of fee account should not equal 0.")

  })

  it("Should fail to unfreeze account with no frozen funds", async () => {
    const token = await TokenIO.deployed();

    const FROZEN_BALANCE = +(await token.frozenBalanceOf(CUSTOMER_ACCOUNT)).toString()
    assert.equal(FROZEN_BALANCE, 0, "Customer frozen balance should equal zero.")

    const CUSTOMER_BALANCE = +(await token.balanceOf(CUSTOMER_ACCOUNT)).toString()

    token.unfreeze(CUSTOMER_ACCOUNT, CUSTOMER_BALANCE, { from: AUTHORITY_ACCOUNT })
      .then(() => { assert.throw("Transaction should throw") })
      .catch((error) => {
        assert.equal(1, error.message.match(RegExp('invalid opcode')).length, "Transaction should revert")
      })

  })



});



/**
 * UTILITY FUNCTIONS FOR COMMON TESTING PATTERNS
 */
