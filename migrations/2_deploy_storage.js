var Storage = artifacts.require("./Storage.sol");
var MultiSig = artifacts.require("./MultiSig.sol");

module.exports = async (deployer) => {
  deployer.deploy(Storage).then(() => {
      return deployer.deploy(MultiSig, Storage.address)
  }).then(() => {
    console.log('Storage & MultiSig Contracts Deployed')
  }).catch((error) => {
    console.log('error', error)
  });


};
