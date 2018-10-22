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
      const safeMath = await deployer.deploy(SafeMath)

      await deployer.link(SafeMath, [TokenIOLib])
      const tokenIOLib = await deployer.deploy(TokenIOLib)

      await deployer.link(TokenIOLib,
          [TokenIOStorage, TokenIOERC20, TokenIOAuthority, TokenIOCurrencyAuthority, TokenIOFX, TokenIOFeeContract])

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
