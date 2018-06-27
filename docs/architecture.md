###### Token, Inc. Smart Contracts Documentation
##### *NOTE: This document is for internal use only. Any external sharing, publication, or distribution with third parties and general audiences without permission and authorization by Token, Inc. is strictly Prohibited.*
---
## Token Smart Money

#### Overview

The Token Smart Money (TSM) System allows for integration with several payment services and platforms. This document covers the Ethereum smart contracts architecture, provides a discussion of TSM services and fees, and discusses associated Ethereum transaction costs.

The purpose of the TSM smart contracts are to provide depository tokens that can be backed 1:1 with fiat currency held by a currency issuer, bank, or other authorized financial institution.

Token fiat currency tokens are ERC20 compliant and have an extensible storage contract to allow for future interoperability with third party systems, and to provide various financial services (e.g. currency exchange, escrow, etc.) through smart contract interfaces.

The TSM system is designed to be peer-to-peer (p2p) and business-to-business (b2b), with limited involvement of third party intermediaries.

The TSM Ethereum contracts will be deployed on the Ethereum main network. Consequentially, to interact with the TSM system on Ethereum, there is a cost that is paid to the network maintainers (i.e. transaction miners). This cost can either be paid directly by the participants in the system (institutions and end-users alike) or the cost can be paid through a proxied signing service that Token will charge a fee for.



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

#### Ethereum Smart Contract Architecture

###### Ownable.sol
###### TokenIOAuthority.sol
###### TokenIOStorage.sol
###### TokenIOLib.sol
###### TokenIOERC20.sol
###### TokenIONameSpace.sol
###### TokenIOCurrencyAuthority.sol
###### TokenIOFX.sol

---
#### Creating a New Customer Account

```sequence
StartPage->CreateKey: Cache details of Email, Phone, Name, Picture in device
CreateKey->BIP39: Show & Confirm 24 word bip39 phrase
BIP39->SubmitAccount: Send Payload to Server
```

###### NOTE: private key of Ethereum address are stored in the device secure enclave

```json
// Payload to send to server on account create
{
	"name": "Ryan Tate", // isCCField
	"email": "Ryan.michael.tate@gmail", // isCCField
	"ethereumAddress": "0x0...", // created by phone/device
	"phonePublicKey": "base64->hex", // provided via the secure enclave for the device RSA 2048 Asymm
	"phoneNumber": "001-555-555-5555",
	"messageHash": "0x1234...", // Buffered data that is to be signed
	"signedMessage": "<Signature of message hash>"

}
```

```sequence
Customer->Server: `createAccount({accountDetails})` Request
Server->Customer: Verify Email
Customer->Server: Email is verified (Clicks confirm)
Server->Customer: Send user SMS text w/ code
Customer-Server: Confirm SMS Code
Server->Database: Validate Details & Save User Information
Database->Server: Return successful update
Server->Customer: Account is confirmed, return UUID for account
```

###### NOTE: Once account is created, allow user to Navigate to home screen on application

```sequence
Client->Server: linkBankAccount({ beneficiaryDetails })

Server->CurrencyCloud: Create Beneficiary Account for User
CurrencyCloud->Server: Response

Server->CurrencyAuthorityETHContract: `approveKYC(address account, bool isApproved, string issuerFirm)`
CurrencyAuthorityETHContract->Server: Tx Receipt
Server->Database: Update Account Info (beneficiary_id)
Database->Server: Successful update
```

###### Request Authorization

```js
const bearer = request.headers['Authorization'];
// console.log(bearer) == "Bearer: " + "<base64 signed string>"
// Use passport http-bearer-strategy

// May not work...
passport.use(new BearerStrategy((accessToken, cb) => {
	try {
		// accessToken == <base64 signed string>
		const publicKey = key.verify(accessToken, algorithm, { payload })

		const user = await User.findOne({ publicKey })
	} catch (error) {
		...
	}
}))

```

###### Beneficiary Account Details Object

// For field params, see: https://www.currencycloud.com/developers/docs/item/create-beneficiary/

```json
{
	"name": "Ryan Tate", // isCCField
	"bankAccountHolderName": "Ryan Tate", //isCCField
	"bankCountry": "US", // isCCField (two-letter abv.)
	"currency": "USD", // isCCField (Three-letter abv.)
	"email": "Ryan.michael.tate@gmail", // isCCField
	"ethereumAddress": "0x0...",
	"beneficiaryAddress": "612 E. 35th Street",
	"beneficiaryCountry": "US",
	"accountNumber": "11235813",
	"routingCodeType1": "aba",
	"routingCodeValue1": "13213455",
	"iban": "XE...", // can we create a virtual Ethereum XE Iban from address?
	""

}
```

---
##### Footnotes
<b id="f1">1</b> https://github.com/trufflesuite/truffle/issues/886  [↩](#a1)

---
VERSION: v0.1.3
DISCLOSURE: This document has been prepared by Emergent Financial LLC on behalf of Token, Inc. This document is intended for notes, documentation, and discussion for how the source code is written at a certain software version. Emergent Financial LLC and Token, Inc. do not guarantee the correctness of this software or the accuracy of this documentation and is not held liable for any misinterpretation, unintentional use or misuse of the software. Emergent Financial LLC and Token, Inc. will actively identify and resolve to the best ability, within reasonable limit, any known software limitations, bugs, or other vulnerabilities that might impact this software.
