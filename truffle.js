require('dotenv').config()
var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  networks: {
    develop: {
      host: "0.0.0.0",
      port: 9545,
      network_id: "*", // Match any network id
      gasLimit: 7e6
    },
    poa: {
      host: "104.236.47.153",
      port: 4000,
      network_id: 9, // Match any network id
	    gasLimit: 7e6
    },
    ropsten: {
      provider: new HDWalletProvider(process.env.PHRASE, `https://ropsten.infura.io/${process.env.INFURA_API}`),
      network_id: 3,
      gasLimit: 47e5
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};
