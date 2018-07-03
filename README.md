###### Token, Inc. Smart Money -- Solidity Smart Contracts Documentation
##### *NOTE: This document is for internal use only. Any external sharing, publication, or distribution with third parties and general audiences without permission and authorization by Token, Inc. is strictly Prohibited.*
---
# Token Smart Money
### Solidity Smart Contract Architecture


* [Overview](#overview)
* [Developer Guide](#developer-guide)
* [Contract Deployment Process](#contract-deployment-process)
* [Unit Tests](#unit-tests)
* [Deployed Contract Addresses](#deployed-contract-addresses)
* [Interacting with TokenIO Contracts](#interacting-with-tokenio-contracts)
* [Links to Smart Contract NatSpec Documentation](#links-to-smart-contract-natspec-documentation)
* [Links to Smart Contract Source Code](#links-to-smart-contract-source-code)
* [Smart Contract Use Cases](#smart-contract-use-cases)
* [Audit Report](#audit-report)


#### Overview

The Token Smart Money (TSM) System allows for integration with several payment services and platforms. This document covers the Ethereum smart contracts architecture, provides a discussion of TSM services and fees, and discusses associated Ethereum transaction costs.

The purpose of the TSM smart contracts are to provide depository tokens that can be backed 1:1 with fiat currency held by a currency issuer, bank, or other authorized financial institution.

Token fiat currency tokens are ERC20 compliant and have an extensible storage contract to allow for future interoperability with third party systems, and to provide various financial services (e.g. currency exchange, escrow, etc.) through smart contract interfaces.

The TSM system is designed to be peer-to-peer (p2p) and business-to-business (b2b), with limited involvement of third party intermediaries.

The TSM Ethereum contracts will be deployed on the Ethereum main network. Consequentially, to interact with the TSM system on Ethereum, there is a cost that is paid to the network maintainers (i.e. transaction miners). This cost can either be paid directly by the participants in the system (institutions and end-users alike) or the cost can be paid through a proxied signing service that Token will charge a fee for.


---
#### Developer Guide

##### Contract Deployment Process

The deployment process is different for the development and production releases of the smart contracts.

When developing the smart contracts, this repository uses `truffle develop` (`npm run dev`) local network to deploy, test, and interact with smart contracts.

Truffle has a migration process, `truffle migrate`, which deploys contract sequences using a migration script, located in the `/migrations` folder in the root of this repository.

The default script, `/migrations/1_initial_migration.js`, is used internally by Truffle to keep track of the contracts deployed to the network using a `Migrations.sol` contract. By default, this file should not be altered.

The remaining scripts in the `/migrations` folder are used to deploy the smart contracts in a sequence. The deployment sequence of these contracts is important!

Running the command: `(console)> migrate --reset` will deploy the scripts in the sequence corresponding to the pre-fixed number. However, if you need to deploy a specific smart contract, `(console)> migrate -f #` is available<sup id="a1">[1](#f1)</sup> where `#` is the number of the script to be deployed.

<small>(E.g. `(console)> migrate -f 2` is to deploy `2_deploy_contracts.js`)</small>

##### Unit Tests


In the Truffle console, run all tests:

`(console)> test`

Alternatively, run a single test:

`(console)> test ./test/<name_of_contract>.js`

---
#### Deployed Contract Addresses

The following contracts have been deployed at the associated addresses corresponding to the Ethereum network deployed on.

*Ropsten:*
- TokenIOStorage.sol: **0x0**
- TokenIOAuthority.sol: **0x0**
- TokenIOCurrencyAuthority.sol: **0x0**
- TokenIOFeeContract.sol: **0x0**
- TokenIOFX.sol: **0x0**
- TokenIOERC20.sol: **0x0**

*TokenIO PoA TestNet:*
- TokenIOStorage.sol: **0x0**
- TokenIOAuthority.sol: **0x0**
- TokenIOCurrencyAuthority.sol: **0x0**
- TokenIOFeeContract.sol: **0x0**
- TokenIOFX.sol: **0x0**
- TokenIOERC20.sol: **0x0**

---

#### Interacting with TokenIO Contracts

TokenIO provides mobile and web client applications to interact with smart contracts.

- [Web Application](http://dc.token.io)
- Mobile Application ([iOS](https://apple.com) / [Android](https://android.com))

Alternatively, if you're a software developer, TokenIO contracts can be interacted with using the TokenIO JS Smart Contract SDK.

- [TokenIO TSM Ethereum JS SDK](https://github.com/tokenio)

---

#### Links To Smart Contract NatSpec Documentation

- [Ownable](./docs/Ownable.md)
- [SafeMath](./docs/SafeMath.md)
- [TokenIOAuthority](./docs/TokenIOAuthority.md)
- [TokenIOCurrencyAuthority](./docs/TokenIOCurrencyAuthority.md)
- [TokenIOERC20](./docs/TokenIOERC20.md)
- [TokenIOFeeContract](./docs/TokenIOFeeContract.md)
- [TokenIOFX](./docs/TokenIOFX.md)
- [TokenIOLib](./docs/TokenIOLib.md)
- [TokenIONameSpace](./docs/TokenIONameSpace.md)
- [TokenIOStorage](./docs/TokenIOStorage.md)

---
#### Links to Smart Contract Source Code

- [Ownable](./contracts/Ownable.sol)
- [SafeMath](./contracts/SafeMath.sol)
- [TokenIOAuthority](./contracts/TokenIOAuthority.sol)
- [TokenIOCurrencyAuthority](./contracts/TokenIOCurrencyAuthority.sol)
- [TokenIOERC20](./contracts/TokenIOERC20.sol)
- [TokenIOFeeContract](./contracts/TokenIOFeeContract.sol)
- [TokenIOFX](./contracts/TokenIOFX.sol)
- [TokenIOLib](./contracts/TokenIOLib.sol)
- [TokenIONameSpace](./contracts/TokenIONameSpace.sol)
- [TokenIOStorage](./contracts/TokenIOStorage.sol)

---
#### Smart Contract Use Cases

---
#### Audit Report

---
##### Footnotes
<b id="f1">1</b> https://github.com/trufflesuite/truffle/issues/886  [↩](#a1)

---
VERSION: v0.1.3
DISCLOSURE: This document is intended for notes, documentation, and discussion for how the source code is written at a certain software version. Token, Inc. do not guarantee the correctness of this software or the accuracy of this documentation and is not held liable for any misinterpretation, unintentional use or misuse of the software. Token, Inc. will actively identify and resolve to the best ability, within reasonable limit, any known software limitations, bugs, or other vulnerabilities that might impact this software.
