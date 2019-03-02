var { Wallet, utils, SigningKey } = require('ethers');
var Promise = require('bluebird')

var TokenIOERC20Unlimited = artifacts.require("./TokenIOERC20Unlimited.sol");
var TokenIOStorage = artifacts.require("./TokenIOStorage.sol");
var TokenIOERC20UnlimitedProxy = artifacts.require("./TokenIOERC20UnlimitedProxy.sol");
var TokenIOCurrencyAuthorityProxy = artifacts.require("./TokenIOCurrencyAuthorityProxy.sol");
var TokenIOStableSwap = artifacts.require("./TokenIOStableSwap.sol");
var TokenIOStableSwapProxy = artifacts.require("./TokenIOStableSwapProxy.sol");

const { mode, development, production } = require('../token.config.js');
const {
	AUTHORITY_DETAILS: { firmName, authorityAddress },
	FEE_PARAMS: { feeBps, feeMin, feeMax, feeFlat },
	TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDc = TOKEN_DETAILS['USDc']


contract("TokenIOStableSwapProxy", function(accounts) {

	// Globals
	const DEPOSIT_AMOUNT = 100e6;
	const SWAP_AMOUNT = 100e6;
	const TEST_ACCOUNT_1 = accounts[1]


	var USDX,
	USDC,
	SWAP,
	CA;

	before(async () => {
		const storage = await TokenIOStorage.deployed()

		CA = await TokenIOCurrencyAuthorityProxy.deployed();
		SWAP = await TokenIOStableSwap.new(storage.address);
		await storage.allowOwnership(SWAP.address)

		SWAPproxy = await TokenIOStableSwapProxy.new(SWAP.address);
		SWAP.allowOwnership(SWAPproxy.address)
		SWAP.initProxy(SWAPproxy.address)

		USDX = await TokenIOERC20UnlimitedProxy.deployed()

		USDC = await TokenIOERC20Unlimited.new(storage.address)
		await storage.allowOwnership(USDC.address)

		USDCproxy = await TokenIOERC20UnlimitedProxy.new(USDC.address)
		USDC.allowOwnership(USDCproxy.address)
		USDC.initProxy(USDCproxy.address)

		await USDCproxy.setParams(...Object.values(USDc).map((v) => { return v }))

		await SWAP.setTokenXCurrency(USDX.address, 'USD');

		// feeBps, feeMin, feeMax, feeFlat
		await SWAP.allowAsset(USDCproxy.address, 'USD', 10, 0, 1e12, 0);
	})

	it("Should Deposit USDc into TEST_ACCOUNT_1 account", async () => {
		const APPROVE_REQUESTER = await CA.approveKYC(TEST_ACCOUNT_1, true, DEPOSIT_AMOUNT, firmName)

		const DEPOSIT_REQUESTER_AMOUNT_TX = await CA.deposit((await USDCproxy.symbol()), TEST_ACCOUNT_1, DEPOSIT_AMOUNT, firmName)

		assert.equal(DEPOSIT_REQUESTER_AMOUNT_TX['receipt']['status'], "0x1", "Transaction should be successful")


		const TEST_ACCOUNT_1_BALANCE = +(await USDCproxy.balanceOf(TEST_ACCOUNT_1)).toString()
		assert.equal(TEST_ACCOUNT_1_BALANCE, DEPOSIT_AMOUNT, "Requester balance should equal deposit amount")

		await USDCproxy.approve(SWAP.address, SWAP_AMOUNT, { from: TEST_ACCOUNT_1 })
		assert.equal(+(await USDCproxy.allowance(TEST_ACCOUNT_1, SWAP.address)), SWAP_AMOUNT, "Allowance of swap contract should equal requester deposit amount");

	})

	it("Should allow the swap between the requester and the contract", async () => {
		await SWAPproxy.convert(USDCproxy.address, USDX.address, SWAP_AMOUNT, { from: TEST_ACCOUNT_1 })

		// const FEES = +(await USDC.calculateFees(SWAP_AMOUNT)) // NOTE: These fees only apply in testing due to Token X ERC20 dummy asset
		const SWAP_FEES = +(await SWAPproxy.calcAssetFees(USDCproxy.address, SWAP_AMOUNT));
		const NET_AMOUNT = (SWAP_AMOUNT-SWAP_FEES);
		const CONVERTED_AMOUNT = (NET_AMOUNT * (10 ** 2)) / (10 ** 6)
		const TEST_ACCOUNT_1_USDC_BALANCE = +(await USDCproxy.balanceOf(TEST_ACCOUNT_1)).toString()
		assert.equal(TEST_ACCOUNT_1_USDC_BALANCE, (DEPOSIT_AMOUNT-SWAP_AMOUNT), "Requester balance should be reduced by swap amount")

		const SWAP_CONTRACT_USDC_BALANCE = +(await USDCproxy.balanceOf(SWAP.address)).toString()
		assert.equal(SWAP_CONTRACT_USDC_BALANCE, (SWAP_AMOUNT), "Swap Balance of USDC should be equal to the swamp amount.")

		const TEST_ACCOUNT_1_USDX_BALANCE = +(await USDX.balanceOf(TEST_ACCOUNT_1)).toString()
		assert.equal(TEST_ACCOUNT_1_USDX_BALANCE, CONVERTED_AMOUNT, "Requester balance should equal requester deposit amount for USDX contract")
	})

	it("Should allow the swap between the requester and the contract in reverse", async () => {
		const SWAP_AMOUNT_2 = +(await USDX.balanceOf(TEST_ACCOUNT_1));

		await SWAPproxy.convert(USDX.address, USDCproxy.address, SWAP_AMOUNT_2, { from: TEST_ACCOUNT_1 })
		const CONVERTED_AMOUNT = (SWAP_AMOUNT_2 / (10 ** 2)) * (10 ** 6)
		const SWAP_FEES = +(await SWAPproxy.calcAssetFees(USDCproxy.address, CONVERTED_AMOUNT));

		const TEST_ACCOUNT_1_USDX_BALANCE = +(await USDX.balanceOf(TEST_ACCOUNT_1)).toString()
		assert.equal(TEST_ACCOUNT_1_USDX_BALANCE, 0, "Requester balance should be reduced by swap amount")

		const TEST_ACCOUNT_1_USDC_BALANCE = +(await USDCproxy.balanceOf(TEST_ACCOUNT_1)).toString()
		assert.equal(TEST_ACCOUNT_1_USDC_BALANCE, CONVERTED_AMOUNT-SWAP_FEES, "Requester balance should equal requester deposit amount for USDC contract")

		const SWAP_CONTRACT_USDC_BALANCE = +(await USDCproxy.balanceOf(SWAP.address)).toString()

		assert.equal(SWAP_CONTRACT_USDC_BALANCE, (
			+(await SWAPproxy.calcAssetFees(USDCproxy.address, SWAP_AMOUNT)) +
			+(await SWAPproxy.calcAssetFees(USDCproxy.address, CONVERTED_AMOUNT))
		), "Swap Balance of USDC should be equal to the swamp amount.")
	})

});
