// See <http://truffleframework.com/docs/advanced/configuration>

module.exports = {
  networks: {
    develop: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*" // Match any network id
    },
    // quorum: {
    //   host: "127.0.0.1",
    //   port: 8545,
    //   network_id: "*" // Match any network id
    // }
  }
};
