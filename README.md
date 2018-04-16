###### Token, Inc. Smart Contracts Documentation
##### *NOTE: This document is for internal use only. Any external sharing, publication, or distribution with third parties and general audiences without permission and authorization by Token, Inc. is strictly Prohibited.*
---

## Getting Started -- Developer Guide

*Prerequisites: Node.js >= v9.11.1*

**Step 1: Download Truffle if not installed**

> `npm i -g truffle`

**Step 2: Install local dependencies**

> `npm install`

**Step 3: Launch local development chain using Truffle**

> `truffle develop`

This will open up a Truffle console where you can interact with contracts, run migrations, debug failed transactions, etc.

Once inside the console you may run `migrate --reset` to redeploy contracts or `test` to run the unit tests.

Read more about the solidity console commands  [here]('http://truffleframework.com/docs/getting_started/console').

---

## Developing

When adding new contracts or changing constructor parameters for contracts, you must update the migrations file that contains the deployment script for that contract. You can do this inside `truffle develop` console using the `migrate --reset` command.

If you try to run unit tests on a contract that is not deployed, Truffle will alert you that it cannot find the contract.
