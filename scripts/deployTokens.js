var Promise = require('bluebird')
var fs = require('fs').promises

var TokenIOStorage = artifacts.require("./TokenIOStorage.sol");
var TokenIOERC20 = artifacts.require("./TokenIOERC20.sol");

const { mode, development, production } = require('../token.config.js');
const { TOKEN_DETAILS } = mode == 'production' ? production : development;

function deployTokens() {
    return new Promise((resolve, reject) => {
        const tokens = TOKEN_DETAILS;
        var storage, deployed = {}

        Promise.resolve(TokenIOStorage.deployed()).then((instance) => {
            storage = instance
            return Promise.resolve(tokens)
        }).map((token) => {
            return TokenIOERC20.new(storage.address)
        }).map( async (_token, i) => {
            deployed[i] = _token
            // Allow ERC20 contract to use the Storage contract
            const params = Object.keys(tokens[i]).map((k) => { return tokens[i][k] })
            const allowed = await storage.allowOwnership(deployed[i].address)
            const initialized = await _token.setParams(...params)
            console.log(`Deployed TokenIOERC20 ${params[0]} Contract -- ${mode}`)
            return null;
        }).then(() => {
            return resolve(deployed)
        }).catch((error) => {
            return reject(error)
        })
    })
}

function saveTokenDetails(deployed) {
    return new Promise( async (resolve, reject) => {
        const { abi, bytecode, contractName } = deployed[0].constructor._json
        var details = {
            abi,
            bytecode,
            contractName,
            addresses: []
        }

        const fileName = `${contractName}--${mode}.json`

        Promise.resolve(Object.keys(deployed)).map((i) => {
            const { address } = deployed[i]
            details.addresses[i] = address
            return null
        }).then(() => {
            return fs.writeFile(`${process.cwd()}/deployed/${fileName}`, JSON.stringify(details), {
                encoding: 'utf8',
                flag: 'w'
            })
        }).then(() => {
            return resolve(true)
        }).catch((error) => {
            return reject(error)
        })
    })
}

module.exports = async function(done) {
    try {
        const deployed = await deployTokens()
        const saved = await saveTokenDetails(deployed)
        console.log(`TokenIOERC20 Contracts Deployed -- ${mode}`)
        done()
    } catch (error) {
        console.log('error', error)
    }
}
