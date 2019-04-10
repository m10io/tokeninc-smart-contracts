const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20Unlimited = artifacts.require("./TokenIOERC20Unlimited.sol")
const TokenIOERC20UnlimitedProxy = artifacts.require("./TokenIOERC20UnlimitedProxy.sol")

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
      const token = await deployer.deploy(TokenIOERC20Unlimited, storage.address)
      await storage.allowOwnership(token.address)

      const tokenProxy = await deployer.deploy(TokenIOERC20UnlimitedProxy, token.address)
      await token.initProxy(tokenProxy.address)

      await token.setParams(...Object.values(TOKEN_DETAILS['USDx']).map((v) => { return v }))

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
