const SafeMath = artifacts.require("./SafeMath.sol")
const TokenIOLib = artifacts.require("./TokenIOLib.sol")
const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20 = artifacts.require("./TokenIOERC20.sol")
const TokenIOAuthority = artifacts.require("./TokenIOAuthority.sol")
const TokenIOFX = artifacts.require("./TokenIOFX.sol")
const TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol")


module.exports = function(deployer, network, accounts) {
    return deployContracts(deployer)
    .then(() => console.log('### successfully deployed contracts!'))
    .catch(err => console.log('error deploying contracts', err))
}

const deployContracts = async (deployer) => {
  try {
      /* deploy base contracts */
      await deployer.deploy(SafeMath)
      await deployer.link(SafeMath, [TokenIOLib])
      await deployer.deploy(TokenIOLib)
      await deployer.link(TokenIOLib, [TokenIOStorage])
      const storage = await deployer.deploy(TokenIOStorage)
      const token = await deployer.deploy(TokenIOERC20, storage.address)
      return true
  } catch (err) {
      console.log('error deploying contracts', err)
  }
}
