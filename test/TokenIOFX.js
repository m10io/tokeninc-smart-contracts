var { Wallet, utils } = require('ethers');
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
		const APPROVE_FULFILLER = await CA.approveKYC(accounts[0], true, "Token, Inc.")

		const DEPOSIT_REQUESTER_AMOUNT_TX = await CA.deposit(TOKEN_B_SYMBOL, REQUESTER_WALLET.address, REQUESTER_OFFERED_AMOUNT, "Token, Inc.")
		const DEPOSIT_FULFILLER_AMOUNT_TX = await CA.deposit(TOKEN_A_SYMBOL, accounts[0], REQUESTER_DESIRED_AMOUNT, "Token, Inc.")

		assert.equal(DEPOSIT_REQUESTER_AMOUNT_TX['receipt']['status'], "0x1", "Transaction should be successful")
		assert.equal(DEPOSIT_FULFILLER_AMOUNT_TX['receipt']['status'], "0x1", "Transaction should be successful")


		const REQUESTER_BALANCE = +(await TOKEN_B.balanceOf(REQUESTER_WALLET.address)).toString()
		assert.equal(REQUESTER_BALANCE, REQUESTER_OFFERED_AMOUNT, "Requester balance should equal offered amount")

		const FULFILLER_BALANCE = +(await TOKEN_A.balanceOf(accounts[0])).toString()
		assert.equal(FULFILLER_BALANCE, REQUESTER_DESIRED_AMOUNT, "Fulfiller balance should equal the requester desired amount")

	})

	it("Should allow the swap between the requester and the fulfiller", async () => {
		const FX = await TokenIOFX.deployed();

		const message = utils.solidityKeccak256(
			[ 'address', 'string', 'string', 'uint', 'uint', 'uint' ],
			[ REQUESTER_WALLET.address, 'JPYx', 'USDx', REQUESTER_OFFERED_AMOUNT, REQUESTER_DESIRED_AMOUNT, (new Date().getTime() * 1000) ]
		)

		const txHash = utils.keccak256(utils.concat([
	        utils.toUtf8Bytes('\x19Ethereum Signed Message:\n'),
	        utils.toUtf8Bytes(String(message.length)),
	        ((typeof(message) === 'string') ? utils.toUtf8Bytes(message): message)
	    ]))

		const signedMessage = REQUESTER_WALLET.signMessage(message)

		const r = signedMessage.slice(0, 66)
		const s = "0x"+signedMessage.slice(66, 130)
		const v = 27 + parseInt(signedMessage.slice(130, 132));

		const address = Wallet.verifyMessage(message, signedMessage)

		assert.equal(address, REQUESTER_WALLET.address, "Verified Address should be Requester's address")

		const REQUESTER_BALANCE_B = +(await TOKEN_B.balanceOf(REQUESTER_WALLET.address)).toString()
		assert.equal(REQUESTER_BALANCE_B, REQUESTER_OFFERED_AMOUNT, "Requester balance should equal offered amount")

		const FULFILLER_BALANCE_A = +(await TOKEN_A.balanceOf(accounts[0])).toString()
		assert.equal(FULFILLER_BALANCE_A, REQUESTER_DESIRED_AMOUNT, "Fulfiller balance should equal the requester desired amount")

		const SWAP_TX = await FX.swap(
			REQUESTER_WALLET.address.toLowerCase(),
			TOKEN_A_SYMBOL, TOKEN_B_SYMBOL,
			REQUESTER_DESIRED_AMOUNT, REQUESTER_OFFERED_AMOUNT,
			v, r, s,
			((new Date().getTime() * 1000) * (86400*1000)),
			txHash
		)

		assert.equal(SWAP_TX['receipt']['status'], "0x1", "Transaction should succeed")

		const REQUESTER_BALANCE_A = +(await TOKEN_A.balanceOf(REQUESTER_WALLET.address)).toString()
		assert.equal(REQUESTER_BALANCE_A, REQUESTER_DESIRED_AMOUNT, "Requester balance should equal desired amount")

		const FULFILLER_BALANCE_B = +(await TOKEN_B.balanceOf(accounts[0])).toString()
		assert.equal(FULFILLER_BALANCE_B, REQUESTER_OFFERED_AMOUNT, "Requester balance should equal desired amount")

	})

	// Global Test Variables;
	// const AUTHORITY_ACCOUNT = accounts[0];
	// const AUTHORITY_ACCOUNT_2 = authorityAddress;
	// const FIRM_NAME = firmName;
	//
	// it("Should confirm AUTHORITY_ACCOUNT has been set appropriately", async () => {
	//   const authority = await TokenIOAuthority.deployed();
	//   const isAuthorized = await authority.isRegisteredToFirm(FIRM_NAME, AUTHORITY_ACCOUNT);
	//   assert.equal(isAuthorized, true, "Authority firm and address should be authorized");
	// });
	//
	// it("Should confirm FIRM_NAME has been set appropriately", async () => {
	//   const authority = await TokenIOAuthority.deployed();
	//   const authorityFirm = await authority.getFirmFromAuthority(AUTHORITY_ACCOUNT);
	//   assert.equal(authorityFirm, FIRM_NAME, "Authority firm should be set to the firmName");
	// })
	//
	// it("Should confirm non-authority is not authorized", async () => {
	//   const authority = await TokenIOAuthority.deployed();
	//   const isAuthorized = await authority.isRegisteredAuthority(AUTHORITY_ACCOUNT_2);
	//   assert.equal(isAuthorized, false, "Non registered account should not be authorized");
	// })

});
