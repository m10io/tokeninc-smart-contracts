require('dotenv').config()
const HDWalletProvider = require("truffle-hdwallet-provider");
const NonceTrackerSubprovider = require("web3-provider-engine/subproviders/nonce-tracker")


module.exports = {
  networks: {
    develop: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "5777", // Match any network id
      gas: 6000000
    },
    poa: {
      host: "104.236.47.153",
      port: 4000,
      network_id: 9, // Match any network id
	    gas: 8e6
    },
    ropsten: {
      provider: () => {
        const wallet = new HDWalletProvider(process.env.PHRASE, `https://ropsten.infura.io/${process.env.INFURA_API}`);
        const nonceTracker = new NonceTrackerSubprovider();
        wallet.engine._providers.unshift(nonceTracker);
        nonceTracker.setEngine(wallet.engine);
        return wallet;
      },
      network_id: 3,
      gas: 8000000
    },
    mainnet: {
      provider: () => {
        const wallet = new HDWalletProvider(process.env.PHRASE, `https://mainnet.infura.io/${process.env.INFURA_API}`);
        const nonceTracker = new NonceTrackerSubprovider();
        wallet.engine._providers.unshift(nonceTracker);
        nonceTracker.setEngine(wallet.engine);
        return wallet;
      },
      network_id: 1,
      gas: 7e6,
      gasPrice: 10e9 // 10 gwei
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    version: '0.4.24'
  }
};
