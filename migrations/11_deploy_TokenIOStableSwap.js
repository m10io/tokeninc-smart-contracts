const { delay } = require('bluebird')

const TokenIOStorage = artifacts.require("./TokenIOStorage.sol")
const TokenIOStableSwap = artifacts.require("./TokenIOStableSwap.sol")
const TokenIOStableSwapProxy = artifacts.require("./TokenIOStableSwapProxy.sol")
const TokenIOERC20Proxy = artifacts.require("./TokenIOERC20Proxy.sol")
const TokenIOERC20UnlimitedProxy = artifacts.require("./TokenIOERC20UnlimitedProxy.sol")

const deployContracts = async (deployer, accounts) => {
  try {
      /* storage */
      const storage = await TokenIOStorage.deployed()

      /* fx */
      const swap = await deployer.deploy(TokenIOStableSwap, storage.address)

      await storage.allowOwnership(swap.address)

      const swapProxy = await deployer.deploy(TokenIOStableSwapProxy, swap.address)

      await swap.initProxy(swapProxy.address)

      // Allow USD asset
      const usdx = await TokenIOERC20Proxy.deployed();
      const params1 = [ usdx.address, await usdx.tla() ]
      await swap.setTokenXCurrency(...params1);

      // Allow other interfaces for USDx
      const usdxUnlimited = await TokenIOERC20UnlimitedProxy.deployed();
      const params2 = [ usdxUnlimited.address, await usdxUnlimited.tla() ]
      await swap.setTokenXCurrency(...params2);

      // Allow USDC
      // NOTE: Fees must be in the decimal representation of the asset
      const USDC = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";
      const feeBps = 10;
      const feeMin = 0;
      const feeMax = 1e12; // $1 million max fee; (6 decimal representation)
      const feeFlat = 0;
      const params3 = [ USDC, "USD",  feeBps, feeMin, feeMax, feeFlat ]
      await swap.allowAsset(...params3);

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
