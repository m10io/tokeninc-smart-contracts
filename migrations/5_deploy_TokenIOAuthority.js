const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOAuthority = artifacts.require("./TokenIOAuthority.sol")

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

      /* registration */
      await authority.setRegisteredFirm(firmName, true)
      await authority.setRegisteredAuthority(firmName, accounts[0], true)
      await authority.setMasterFeeContract(masterFeeContract.address)

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
