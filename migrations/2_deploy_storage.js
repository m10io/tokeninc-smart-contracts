var Storage = artifacts.require("./Storage.sol");
var MultiSig = artifacts.require("./MultiSig.sol");

/**
 * NOTE: Check if this deployment sequence will work when migrating to the
 * quorum network. Reason(s) why it may not work
 *
 * 1. Will the `privateFor` field in the transaction object be valid in Truffle--
 * And do we even need it? E.g. do we only want to make certain transactions private
 * when interacting with the contract. TBD

 */

module.exports = async (deployer) => {
  deployer.deploy(Storage).then(() => {
      return deployer.deploy(MultiSig, Storage.address)
  }).then(() => {
    console.log('Storage & MultiSig Contracts Deployed')
  }).catch((error) => {
    console.log('error', error)
  });


};
