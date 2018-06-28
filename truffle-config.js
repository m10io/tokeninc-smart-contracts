// See <http://truffleframework.com/docs/advanced/configuration>

module.exports = {
  networks: {
    develop: {
      host: "0.0.0.0",
      port: 9545,
      network_id: "*", // Match any network id
      gasLimit: 7e9
    },
    poa: {
      host: "104.236.47.153",
      port: 4000,
      network_id: 9, // Match any network id
	  gasLimit: 7e9
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};
