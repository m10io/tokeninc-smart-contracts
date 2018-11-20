const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOFeeContract = artifacts.require("./TokenIOFeeContract.sol")
const TokenIOMerchant = artifacts.require("./TokenIOMerchant.sol")
const TokenIOProxyProvider = artifacts.require("./TokenIOProxyProvider.sol")

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* master fee contract */
      const masterFeeContract = await TokenIOFeeContract.deployed()

      /* merchant contract */
      const merchant = await deployer.deploy(TokenIOMerchant, storage.address)
      await storage.allowOwnership(merchant.address)
      await merchant.setParams(masterFeeContract.address)

      /* proxy provider */
      const proxyProvider = await TokenIOProxyProvider.deployed()
      const proxy = await proxyProvider.getProxyContract('TokenIOMerchant')

      if (proxy != '0x0000000000000000000000000000000000000000') {
        proxyProvider.updateProxy(proxy, merchant.address, 'TokenIOMerchant')
      } else {
        proxyProvider.newProxy(merchant.address, 'TokenIOMerchant')
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
