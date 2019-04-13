var { Wallet, utils, SigningKey } = require('ethers');
var Promise = require('bluebird')
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");
var TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");
var TokenIOStorage = artifacts.require("./TokenIOStorage.sol");
var TokenIOFX = artifacts.require("./TokenIOFX.sol");
var TokenIOERC20Proxy = artifacts.require("./TokenIOERC20Proxy.sol");
var TokenIOCurrencyAuthorityProxy = artifacts.require("./TokenIOCurrencyAuthorityProxy.sol");
var TokenIOFXProxy = artifacts.require("./TokenIOFXProxy.sol");

const { mode, development, production } = require('../token.config.js');
const {
	AUTHORITY_DETAILS: { firmName, authorityAddress },
	TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS['USDx']
const EURx = TOKEN_DETAILS['EURx']


contract("TokenIOFXProxy", function(accounts) {

	// Globals
	const coder = new utils.AbiCoder()
	const REQUESTER_OFFERED_AMOUNT = 10000e2
	const REQUESTER_DESIRED_AMOUNT = 1000e2

	const SPENDING_LIMIT = 10000e2
	const TEST_ACCOUNT_1 = accounts[0]


	var TOKEN_A,
	TOKEN_B,
	TOKEN_A_SYMBOL,
	TOKEN_B_SYMBOL,
	REQUESTER_WALLET;

	before(async () => {
		const storage = await TokenIOStorage.deployed()
		const token1 = await TokenIOERC20.new(storage.address)
		const token2 = await TokenIOERC20.new(storage.address)
		await storage.allowOwnership(token1.address)
		await storage.allowOwnership(token2.address)
		TOKEN_A = token1;
		TOKEN_B = token2;
		await token1.allowOwnership(TOKEN_A.address)
      	await token1.initProxy(TOKEN_A.address)
      	await token2.allowOwnership(TOKEN_B.address)
      	await token2.initProxy(TOKEN_B.address)

		await TOKEN_A.setParams(...Object.values(USDx).map((v) => { return v }))
		await TOKEN_B.setParams(...Object.values(EURx).map((v) => { return v }))

		REQUESTER_WALLET = await Wallet.createRandom()
	})

	describe("Should ensure token symbols are correctly set", function () {
      it("Should pass", async function () {
		TOKEN_A_SYMBOL = await TOKEN_A.symbol()
		TOKEN_B_SYMBOL = await TOKEN_B.symbol()

		assert.equal(TOKEN_A_SYMBOL, "USDx", "Initiated Token should be USDx")
		assert.equal(TOKEN_B_SYMBOL, "EURx", "Initiated Token should be EURx")
	  })
	})

	describe("Should Deposit EURx into REQUESTER_WALLET account", function () {
      it("Should pass", async function () {
		const CAProxy = await TokenIOCurrencyAuthorityProxy.deployed();

		const APPROVE_REQUESTER = await CAProxy.approveKYC(REQUESTER_WALLET.address, true, SPENDING_LIMIT, "Token, Inc.")
		const APPROVE_FULFILLER = await CAProxy.approveKYC(TEST_ACCOUNT_1, true, SPENDING_LIMIT, "Token, Inc.")

		const DEPOSIT_REQUESTER_AMOUNT_TX = await CAProxy.deposit(TOKEN_B_SYMBOL, REQUESTER_WALLET.address, REQUESTER_OFFERED_AMOUNT, "Token, Inc.")
		const DEPOSIT_FULFILLER_AMOUNT_TX = await CAProxy.deposit(TOKEN_A_SYMBOL, TEST_ACCOUNT_1, REQUESTER_DESIRED_AMOUNT, "Token, Inc.")

		assert.equal(DEPOSIT_REQUESTER_AMOUNT_TX['receipt']['status'], "0x1", "Transaction should be successful")
		assert.equal(DEPOSIT_FULFILLER_AMOUNT_TX['receipt']['status'], "0x1", "Transaction should be successful")


		const REQUESTER_BALANCE = +(await TOKEN_B.balanceOf(REQUESTER_WALLET.address)).toString()
		assert.equal(REQUESTER_BALANCE, REQUESTER_OFFERED_AMOUNT, "Requester balance should equal offered amount")

		const FULFILLER_BALANCE = +(await TOKEN_A.balanceOf(TEST_ACCOUNT_1)).toString()
		assert.equal(FULFILLER_BALANCE, REQUESTER_DESIRED_AMOUNT, "Fulfiller balance should equal the requester desired amount")
	  })
    })

	describe("Should allow the swap between the requester and the fulfiller", function () {
      it("Should pass", async function () {
		const FXProxy = await TokenIOFXProxy.deployed();

		const expiration = ((new Date().getTime() * 1000) + 86400 );

		const message = utils.solidityKeccak256(
			[ 'address', 'string', 'string', 'uint256', 'uint256', 'uint256' ],
			[ REQUESTER_WALLET.address, 'USDx', 'EURx', REQUESTER_DESIRED_AMOUNT, REQUESTER_OFFERED_AMOUNT, expiration ]
		)

		const signingKey = new SigningKey(REQUESTER_WALLET.privateKey)
		const sig = signingKey.signDigest(message)
		const address = SigningKey.recover(message, sig.r, sig.s, sig.recoveryParam)

		assert.equal(address, REQUESTER_WALLET.address, "Verified Address should be Requester's address")
		assert.equal(+(await TOKEN_B.balanceOf(REQUESTER_WALLET.address)).toString(), REQUESTER_OFFERED_AMOUNT, "Requester balance should equal offered amount")
		assert.equal(+(await TOKEN_A.balanceOf(REQUESTER_WALLET.address)).toString(), 0, "Requester balance for token A should be zero")
		assert.equal(+(await TOKEN_A.balanceOf(TEST_ACCOUNT_1)).toString(), REQUESTER_DESIRED_AMOUNT, "Fulfiller balance should equal the requester desired amount")
		assert.equal(+(await TOKEN_B.balanceOf(TEST_ACCOUNT_1)).toString(), 0, "Fulfiller balance for token B should be zero")

		const SWAP_TX = await FXProxy.swap(
			REQUESTER_WALLET.address.toLowerCase(),
			TOKEN_A_SYMBOL, TOKEN_B_SYMBOL,
			REQUESTER_DESIRED_AMOUNT, REQUESTER_OFFERED_AMOUNT,
			(+sig.recoveryParam + 27), sig.r, sig.s,
			expiration
		)

		assert.equal(SWAP_TX['receipt']['status'], "0x1", "Transaction should succeed")
		assert.equal(+(await TOKEN_A.balanceOf(REQUESTER_WALLET.address)).toString(), REQUESTER_DESIRED_AMOUNT, "Requester balance should equal desired amount")
		assert.equal(+(await TOKEN_B.balanceOf(REQUESTER_WALLET.address)).toString(), 0, "Requester balance for token B should be zero after swap")
		assert.equal(+(await TOKEN_B.balanceOf(TEST_ACCOUNT_1)).toString(), REQUESTER_OFFERED_AMOUNT, "Requester balance should equal desired amount")
		assert.equal(+(await TOKEN_A.balanceOf(TEST_ACCOUNT_1)).toString(), 0, "Fulfiller balance for token A should be zero after swap")
	  })
    })

});
