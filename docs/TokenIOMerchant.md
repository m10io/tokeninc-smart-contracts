* [TokenIOMerchant](#tokeniomerchant)
  * [allowOwnership](#function-allowownership)
  * [setParams](#function-setparams)
  * [calculateFees](#function-calculatefees)
  * [owner](#function-owner)
  * [pay](#function-pay)
  * [getFeeParams](#function-getfeeparams)
  * [transferOwnership](#function-transferownership)
  * [LogOwnershipTransferred](#event-logownershiptransferred)
  * [LogAllowOwnership](#event-logallowownership)


---
# TokenIOMerchant


## *function* allowOwnership

TokenIOMerchant.allowOwnership(allowedAddress) `nonpayable` `4bbc142c`

> Allows interface contracts to access contract methods (e.g. Storage contract)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | The address of new owner |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully allowed ownership |

## *function* setParams

TokenIOMerchant.setParams(feeContract) `nonpayable` `4e49acac`

**Sets Merchant globals and fee paramters**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | feeContract | Address of fee contract |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* calculateFees

TokenIOMerchant.calculateFees(amount) `view` `52238fdd`

**Calculates fee of a given transfer amount**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | amount | Amount to calculcate fee value |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | fees | Returns the calculated transaction fees based on the fee contract parameters |

## *function* owner

TokenIOMerchant.owner() `view` `666e1b39`


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |


## *function* pay

TokenIOMerchant.pay(currency, merchant, amount, merchantPaysFees) `nonpayable` `87617d94`

**Pay method for merchant interface**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | Currency symbol of the token (e.g. USDx, JYPx, GBPx) |
| *address* | merchant | Ethereum address of merchant |
| *uint256* | amount | Amount of currency to send to merchant |
| *bool* | merchantPaysFees | Provide option for merchant to pay the transaction fees |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* getFeeParams

TokenIOMerchant.getFeeParams() `view` `be6fc181`

**Gets fee parameters**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | bps | Fee amount as a mesuare of basis points |
| *uint256* | min | Minimum fee amount |
| *uint256* | max | Maximum fee amount |
| *uint256* | flat | Flat fee amount |
| *address* | feeAccount | undefined |

## *function* transferOwnership

TokenIOMerchant.transferOwnership(newOwner) `nonpayable` `f2fde38b`

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

TokenIOMerchant.LogOwnershipTransferred(previousOwner, newOwner) `db6d05f3`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |

## *event* LogAllowOwnership

TokenIOMerchant.LogAllowOwnership(allowedAddress) `5c65eb6a`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | indexed |
