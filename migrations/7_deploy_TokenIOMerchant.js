const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOFeeContractProxy = artifacts.require("./TokenIOFeeContractProxy.sol")
const TokenIOMerchant = artifacts.require("./TokenIOMerchant.sol")
const TokenIOMerchantProxy = artifacts.require("./TokenIOMerchantProxy.sol")

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* master fee contract */
      const masterFeeContractProxy = await TokenIOFeeContractProxy.deployed()

      /* merchant contract */
      const merchant = await deployer.deploy(TokenIOMerchant, storage.address)
      await storage.allowOwnership(merchant.address)
      const merchantProxy = await deployer.deploy(TokenIOMerchantProxy, merchant.address)
      await merchant.initProxy(merchantProxy.address)

      await merchant.setParams(masterFeeContractProxy.address)

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
