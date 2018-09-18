var { utils } = require('ethers');
var Promise = require('bluebird')
var TokenIOAuthority = artifacts.require("./TokenIOAuthority.sol");

const { mode, development, production } = require('../token.config.js');
const {
    AUTHORITY_DETAILS: { firmName, authorityAddress },
    TOKEN_DETAILS
} = mode == 'production' ? production : development;

const USDx = TOKEN_DETAILS['USDx']

contract("TokenIOAuthority", function(accounts) {

    // Global Test Variables;
    const AUTHORITY_ACCOUNT_0 = accounts[0];
    const AUTHORITY_ACCOUNT_1 = accounts[1];
    const FIRM_NAME = firmName;
    const NEW_FIRM_NAME = "Test Firm, L.L.C."
    const AUTHORITY_ACCOUNT_2 = accounts[2];


    it("Should confirm AUTHORITY_ACCOUNT has been set appropriately", async () => {
        const authority = await TokenIOAuthority.deployed();
        const isAuthorized = await authority.isRegisteredToFirm(FIRM_NAME, AUTHORITY_ACCOUNT_0);
        assert.equal(isAuthorized, true, "Authority firm and address should be authorized");
    });

    it("Should confirm FIRM_NAME has been set appropriately", async () => {
        const authority = await TokenIOAuthority.deployed();
        const authorityFirm = await authority.getFirmFromAuthority(AUTHORITY_ACCOUNT_0);
        assert.equal(authorityFirm, FIRM_NAME, "Authority firm should be set to the firmName");
    })

    it("Should confirm non-authority is not authorized", async () => {
        const authority = await TokenIOAuthority.deployed();
        const isAuthorized = await authority.isRegisteredAuthority(AUTHORITY_ACCOUNT_1);
        assert.equal(isAuthorized, false, "Non registered account should not be authorized");
    })

    it("Should register a new firm and a firm authority", async () => {
        const authority = await TokenIOAuthority.deployed();
        const NEW_FIRM_TX = await authority.setRegisteredFirm(NEW_FIRM_NAME, true)
        const NEW_AUTHORITY_TX = await authority.setRegisteredAuthority(NEW_FIRM_NAME, AUTHORITY_ACCOUNT_2, true)

        assert.equal(NEW_FIRM_TX['receipt']['status'], "0x1", "Transaction should succeed")
        assert.equal(NEW_AUTHORITY_TX['receipt']['status'], "0x1", "Transaction should succeed")

        const isRegisteredFirm = await authority.isRegisteredFirm(NEW_FIRM_NAME);
        assert.equal(isRegisteredFirm, true, "New firm should be registered");

        const isAuthorized = await authority.isRegisteredToFirm(NEW_FIRM_NAME, AUTHORITY_ACCOUNT_2);
        assert.equal(isAuthorized, true, "Authority firm and address should be authorized");

    })

    it("Should allow AUTHORITY_ACCOUNT_2 to register AUTHORITY_ACCOUNT_1 to NEW_FIRM_NAME", async () => {
        const authority = await TokenIOAuthority.deployed();
        const NEW_AUTHORITY_TX = await authority.setRegisteredAuthority(NEW_FIRM_NAME, AUTHORITY_ACCOUNT_1, true, { from: AUTHORITY_ACCOUNT_2 })

        assert.equal(NEW_AUTHORITY_TX['receipt']['status'], "0x1", "Transaction should succeed")

        const isAuthorized = await authority.isRegisteredToFirm(NEW_FIRM_NAME, AUTHORITY_ACCOUNT_1);
        assert.equal(isAuthorized, true, "Authority firm and address should be authorized");

    })



});
