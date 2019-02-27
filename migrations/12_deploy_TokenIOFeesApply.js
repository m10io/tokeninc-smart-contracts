const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20FeesApply = artifacts.require("./TokenIOERC20FeesApply.sol")
const TokenIOERC20FeesApplyProxy = artifacts.require("./TokenIOERC20FeesApplyProxy.sol")

const { mode, development, production } = require('../token.config.js');
const {
    AUTHORITY_DETAILS: { firmName, authorityAddress },
    TOKEN_DETAILS
} = mode == 'production' ? production : development;

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* token */
      const token = await deployer.deploy(TokenIOERC20FeesApply, storage.address)
      await storage.allowOwnership(token.address)

      const tokenProxy = await deployer.deploy(TokenIOERC20FeesApplyProxy, token.address, "0x00")
      await token.allowOwnership(tokenProxy.address)
      await token.initProxy(tokenProxy.address)

      await tokenProxy.setParams(...Object.values(TOKEN_DETAILS['USDx']).map((v) => { return v }))

      return true
  } catch (err) {
      console.log('### error deploying contracts', err)
  }
}


module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        await deployContracts(deployer, accounts)
        console.log('### finished deploying contracts')
    })
    .catch(err => console.log('### error deploying contracts', err))
}
