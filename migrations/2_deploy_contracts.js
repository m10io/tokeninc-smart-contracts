const { delay } = require('bluebird')

const SafeMath = artifacts.require("./SafeMath.sol")
const TokenIOLib = artifacts.require("./TokenIOLib.sol")
const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOERC20 = artifacts.require("./TokenIOERC20.sol")
const TokenIOAuthority = artifacts.require("./TokenIOAuthority.sol")
const TokenIOFX = artifacts.require("./TokenIOFX.sol")
const TokenIOCurrencyAuthority = artifacts.require("./TokenIOCurrencyAuthority.sol")
const TokenIOFeeContract = artifacts.require("./TokenIOFeeContract.sol")
const TokenIOMerchant = artifacts.require("./TokenIOMerchant.sol")

const { mode, development, production } = require('../token.config.js');
const {
    AUTHORITY_DETAILS: { firmName, authorityAddress },
    TOKEN_DETAILS,
    FEE_PARAMS
} = mode == 'production' ? production : development;

const deployContracts = async (deployer, accounts) => {
  try {
      /* library */
      // const safeMath = await deployer.deploy(SafeMath)
      // await deployer.link(SafeMath, [TokenIOLib])
      // const tokenIOLib = await deployer.deploy(TokenIOLib)
      await deployer.link(TokenIOLib,
          [TokenIOStorage, TokenIOERC20, TokenIOAuthority, TokenIOCurrencyAuthority, TokenIOFX, TokenIOFeeContract])

      /* storage */
      const storage = await TokenIOStorage.deployed() // await deployer.deploy(TokenIOStorage)

      /* master fee contract */
      // const masterFeeContract = await deployer.deploy(TokenIOFeeContract, storage.address)
      // await storage.allowOwnership(masterFeeContract.address)
      // await masterFeeContract.setFeeParams(...Object.keys(FEE_PARAMS).map((p) => { return FEE_PARAMS[p] }))

      /* authority contracts */
      // const authority = await deployer.deploy(TokenIOAuthority, storage.address)
      // await storage.allowOwnership(authority.address)
      // const currencyAuthority = await deployer.deploy(TokenIOCurrencyAuthority, storage.address)
      // await storage.allowOwnership(currencyAuthority.address)

      /* merchant contract */
      // const merchant = await deployer.deploy(TokenIOMerchant, storage.address)
      // await storage.allowOwnership(merchant.address)
      // await merchant.setParams(masterFeeContract.address)

      /* fx */
      // const fx = await deployer.deploy(TokenIOFX, storage.address)
      // await storage.allowOwnership(fx.address)

      /* registration */
      // await authority.setRegisteredFirm(firmName, true)
      // await authority.setRegisteredAuthority(firmName, accounts[0], true)
      // await authority.setMasterFeeContract(masterFeeContract.address)

      /* token */
      const token = await deployer.deploy(TokenIOERC20, storage.address)
      await storage.allowOwnership(token.address)
      await token.setParams(...Object.values(TOKEN_DETAILS['USDx']).map((v) => { return v }))

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
