const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      await deployer.deploy(TokenIOStorage)

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
