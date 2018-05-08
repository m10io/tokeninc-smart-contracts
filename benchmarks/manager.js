const Promise = require('bluebird')
const fork = require('child_process').fork


const workers = {
  0: fork('./sendTransaction.js'),
  1: fork('./sendTransaction.js'),
  2: fork('./sendTransaction.js')
}

const accounts = [{
    account: "0xed9d02e382b34818e88b88a309c7fe71e65f419d",
    rpc: "http://40.125.64.9:22000"
  }, {
    account: "0xca843569e3427144cead5e4d5999a3d0ccf92b8e",
    rpc: "http://40.125.64.9:22001"
  }, {
    account: "0x9186eb3d20cbd1f5f992a950d808c4495153abd5",
    rpc: "http://40.125.64.9:22003"
  }]

function sendWork({ worker, fromAccount, rpc }) {
  return new Promise((resolve, reject) => {
    try {
      workers[worker].on('message', (msg) => {
        return resolve(true)
      });

      workers[worker].on('error', (error) => {
        console.log('error', error)
      });

      workers[worker].send({ fromAccount, rpc });
    } catch (error) {
      return reject(error)
    }
  })
}


Promise.resolve(accounts).map((data, i) => {
  const { account, rpc } = data
  console.time('sendTransaction-benchmark')
  return sendWork({
    worker: i,
    fromAccount: account,
    rpc
  })
}).then(() => {
  console.timeEnd('sendTransaction-benchmark')
  console.log('finished')
  process.exit(0)
}).catch((error) => {
  console.log(error)
  process.exit(1)
})
