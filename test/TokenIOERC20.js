var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");

const { mode, development, production } = require('../token.config.js');
const {
  AUTHORITY_DETAILS: { firmName, authorityAddress },
  TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS[0]


// [ ] - Should ensure erc20 compliance
// [ ] - Should ensure all values are set in the storage contract

contract("TokenIOERC20", function(accounts) {

  // Global Test Variables;
  const TEST_ACCOUNT_1 = accounts[1];
  const TEST_ACCOUNT_2 = accounts[2];

  //
  const TOKEN_NAME = USDx.tokenName;
  const TOKEN_SYMBOL = USDx.tokenSymbol
  const TOKEN_TLA = USDx.tokenTLA
  const TOKEN_VERSION = USDx.tokenVersion
  const TOKEN_DECIMALS = USDx.tokenDecimals
  const TOKEN_FEE_BPS = USDx.feeBps
  const TOKEN_FEE_MIN = USDx.feeMin
  const TOKEN_FEE_MAX = USDx.feeMax
  const TOKEN_FEE_FLAT = USDx.feeFlat
  const TOKEN_FEE_ACCOUNT = USDx.feeAccount

  it("Should ensure the token params are set.", async () => {
    const erc20 = await TokenIOERC20.deployed();
    const name = await erc20.name();
    const symbol = await erc20.symbol();
    const tla = await erc20.tla();
    const version = await erc20.version();
    const decimals = await erc20.decimals();

    assert.equal(name, TOKEN_NAME, "Token name should be set in the storage contract.");
    assert.equal(symbol, TOKEN_SYMBOL, "Token symbol should be set in the storage contract.");
    assert.equal(tla, TOKEN_TLA, "Token tla should be set in the storage contract.");
    assert.equal(version, TOKEN_VERSION, "Token version should be set in the storage contract.");
    assert.equal(decimals, TOKEN_DECIMALS, "Token decimals should be set in the storage contract.");
  });


  it("Should ensure the token fee params are set.", async () => {
    const erc20 = await TokenIOERC20.deployed();

    const feeParams = await erc20.getFeeParams()
    const feeBps = feeParams[0]
    const feeMin = feeParams[1]
    const feeMax = feeParams[2]
    const feeFlat = feeParams[3]
    const feeAccount = feeParams[4]

    assert.equal(feeBps, TOKEN_FEE_BPS, "Token feeBps should be set in the storage contract.");
    assert.equal(feeMin, TOKEN_FEE_MIN, "Token feeMin should be set in the storage contract.");
    assert.equal(feeMax, TOKEN_FEE_MAX, "Token feeMax should be set in the storage contract.");
    assert.equal(feeFlat, TOKEN_FEE_FLAT, "Token feeFlat should be set in the storage contract.");
    assert.equal(feeAccount, TOKEN_FEE_ACCOUNT, "Token feeAccount should be set in the storage contract.");
  });



  // it("Should... ", async () => {
  //   const erc20 = await TokenIOERC20.deployed();
  //   assert.equal(true, true "True is True");
  // });
  //
  // it("Should... ", async () => {
  //   const erc20 = await TokenIOERC20.deployed();
  //   assert.equal(true, true "True is True");
  // });

});
