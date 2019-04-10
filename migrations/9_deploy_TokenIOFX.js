const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOFX = artifacts.require("./TokenIOFX.sol")
const TokenIOFXProxy = artifacts.require("./TokenIOFXProxy.sol")

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* fx */
      const fx = await deployer.deploy(TokenIOFX, storage.address)
      await storage.allowOwnership(fx.address)

      const fxProxy = await deployer.deploy(TokenIOFXProxy, fx.address)
      fx.initProxy(fxProxy.address)

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
