// See <http://truffleframework.com/docs/advanced/configuration>

module.exports = {
  networks: {
    develop: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*" // Match any network id
    },
    quorum: {
      host: "40.125.64.9",
      port: 22000,
      network_id: "*", // Match any network id
      gasPrice: 0,
      gas: 4500000
    }
  }
};
