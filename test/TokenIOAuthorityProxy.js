var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOAuthorityProxy = artifacts.require("./TokenIOAuthorityProxy.sol");


const { mode, development, production } = require('../token.config.js');
const {
    AUTHORITY_DETAILS: { firmName, authorityAddress },
    TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS['USDx']

contract("TokenIOAuthorityProxy", function(accounts) {

    // Global Test Variables;
    const AUTHORITY_ACCOUNT_0 = accounts[0];
    const AUTHORITY_ACCOUNT_1 = accounts[1];
    const FIRM_NAME = firmName;
    const NEW_FIRM_NAME = "Test Firm, L.L.C."
    const AUTHORITY_ACCOUNT_2 = accounts[2];
    const AUTHORITY_ACCOUNT_3 = accounts[3];

    before(async function () {
      this.tokenIOAuthorityProxy = await TokenIOAuthorityProxy.deployed();
    });

    describe("Should confirm AUTHORITY_ACCOUNT has been set appropriately", function () {
      it("Should pass", async function () {
        const isAuthorized = await this.tokenIOAuthorityProxy.isRegisteredToFirm(FIRM_NAME, AUTHORITY_ACCOUNT_0);
        assert.equal(isAuthorized, true, "Authority firm and address should be authorized");
      });
    })

    describe("Should confirm FIRM_NAME has been set appropriately", function () {
      it("Should pass", async function () {
        const authorityFirm = await this.tokenIOAuthorityProxy.getFirmFromAuthority(AUTHORITY_ACCOUNT_0);
        assert.equal(authorityFirm, FIRM_NAME, "Authority firm should be set to the firmName");
      })
    })

    describe("Should confirm non-authority is not authorized", function () {
      it("Should pass", async function () {
        const isAuthorized = await this.tokenIOAuthorityProxy.isRegisteredAuthority(AUTHORITY_ACCOUNT_1);
        assert.equal(isAuthorized, false, "Non registered account should not be authorized");
      })
    })

    describe("Should register a new firm and a firm authority", function () {
      it("Should pass", async function () {
        const NEW_FIRM_TX = await this.tokenIOAuthorityProxy.setRegisteredFirm(NEW_FIRM_NAME, true)
        const NEW_AUTHORITY_TX = await this.tokenIOAuthorityProxy.setRegisteredAuthority(NEW_FIRM_NAME, AUTHORITY_ACCOUNT_2, true)

        assert.equal(NEW_FIRM_TX['receipt']['status'], "0x1", "Transaction should succeed")
        assert.equal(NEW_AUTHORITY_TX['receipt']['status'], "0x1", "Transaction should succeed")

        const isRegisteredFirm = await this.tokenIOAuthorityProxy.isRegisteredFirm(NEW_FIRM_NAME);
        assert.equal(isRegisteredFirm, true, "New firm should be registered");

        const isAuthorized = await this.tokenIOAuthorityProxy.isRegisteredToFirm(NEW_FIRM_NAME, AUTHORITY_ACCOUNT_2);
        assert.equal(isAuthorized, true, "Authority firm and address should be authorized");
      })
    })

    describe("Should allow AUTHORITY_ACCOUNT_2 to register AUTHORITY_ACCOUNT_1 to NEW_FIRM_NAME", function () {
      it("Should pass", async function () {
        const NEW_AUTHORITY_TX = await this.tokenIOAuthorityProxy.setRegisteredAuthority(NEW_FIRM_NAME, AUTHORITY_ACCOUNT_1, true, { from: AUTHORITY_ACCOUNT_2 })

        assert.equal(NEW_AUTHORITY_TX['receipt']['status'], "0x1", "Transaction should succeed")

        const isAuthorized = await this.tokenIOAuthorityProxy.isRegisteredToFirm(NEW_FIRM_NAME, AUTHORITY_ACCOUNT_1);
        assert.equal(isAuthorized, true, "Authority firm and address should be authorized");
      })
    })

    describe('staticCall', function () {
      it('Should pass', async function () {
        const payload = web3.eth.abi.encodeFunctionCall({
            name: 'isRegisteredAuthority',
            type: 'function',
            inputs: [{
                type: 'address',
                name: 'authority'
            }]
        }, [AUTHORITY_ACCOUNT_3]);
        const encodedResult = await this.tokenIOAuthorityProxy.staticCall(payload);
        const result = web3.eth.abi.decodeParameters(['bool'], encodedResult);
        assert.equal(result[0], false)
      });
    });

    describe('call', function () {
      it('Should fail due to proxy is not an owner of logic contract', async function () {
        const payload = web3.eth.abi.encodeFunctionCall({
            name: 'setMasterFeeContract',
            type: 'function',
            inputs: [{
                type: 'address',
                name: 'feeContract'
            }]
        }, [accounts[4]]);

        await this.tokenIOAuthorityProxy.call(payload);
      });
    });



});
