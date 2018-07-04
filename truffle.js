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
        provider: new HDWalletProvider(process.env.PHRASE, `https://ropsten.infura.io/kFvVxuVal7BFFAQuxgxi`),
        network_id: 3,
        gasLimit: 7e6
      }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};
