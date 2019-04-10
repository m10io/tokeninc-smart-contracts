const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOFeeContract = artifacts.require("./TokenIOFeeContract.sol")
const TokenIOFeeContractProxy = artifacts.require("./TokenIOFeeContractProxy.sol")

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
      const masterFeeContractProxy = await deployer.deploy(TokenIOFeeContractProxy, masterFeeContract.address)
      await storage.allowOwnership(masterFeeContract.address)
      await masterFeeContract.initProxy(masterFeeContractProxy.address)
      await masterFeeContract.setFeeParams(...Object.keys(FEE_PARAMS).map((p) => { return FEE_PARAMS[p] }))

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
