const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol")

const deployContracts = async (deployer, accounts) => {
  try {

      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* authority contracts */
      const currencyAuthority = await deployer.deploy(TokenIOCurrencyAuthority, storage.address)
      await storage.allowOwnership(currencyAuthority.address)

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
