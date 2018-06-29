var { Wallet, utils, SigningKey } = require('ethers');
var Promise = require('bluebird')
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");
var TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol");
var TokenIOStorage = artifacts.require("./TokenIOStorage.sol");
var TokenIOFX = artifacts.require("./TokenIOFX.sol");

const { mode, development, production } = require('../token.config.js');
const {
	AUTHORITY_DETAILS: { firmName, authorityAddress },
	TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS[0]

const { addresses, abi, bytecode } = require('../deployed/TokenIOERC20--development.json')

/*
- [ ] load deployed token contracts;
- [ ] Create Request Address;
- [ ] Provide Requester Address w/ GBP Balance;
- [ ] Sign a message for requester;
- [ ] Send signed message to execSwap() function
- [ ] Check Balances
*/



contract("TokenIOFX", function(accounts) {

	// Globals
	const coder = new utils.AbiCoder()
	const REQUESTER_OFFERED_AMOUNT = 1000000
	const REQUESTER_DESIRED_AMOUNT = 10000

	const TEST_ACCOUNT_1 = accounts[0]


	var TOKEN_A,
	TOKEN_B,
	TOKEN_A_SYMBOL,
	TOKEN_B_SYMBOL,
	REQUESTER_WALLET;

	before(async () => {
		const storage = await TokenIOStorage.deployed()
		TOKEN_A = await TokenIOERC20.new(storage.address)
		TOKEN_B = await TokenIOERC20.new(storage.address)

		await storage.allowOwnership(TOKEN_A.address)
		await storage.allowOwnership(TOKEN_B.address)
		await TOKEN_A.setParams(...Object.keys(TOKEN_DETAILS[0]).map((param) => { return TOKEN_DETAILS[0][param] }))
		await TOKEN_B.setParams(...Object.keys(TOKEN_DETAILS[3]).map((param) => { return TOKEN_DETAILS[3][param] }))

		REQUESTER_WALLET = await Wallet.createRandom()
	})

	it("Should create a wallet for our requester and provide it with an initial balance", async () => {
		TOKEN_A_SYMBOL = await TOKEN_A.symbol()
		TOKEN_B_SYMBOL = await TOKEN_B.symbol()

		assert.equal(TOKEN_A_SYMBOL, "USDx", "Initiated Token should be USDx")
		assert.equal(TOKEN_B_SYMBOL, "JPYx", "Initiated Token should be JPYx")

	})

	it("Should Deposit JPYx into REQUESTER_WALLET account", async () => {
		const CA = await TokenIOCurrencyAuthority.deployed();

		const APPROVE_REQUESTER = await CA.approveKYC(REQUESTER_WALLET.address, true, "Token, Inc.")
		const APPROVE_FULFILLER = await CA.approveKYC(TEST_ACCOUNT_1, true, "Token, Inc.")

		const DEPOSIT_REQUESTER_AMOUNT_TX = await CA.deposit(TOKEN_B_SYMBOL, REQUESTER_WALLET.address, REQUESTER_OFFERED_AMOUNT, "Token, Inc.")
		const DEPOSIT_FULFILLER_AMOUNT_TX = await CA.deposit(TOKEN_A_SYMBOL, TEST_ACCOUNT_1, REQUESTER_DESIRED_AMOUNT, "Token, Inc.")

		assert.equal(DEPOSIT_REQUESTER_AMOUNT_TX['receipt']['status'], "0x1", "Transaction should be successful")
		assert.equal(DEPOSIT_FULFILLER_AMOUNT_TX['receipt']['status'], "0x1", "Transaction should be successful")


		const REQUESTER_BALANCE = +(await TOKEN_B.balanceOf(REQUESTER_WALLET.address)).toString()
		assert.equal(REQUESTER_BALANCE, REQUESTER_OFFERED_AMOUNT, "Requester balance should equal offered amount")

		const FULFILLER_BALANCE = +(await TOKEN_A.balanceOf(TEST_ACCOUNT_1)).toString()
		assert.equal(FULFILLER_BALANCE, REQUESTER_DESIRED_AMOUNT, "Fulfiller balance should equal the requester desired amount")

	})

	it("Should allow the swap between the requester and the fulfiller", async () => {
		const FX = await TokenIOFX.deployed();

		const expiration = ((new Date().getTime() * 1000) + 86400 );

		const message = utils.solidityKeccak256(
			[ 'address', 'string', 'string', 'uint256', 'uint256', 'uint256' ],
			[ REQUESTER_WALLET.address, 'USDx', 'JPYx', REQUESTER_DESIRED_AMOUNT, REQUESTER_OFFERED_AMOUNT, expiration ]
		)

		const signingKey = new SigningKey(REQUESTER_WALLET.privateKey)
		const sig = signingKey.signDigest(message)
		const address = SigningKey.recover(message, sig.r, sig.s, sig.recoveryParam)

		assert.equal(address, REQUESTER_WALLET.address, "Verified Address should be Requester's address")
		assert.equal(+(await TOKEN_B.balanceOf(REQUESTER_WALLET.address)).toString(), REQUESTER_OFFERED_AMOUNT, "Requester balance should equal offered amount")
		assert.equal(+(await TOKEN_A.balanceOf(REQUESTER_WALLET.address)).toString(), 0, "Requester balance for token A should be zero")
		assert.equal(+(await TOKEN_A.balanceOf(TEST_ACCOUNT_1)).toString(), REQUESTER_DESIRED_AMOUNT, "Fulfiller balance should equal the requester desired amount")
		assert.equal(+(await TOKEN_B.balanceOf(TEST_ACCOUNT_1)).toString(), 0, "Fulfiller balance for token B should be zero")

		const SWAP_TX = await FX.swap(
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

});
