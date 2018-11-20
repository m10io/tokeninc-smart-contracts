const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol")
const TokenIOProxyProvider = artifacts.require("./TokenIOProxyProvider.sol")

const deployContracts = async (deployer, accounts) => {
  try {

      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* authority contracts */
      const currencyAuthority = await deployer.deploy(TokenIOCurrencyAuthority, storage.address)
      await storage.allowOwnership(currencyAuthority.address)

      /* proxy provider */
      const proxyProvider = await TokenIOProxyProvider.deployed()
      const proxy = await proxyProvider.getProxyContract('TokenIOCurrencyAuthority')

      if (proxy != '0x0000000000000000000000000000000000000000') {
        proxyProvider.updateProxy(proxy, currencyAuthority.address, 'TokenIOCurrencyAuthority')
      } else {
        proxyProvider.newProxy(currencyAuthority.address, 'TokenIOCurrencyAuthority')
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
