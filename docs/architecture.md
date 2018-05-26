###### Token, Inc. Smart Contracts Documentation
##### *NOTE: This document is for internal use only. Any external sharing, publication, or distribution with third parties and general audiences without permission and authorization by Token, Inc. is strictly Prohibited.*
---
## Ethereum Smart Contract Architecture

#### Overview



#### Deployment Process

The deployment process is different for the development and production releases of the smart contracts.

###### Development

When developing the smart contracts, this repository uses `truffle develop` local network to deploy, test, and interact with smart contracts.

Truffle has a migration process, `truffle migrate`, which deploys contract sequences using a migration script, located in the `/migrations` folder in the root of this repository.

The default script, `/migrations/1_initial_migration.js`, is used internally by Truffle to keep track of the contracts deployed to the network using a `Migrations.sol` contract. By default, this file should not be altered.

The remaining scripts in the `/migrations` folder are used to deploy the smart contracts in a sequence. The deployment sequence of these contracts is important!

Running the command: `truffle migrate --reset` will deploy the scripts in the sequence corresponding to the pre-fixed number. However, if you need to deploy a specific smart contract, `truffle migrate -f #` is available<sup id="a1">[1](#f1)</sup> where `#` is the number of the script to be deployed.

<small>(E.g. `truffle migrate -f 2` is to deploy `2_deploy_contracts.js`)</small>


###### Production

---
##### Footnotes
<b id="f1">1</b> https://github.com/trufflesuite/truffle/issues/886  [↩](#a1)

---
VERSION: v0.1.0
DISCLOSURE: This document has been prepared by Emergent Financial LLC on behalf of Token, Inc. This document is intended for notes, documentation, and discussion for how the source code is written at a certain software version. Emergent Financial LLC and Token, Inc. do not guarantee the correctness of this software or the accuracy of this documentation and is not held liable for any misinterpretation, unintentional use or misuse of the software. Emergent Financial LLC and Token, Inc. will actively identify and resolve to the best ability, within reasonable limit, any known software limitations, bugs, or other vulnerabilities that might impact this software.
