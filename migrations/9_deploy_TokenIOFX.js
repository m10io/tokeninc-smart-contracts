const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOFX = artifacts.require("./TokenIOFX.sol")
const TokenIOProxyProvider = artifacts.require("./TokenIOProxyProvider.sol")

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* fx */
      const fx = await deployer.deploy(TokenIOFX, storage.address)
      await storage.allowOwnership(fx.address)

      /* proxy provider */
      const proxyProvider = await TokenIOProxyProvider.deployed()
      const proxy = await proxyProvider.getProxyContract('TokenIOFX')

      if (proxy != '0x0000000000000000000000000000000000000000') {
        proxyProvider.updateProxy(proxy, fx.address, 'TokenIOFX')
      } else {
        proxyProvider.newProxy(fx.address, 'TokenIOFX')
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
