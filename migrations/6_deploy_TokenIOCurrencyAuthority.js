const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol")
const TokenIOCurrencyAuthorityProxy = artifacts.require("./TokenIOCurrencyAuthorityProxy.sol")

const deployContracts = async (deployer, accounts) => {
  try {

      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* authority contracts */
      const currencyAuthority = await deployer.deploy(TokenIOCurrencyAuthority, storage.address)
      await storage.allowOwnership(currencyAuthority.address)
      const currencyAuthorityProxy = await deployer.deploy(TokenIOCurrencyAuthorityProxy, currencyAuthority.address, "0x00")

      await currencyAuthority.allowOwnership(currencyAuthorityProxy.address)
      await currencyAuthority.initProxy(currencyAuthorityProxy.address)

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
