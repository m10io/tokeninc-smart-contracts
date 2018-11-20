const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOAuthority = artifacts.require("./TokenIOAuthority.sol")
const TokenIOFeeContract = artifacts.require("./TokenIOFeeContract.sol")
const TokenIOProxyProvider = artifacts.require("./TokenIOProxyProvider.sol")

const { mode, development, production } = require('../token.config.js');
const {
    AUTHORITY_DETAILS: { firmName, authorityAddress },
    FEE_PARAMS
} = mode == 'production' ? production : development;

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* master fee contract */
      const masterFeeContract = await deployer.deploy(TokenIOFeeContract, storage.address)
      await storage.allowOwnership(masterFeeContract.address)
      await masterFeeContract.setFeeParams(...Object.keys(FEE_PARAMS).map((p) => { return FEE_PARAMS[p] }))

      /* authority contracts */
      const authority = await deployer.deploy(TokenIOAuthority, storage.address)
      await storage.allowOwnership(authority.address)

      /* registration */
      await authority.setRegisteredFirm(firmName, true)
      await authority.setRegisteredAuthority(firmName, accounts[0], true)
      await authority.setMasterFeeContract(masterFeeContract.address)

      /* proxy provider */
      const proxyProvider = await TokenIOProxyProvider.deployed()
      const proxy = await proxyProvider.getProxyContract('TokenIOAuthority')

      if (proxy != '0x0000000000000000000000000000000000000000') {
        proxyProvider.updateProxy(proxy, authority.address, 'TokenIOAuthority')
      } else {
        proxyProvider.newProxy(authority.address, 'TokenIOAuthority')
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
