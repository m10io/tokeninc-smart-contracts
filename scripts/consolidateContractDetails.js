var Promise = require('bluebird')
var fs = require('fs').promises

const DIR_PATH = `${process.cwd()}/build/contracts`

async function readContractJSON(file) {
	try {
		const details = JSON.parse(await fs.readFile(`${DIR_PATH}/${file}`, {
			encoding: 'utf8',
		}))

		return details
	} catch (error) {
		return error
	}
}

async function readContractBuildDir() {
	try {
		const files = await fs.readdir(DIR_PATH)
		return files
	} catch (error) {
		console.log('error', error)
		return error
	}
}


async function main() {
		try {
				const files = await readContractBuildDir()
				console.log('files', files)
				var ContractInfo = {}
				await Promise.all(
						files.map(async file => {
								return await readContractJSON(file)
						})
				).map(async interface => {
					const { bytecode, abi, contractName } = interface
					ContractInfo[contractName] = { abi, bytecode }
					return { bytecode, abi, contractName }
				}).then(async () => {
					console.log('Save Contract Info: ', ContractInfo)
					return await fs.writeFile(`${process.cwd()}/deployed/contracts.json`, JSON.stringify(ContractInfo), {
						encoding: 'utf8',
						flag: 'w'
					})
				})
		} catch (err) {
				console.log('error', error)
		}
}

main()

// readContractBuildDir().map((file) => {
// 	return readContractJSON(file)
// }).map((details) => {
// 	console.log('details', details)
// 	return null
// }).then(() => {
// 	console.log('finished')
// }).catch((error) => {
// 	console.log('error', error)
// })
