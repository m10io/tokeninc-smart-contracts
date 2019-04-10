const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOAuthority = artifacts.require("./TokenIOAuthority.sol")
const TokenIOAuthorityProxy = artifacts.require("./TokenIOAuthorityProxy.sol")
const TokenIOFeeContractProxy = artifacts.require("./TokenIOFeeContractProxy.sol")

const { mode, development, production } = require('../token.config.js');
const {
    AUTHORITY_DETAILS: { firmName, authorityAddress },
} = mode == 'production' ? production : development;

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* authority contracts */
      const authority = await deployer.deploy(TokenIOAuthority, storage.address)
      await storage.allowOwnership(authority.address)

      const authorityProxy = await deployer.deploy(TokenIOAuthorityProxy, authority.address)

      await authority.initProxy(authorityProxy.address)

      const masterFeeContractProxy = await TokenIOFeeContractProxy.deployed()

      /* registration */
      await authorityProxy.setRegisteredFirm(firmName, true)
      await authorityProxy.setRegisteredAuthority(firmName, accounts[0], true)
      await authority.setMasterFeeContract(masterFeeContractProxy.address)

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
