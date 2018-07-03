* [TokenIOFeeContract](#tokeniofeecontract)
  * [getTokenBalance](#function-gettokenbalance)
  * [transferCollectedFees](#function-transfercollectedfees)
  * [allowOwnership](#function-allowownership)
  * [calculateFees](#function-calculatefees)
  * [owner](#function-owner)
  * [setFeeParams](#function-setfeeparams)
  * [getFeeParams](#function-getfeeparams)
  * [transferOwnership](#function-transferownership)
  * [LogOwnershipTransferred](#event-logownershiptransferred)
  * [LogAllowOwnership](#event-logallowownership)


---
# TokenIOFeeContract


## *function* getTokenBalance

TokenIOFeeContract.getTokenBalance(currency) `view` `025abd58`

**Returns balance of this contract associated with currency symbol.**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | Currency symbol of the token (e.g. USDx, JYPx, GBPx) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | balance | Balance of TokenIO TSM currency account |

## *function* transferCollectedFees

TokenIOFeeContract.transferCollectedFees(currency, to, amount, data) `nonpayable` `13b4312f`

**Transfer collected fees to another account; onlyOwner**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | Currency symbol of the token (e.g. USDx, JYPx, GBPx) |
| *address* | to | Ethereum address of account to send token amount to |
| *uint256* | amount | Amount of tokens to transfer |
| *bytes* | data | Arbitrary bytes data message to include in transfer |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns ture if successfully called from another contract |

## *function* allowOwnership

TokenIOFeeContract.allowOwnership(allowedAddress) `nonpayable` `4bbc142c`

> Allows interface contracts to access contract methods (e.g. Storage contract)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | The address of new owner |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully allowed ownership |

## *function* calculateFees

TokenIOFeeContract.calculateFees(amount) `view` `52238fdd`

**Calculates fee of a given transfer amount**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | amount | transfer amount |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | fees | Returns the fees associated with this contract |

## *function* owner

TokenIOFeeContract.owner() `view` `666e1b39`


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |


## *function* setFeeParams

TokenIOFeeContract.setFeeParams(feeBps, feeMin, feeMax, feeFlat) `nonpayable` `6d5fb64a`

**Set Fee Parameters for Fee Contract**

> The min, max, flat transaction fees should be relative to decimal precision

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | feeBps | Basis points transaction fee |
| *uint256* | feeMin | Minimum transaction fees |
| *uint256* | feeMax | Maximum transaction fee |
| *uint256* | feeFlat | Flat transaction fee returns {"success" : "Returns true if successfully called from another contract"} |


## *function* getFeeParams

TokenIOFeeContract.getFeeParams() `view` `be6fc181`

**Gets fee parameters**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | bps | Returns the basis points fee of the TokenIOFeeContract |
| *uint256* | min | Returns the min fee of the TokenIOFeeContract |
| *uint256* | max | Returns the max fee of the TokenIOFeeContract |
| *uint256* | flat | Returns the flat fee of the TokenIOFeeContract |
| *address* | feeContract | Address of this contract |

## *function* transferOwnership

TokenIOFeeContract.transferOwnership(newOwner) `nonpayable` `f2fde38b`

> Allows the current owner to transfer control of the contract to a newOwner.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | newOwner | The address to transfer ownership to. |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully transferred ownership |

## *event* LogOwnershipTransferred

TokenIOFeeContract.LogOwnershipTransferred(previousOwner, newOwner) `db6d05f3`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |

## *event* LogAllowOwnership

TokenIOFeeContract.LogAllowOwnership(allowedAddress) `5c65eb6a`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | indexed |
