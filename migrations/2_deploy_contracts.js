var TokenIO = artifacts.require("./TokenIO.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

// NOTE: When using truffle console, if the config file changes ensure to restart
// truffle console before attempting to `migrate --reset` as the config Variables
// seem to be cached between each migration run.
// TODO: Report issue on truffle github

const { mode, development, production, tokenDetails } = require('../token.config.js');
const { admin, feeAccount } = mode == 'production' ? production : development;

const {
  tokenName,
  tokenSymbol,
  tokenTLA,
  tokenVersion,
  tokenDecimals
} = tokenDetails

module.exports = async function(deployer, network) {
	var token, storage;
	// Deploy SafeMath Library
	deployer.deploy(SafeMath).then(() => {
		// Link SafeMath library to both TokenIO & TokenIOLib
		return deployer.link(SafeMath, [ TokenIO ]);
	}).then(() => {
		// Deploy TokenIO
		return deployer.deploy(
      TokenIO,
      admin,
      feeAccount,
      tokenName,
      tokenSymbol,
      tokenTLA,
      tokenVersion,
      tokenDecimals
    )
	}).then((_token) => {
		token = _token
	}).catch((error) => {
		console.log('DEPLOYMENT ERROR: ', error)
	})
}
