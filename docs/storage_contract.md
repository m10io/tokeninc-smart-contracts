###### Token, Inc. Smart Contracts Documentation
##### *NOTE: This document is for internal use only. Any external sharing, publication, or distribution with third parties and general audiences without permission and authorization by Token, Inc. is strictly Prohibited.*
---
## Storage.sol Contract

The storage contract provides a persistent layer for other contracts in the event that a contract's code must be upgraded or redeployed.

The storage contract is owned and managed by a multi-signature contract. The multi-signature contract also stores data inside the storage.sol contract and grants additional smart contracts (e.g. the Token contract) access to updating the storage contract for specific keys (e.g. balance, allowance, and other erc20 methods).

The storage contract also maintains the values for modifiers and authorization guards used by other contracts.

---
VERSION: v0.1.0
DISCLOSURE: This document has been prepared by Emergent Financial LLC on behalf of Token, Inc. This document is intended for notes, documentation, and discussion for how the source code is written at a certain software version. Emergent Financial LLC and Token, Inc. do not guarantee the correctness of this software or the accuracy of this documentation and is not held liable for any misinterpretation, unintentional use or misuse of the software. Emergent Financial LLC and Token, Inc. will actively identify and resolve to the best ability, within reasonable limit, any known software limitations, bugs, or other vulnerabilities that might impact this software.
