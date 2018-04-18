const Web3 = require('web3')
const Promise = require('bluebird')

const NUM_TX_PER_ACCOUNT = 500

// Receiving Accounts
const RECEIVING_ACCOUNTS = [
  "0x8520de2650e91063882a2f45dD16CC80224BC451",
  "0x7BdD73C8A76B67B2E78dDE46BD18468341063Ed5",
  "0xAf2554cBd0f1E6ecEd368A206a8714bdE162327a"
]

function benchSendTransaction({ web3, from, to, nonce, counter }) {
  return new Promise((resolve, reject) => {
    if (counter == 0) {
      return resolve(true)
    } else {
      // console.time(`eth.sendTransaction, nonce: ${nonce}`)
      web3.eth.sendTransaction({ from, to, value: 1e2 })
        // .once('transactionHash', (txHash) => { console.log('txHash', txHash) })
        // .once('receipt', (receipt) => { console.log('receipt', receipt) })
        // .on('confirmation', (confirmation, receipt) => { console.log('confirmation, receipt', confirmation, receipt) })
        .on('error', (error) => { return reject(error) })
        .then((receipt) => {
          // console.timeEnd(`eth.sendTransaction, nonce: ${nonce}`)
          return resolve(benchSendTransaction({
            web3,
            from,
            to,
            nonce: nonce += 1,
            counter: counter -= 1
          }))
        })
    }
  })
}

process.on('message', (msg) => {
  const { fromAccount, rpc} = msg
  const web3 = new Web3(rpc);

  let nonce;

  Promise.resolve(web3.eth.getTransactionCount(fromAccount)).then((count) => {
    nonce = count
    return RECEIVING_ACCOUNTS
  }).map((toAccount) => {
    console.time('eth.sendTransaction')
    return benchSendTransaction({
      web3,
      from: fromAccount,
      to: toAccount,
      nonce,
      counter: NUM_TX_PER_ACCOUNT
    })
  }).then((finished) => {
    console.timeEnd('eth.sendTransaction')
    process.send({ finished: true });
  }).catch((error) => {
    console.log('error', error)
    process.send({ error: true });
  })

});
