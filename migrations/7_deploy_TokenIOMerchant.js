const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOFeeContract = artifacts.require("./TokenIOFeeContract.sol")
const TokenIOMerchant = artifacts.require("./TokenIOMerchant.sol")

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* master fee contract */
      const masterFeeContract = await deployer.deployed(TokenIOFeeContract)

      /* merchant contract */
      const merchant = await deployer.deploy(TokenIOMerchant, storage.address)
      await storage.allowOwnership(merchant.address)
      await merchant.setParams(masterFeeContract.address)

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
