* [TokenIONameSpace](#tokenionamespace)
  * [getTokenNameSpace](#function-gettokennamespace)
  * [allowOwnership](#function-allowownership)
  * [owner](#function-owner)
  * [transferOwnership](#function-transferownership)
  * [LogOwnershipTransferred](#event-logownershiptransferred)
  * [LogAllowOwnership](#event-logallowownership)

---
# TokenIONameSpace


## *function* getTokenNameSpace

TokenIONameSpace.getTokenNameSpace(currency) `view` `394387b1`

**Returns the address of the contract associated with the currency symbolThis method may be deprecated or refactored to allow for multiple interfaces**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | string Currency symbol of the token (e.g. USDx, JYPx, GBPx) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | contractAddress | Returns the token contract address associated with the currency |

## *function* allowOwnership

TokenIONameSpace.allowOwnership(allowedAddress) `nonpayable` `4bbc142c`

> Allows interface contracts to access contract methods (e.g. Storage contract)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | The address of new owner |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully allowed ownership |

## *function* owner

TokenIONameSpace.owner() `view` `666e1b39`


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |


## *function* transferOwnership

TokenIONameSpace.transferOwnership(newOwner) `nonpayable` `f2fde38b`

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

TokenIONameSpace.LogOwnershipTransferred(previousOwner, newOwner) `db6d05f3`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |

## *event* LogAllowOwnership

TokenIONameSpace.LogAllowOwnership(allowedAddress) `5c65eb6a`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | indexed |
