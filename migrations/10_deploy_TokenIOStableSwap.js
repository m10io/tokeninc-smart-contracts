const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOStableSwap = artifacts.require("./TokenIOStableSwap.sol")
const TokenIOERC20 = artifacts.require("./TokenIOERC20.sol")

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* fx */
      const swap = await deployer.deploy(TokenIOStableSwap, storage.address)

      await storage.allowOwnership(swap.address)

      // Allow USD asset
      const usdx = await TokenIOERC20.deployed();
      const params = [ usdx.address, await usdx.tla() ]
      await swap.setTokenXCurrency(...params);

      console.log('isAllowed', await swap.isAllowedAsset(...params))

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
