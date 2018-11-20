const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20FeesApply = artifacts.require("./TokenIOERC20FeesApply.sol")
const TokenIOProxyProvider = artifacts.require("./TokenIOProxyProvider.sol")

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
      await token.setParams(...Object.values(TOKEN_DETAILS['USDx']).map((v) => { return v }))

      /* proxy provider */
      const proxyProvider = await TokenIOProxyProvider.deployed()
      const proxy = await proxyProvider.getProxyContract('TokenIOERC20FeesApply')

      if (proxy != '0x0000000000000000000000000000000000000000') {
        proxyProvider.updateProxy(proxy, token.address, 'TokenIOERC20FeesApply')
      } else {
        proxyProvider.newProxy(token.address, 'TokenIOERC20FeesApply')
      }

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
